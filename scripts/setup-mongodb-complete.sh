#!/bin/bash
# scripts/setup-mongodb-complete.sh

set -e

echo "🚀 Complete MongoDB Setup with Replica Set"
echo "=========================================="

# Update system
sudo apt update

# Install MongoDB
echo "📦 Installing MongoDB..."
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Create directories and set permissions
echo "🔧 Setting up directories and permissions..."
sudo mkdir -p /var/lib/mongodb
sudo mkdir -p /var/log/mongodb
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb

# Generate keyfile for replica set authentication (with check)
if [ ! -f /etc/mongodb-keyfile ]; then
    echo "🔑 Generating keyfile for replica set authentication..."
    sudo bash -c 'openssl rand -base64 756 > /etc/mongodb-keyfile'
    sudo chmod 400 /etc/mongodb-keyfile
    sudo chown mongodb:mongodb /etc/mongodb-keyfile
else
    echo "🔑 Keyfile already exists, skipping generation..."
fi

# Configure MongoDB
echo "⚙️ Configuring MongoDB..."
sudo tee /etc/mongod.conf << 'EOF'
storage:
  dbPath: /var/lib/mongodb

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  timeZoneInfo: /usr/share/zoneinfo

security:
  authorization: enabled
  keyFile: /etc/mongodb-keyfile

replication:
  replSetName: "rs0"
EOF

# Start MongoDB
echo "🔄 Starting MongoDB..."
sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl restart mongod

# Wait for startup
echo "⏳ Waiting for MongoDB to start..."
sleep 10

# Check if MongoDB is running
if ! systemctl is-active --quiet mongod; then
  echo "❌ MongoDB failed to start. Checking logs..."
  sudo journalctl -u mongod -n 50 --no-pager
  exit 1
fi

# Initialize replica set
echo "🔄 Initializing replica set..."
mongosh --eval "
try {
  rs.initiate({
    _id: 'rs0',
    members: [{ _id: 0, host: 'localhost:27017' }]
  });
  console.log('Replica set initialized successfully');
} catch (e) {
  console.error('Error initializing replica set:', e);
  throw e;
}
" || {
  echo "❌ Failed to initialize replica set";
  exit 1;
}

# Wait for replica set to be ready
echo "⏳ Waiting for replica set to stabilize..."
sleep 15

# Create users
echo "👤 Creating database users..."

# Prompt for passwords
read -s -p "Enter admin password: " ADMIN_PASSWORD
echo
read -s -p "Enter staging app password: " STAGING_PASSWORD
echo
read -s -p "Enter production app password: " PRODUCTION_PASSWORD
echo

# Create admin user
echo "🛡️ Creating admin user..."
mongosh admin --eval "
try {
  db.createUser({
    user: 'admin',
    pwd: '$ADMIN_PASSWORD',
    roles: [
      { role: 'userAdminAnyDatabase', db: 'admin' },
      { role: 'readWriteAnyDatabase', db: 'admin' },
      { role: 'dbAdminAnyDatabase', db: 'admin' },
      { role: 'clusterAdmin', db: 'admin' }
    ]
  });
  console.log('Admin user created successfully');
} catch (e) {
  console.error('Error creating admin user:', e);
  throw e;
}
" || {
  echo "❌ Failed to create admin user";
  exit 1;
}

# Create app users
echo "👥 Creating application users..."
mongosh admin --eval "
try {
  db.auth('admin', '$ADMIN_PASSWORD');
  
  db.createUser({
    user: 'nextjs1_staging',
    pwd: '$STAGING_PASSWORD',
    roles: [{ role: 'readWrite', db: 'nextjs1_staging' }]
  });
  
  db.createUser({
    user: 'nextjs1_production',
    pwd: '$PRODUCTION_PASSWORD',
    roles: [{ role: 'readWrite', db: 'nextjs1_production' }]
  });
  
  console.log('Application users created successfully');
} catch (e) {
  console.error('Error creating application users:', e);
  throw e;
}
" || {
  echo "❌ Failed to create application users";
  exit 1;
}

# Configure firewall
echo "🔒 Configuring firewall..."
sudo ufw allow 27017

# Test connection
echo "🧪 Testing replica set..."
# Escape special characters in password for shell
ESCAPED_ADMIN_PASSWORD=$(printf '%s\n' "$ADMIN_PASSWORD" | sed 's/[[\.*^$()+?{|]/\\&/g')
mongosh admin --eval "
try {
  db.auth('admin', '$ESCAPED_ADMIN_PASSWORD');
  const status = rs.status();
  console.log('Replica set status:', status.ok ? 'OK' : 'Error');
  console.log('Members:');
  status.members.forEach(member => {
    console.log(\`- \${member.name}: \${member.stateStr}\`);
  });
} catch (e) {
  console.error('Error checking replica set status:', e);
  throw e;
}
" || {
  echo "❌ Replica set test failed";
  exit 1;
}

echo "✅ MongoDB setup complete!"
echo ""
echo "📝 Connection strings:"
echo "Admin:       mongodb://admin:$ADMIN_PASSWORD@localhost:27017/admin?authSource=admin&replicaSet=rs0"
echo "Staging:     mongodb://nextjs1_staging:$STAGING_PASSWORD@localhost:27017/nextjs1_staging?authSource=admin&replicaSet=rs0"
echo "Production:  mongodb://nextjs1_production:$PRODUCTION_PASSWORD@localhost:27017/nextjs1_production?authSource=admin&replicaSet=rs0"
echo ""
echo "⚠️  Save these connection strings securely!"
echo "🔑 Keyfile location: /etc/mongodb-keyfile"