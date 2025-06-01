#!/bin/bash
# scripts/monitor-mongodb.sh

echo "📊 MongoDB Health Check"
echo "======================"

# Check MongoDB status
echo "🔧 Service Status:"
sudo systemctl is-active mongod

# Check if MongoDB is responding
echo "🔗 MongoDB Connection:"
if mongosh --quiet --eval "db.runCommand('ping')" >/dev/null 2>&1; then
    echo "✅ MongoDB is responding"
else
    echo "❌ MongoDB is not responding"
    exit 1
fi

# Prompt for admin credentials if not provided as environment variables
if [ -z "$MONGODB_ADMIN_USER" ] || [ -z "$MONGODB_ADMIN_PASSWORD" ]; then
    echo ""
    echo "🔑 Authentication required for detailed monitoring:"
    read -p "Admin username (default: admin): " ADMIN_USER
    ADMIN_USER=${ADMIN_USER:-admin}
    read -s -p "Admin password: " ADMIN_PASSWORD
    echo ""
else
    ADMIN_USER=$MONGODB_ADMIN_USER
    ADMIN_PASSWORD=$MONGODB_ADMIN_PASSWORD
fi

# Escape special characters in password and remove newlines
ESCAPED_PASSWORD=$(printf '%s' "$ADMIN_PASSWORD" | sed 's/[[\.*^$()+?{|]/\\&/g' | tr -d '\n\r')

echo ""
echo "🔄 Replica Set Status:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  var status = rs.status();
  print('Replica Set: ' + status.set);
  var primary = status.members.find(m => m.stateStr === 'PRIMARY');
  if (primary) {
    print('Primary: ' + primary.name);
  }
  print('Members: ' + status.members.length);
  status.members.forEach(function(member) {
    print('  - ' + member.name + ': ' + member.stateStr);
  });
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "💾 Database Sizes:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  db.adminCommand('listDatabases').databases.forEach(function(database) {
    if (database.name !== 'admin' && database.name !== 'config' && database.name !== 'local') {
      print(database.name + ': ' + (database.sizeOnDisk / 1024 / 1024).toFixed(2) + ' MB');
    }
  });
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "🔗 Active Connections:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  var connections = db.serverStatus().connections;
  print('Current: ' + connections.current);
  print('Available: ' + connections.available);
  print('Total Created: ' + connections.totalCreated);
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "🧠 Memory Usage:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  var mem = db.serverStatus().mem;
  print('Resident: ' + mem.resident + ' MB');
  print('Virtual: ' + mem.virtual + ' MB');
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "📈 Performance Metrics:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  var stats = db.serverStatus();
  print('Uptime: ' + Math.floor(stats.uptime / 3600) + ' hours');
  print('Operations per second:');
  if (stats.opcounters) {
    var ops = stats.opcounters;
    print('  - Inserts: ' + ops.insert);
    print('  - Queries: ' + ops.query);
    print('  - Updates: ' + ops.update);
    print('  - Deletes: ' + ops.delete);
  }
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "👥 Database Users:"
mongosh admin --quiet --eval "
try {
  db.auth('$ADMIN_USER', '$ESCAPED_PASSWORD');
  print('Users in admin database:');
  var users = db.getUsers();
  if (users && users.users) {
    users.users.forEach(function(user) {
      print('  - ' + user.user + ' (roles: ' + user.roles.map(r => r.role).join(', ') + ')');
    });
  } else if (users && Array.isArray(users)) {
    users.forEach(function(user) {
      print('  - ' + user.user + ' (roles: ' + user.roles.map(r => r.role).join(', ') + ')');
    });
  } else {
    print('  No users found or unexpected format');
  }
} catch(e) {
  print('Error: ' + e.message);
}
"

echo ""
echo "✅ MongoDB health check complete"