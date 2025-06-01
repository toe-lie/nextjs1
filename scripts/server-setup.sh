#!/bin/bash
# scripts/server-setup.sh

echo "🚀 Setting up Ubuntu server for Next.js 15..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20 (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js version
node --version
npm --version

# Install PM2 globally
sudo npm install -g pm2

# Install Nginx
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Install certbot for SSL
sudo apt install certbot python3-certbot-nginx -y

# Create application directories
sudo mkdir -p /var/www/nextjs1/{staging,production}
sudo chown -R $USER:$USER /var/www/nextjs1

# Create log directories
sudo mkdir -p /var/log/nextjs1
sudo chown -R $USER:$USER /var/log/nextjs1

# Create environment configuration directory
sudo mkdir -p /etc/nextjs1
sudo chown -R $USER:$USER /etc/nextjs1

# Setup firewall
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Install Git
sudo apt install git -y

echo "✅ Server setup complete!"
echo "📝 Next steps:"
echo "1. Configure your domain DNS to point to this server"
echo "2. Run SSL certificate setup"
echo "3. Deploy your application"