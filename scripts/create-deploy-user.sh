#!/bin/bash
# scripts/create-deploy-user.sh

set -e

echo "👤 Creating Deploy User Setup"
echo "============================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root (or with sudo)"
    echo "Usage: sudo ./create-deploy-user.sh"
    exit 1
fi

echo "📝 Creating 'deploy' user..."

# Create deploy user with home directory
useradd -m -s /bin/bash deploy

# Add deploy user to necessary groups
usermod -aG sudo deploy  # For sudo access if needed
usermod -aG www-data deploy  # For web server permissions

echo "🔐 Setting up SSH access for deploy user..."

# Create .ssh directory for deploy user
mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

# Create authorized_keys file
touch /home/deploy/.ssh/authorized_keys
chmod 600 /home/deploy/.ssh/authorized_keys

# Set proper ownership
chown -R deploy:deploy /home/deploy/.ssh

echo "📁 Creating application directories..."

# Create application directories with proper ownership
mkdir -p /var/www/nextjs1/{staging,production}
mkdir -p /var/log/nextjs1
mkdir -p /var/backups/nextjs1
mkdir -p /etc/nextjs1

# Set ownership to deploy user
chown -R deploy:deploy /var/www/nextjs1
chown -R deploy:deploy /var/log/nextjs1
chown -R deploy:deploy /var/backups/nextjs1
chown -R deploy:deploy /etc/nextjs1

# Set proper permissions
chmod -R 755 /var/www/nextjs1
chmod -R 755 /var/log/nextjs1
chmod -R 755 /var/backups/nextjs1
chmod -R 700 /etc/nextjs1  # More restrictive for config files

echo "⚙️ Configuring sudo access for deploy user..."

# Create sudoers file for deploy user (passwordless for specific commands)
tee /etc/sudoers.d/deploy << 'EOF'
# Allow deploy user to restart services without password
deploy ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
deploy ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
deploy ALL=(ALL) NOPASSWD: /bin/systemctl status nginx
deploy ALL=(ALL) NOPASSWD: /usr/bin/nginx -t
deploy ALL=(ALL) NOPASSWD: /bin/systemctl restart mongod
deploy ALL=(ALL) NOPASSWD: /bin/systemctl status mongod

# Allow deploy user to manage PM2 as root if needed
deploy ALL=(ALL) NOPASSWD: /usr/bin/pm2 *

# Allow deploy user to read/write log files
deploy ALL=(ALL) NOPASSWD: /bin/chown deploy:deploy /var/log/nextjs1/*
deploy ALL=(ALL) NOPASSWD: /bin/chmod 644 /var/log/nextjs1/*
EOF

# Validate sudoers file
visudo -c -f /etc/sudoers.d/deploy

echo "🔧 Setting up Node.js and PM2 for deploy user..."

# Switch to deploy user and install Node.js tools
su - deploy << 'EOF'
# Install PM2 globally for deploy user
npm install -g pm2

# Setup PM2 startup (will create systemd service)
pm2 startup
EOF

echo "🔑 SSH Key Setup Instructions"
echo "============================="
echo ""
echo "To add your SSH public key for the deploy user:"
echo ""
echo "Option 1: Copy from your local machine"
echo "---------------------------------------"
echo "# On your local machine, copy your public key:"
echo "ssh-copy-id deploy@YOUR_SERVER_IP"
echo ""
echo "Option 2: Manual setup"
echo "----------------------"
echo "# Copy your public key content and run:"
echo "echo 'YOUR_PUBLIC_KEY_CONTENT' >> /home/deploy/.ssh/authorized_keys"
echo ""
echo "Option 3: Copy from root user (if root has the key)"
echo "---------------------------------------------------"
if [ -f /root/.ssh/authorized_keys ]; then
    echo "# Copying existing keys from root to deploy user..."
    cat /root/.ssh/authorized_keys >> /home/deploy/.ssh/authorized_keys
    chown deploy:deploy /home/deploy/.ssh/authorized_keys
    echo "✅ SSH keys copied from root to deploy user"
else
    echo "# No existing keys found in /root/.ssh/authorized_keys"
fi

echo ""
echo "🧪 Testing deploy user setup..."

# Test if deploy user can access directories
su - deploy -c "ls -la /var/www/nextjs1/" > /dev/null && echo "✅ Deploy user can access /var/www/nextjs1/"
su - deploy -c "touch /var/log/nextjs1/test.log && rm /var/log/nextjs1/test.log" > /dev/null && echo "✅ Deploy user can write to /var/log/nextjs1/"
su - deploy -c "pm2 --version" > /dev/null && echo "✅ PM2 is available for deploy user"

echo ""
echo "✅ Deploy User Setup Complete!"
echo "=============================="
echo ""
echo "📋 Summary:"
echo "- User: deploy"
echo "- Home: /home/deploy"
echo "- Groups: deploy, sudo, www-data"
echo "- Application directory: /var/www/nextjs1/ (owned by deploy)"
echo "- Logs directory: /var/log/nextjs1/ (owned by deploy)"
echo "- Config directory: /etc/nextjs1/ (owned by deploy)"
echo "- Backups directory: /var/backups/nextjs1/ (owned by deploy)"
echo ""
echo "🔐 Security Features:"
echo "- Passwordless sudo for specific service commands"
echo "- SSH key-based authentication"
echo "- Restricted permissions on config directory"
echo ""
echo "📝 Next Steps:"
echo "1. Add your SSH public key to deploy user"
echo "2. Test SSH connection: ssh deploy@YOUR_SERVER_IP"
echo "3. Update your GitHub Actions to use 'deploy' user"
echo "4. Update your environment files in /etc/nextjs1/"
echo ""
echo "🔧 GitHub Actions Update Needed:"
echo "Update your secrets to use:"
echo "- STAGING_USER: deploy"
echo "- PRODUCTION_USER: deploy"
echo ""
echo "⚠️  Remember to:"
echo "- Move your environment files to /etc/nextjs1/"
echo "- Update file paths in your deployment scripts"
echo "- Test the deployment pipeline"