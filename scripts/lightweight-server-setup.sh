#!/bin/bash
# scripts/lightweight-server-setup.sh

echo "🚀 Setting up server for lightweight Next.js deployment..."

# Update system
apt update && apt upgrade -y

# Install Node.js 20 (LTS) - only runtime needed
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install PM2 globally (process management only)
npm install -g pm2

# Install Nginx
apt install nginx -y
systemctl start nginx
systemctl enable nginx

# Install certbot for SSL
apt install certbot python3-certbot-nginx -y

# Create directories
mkdir -p /var/www/myapp/{staging,production}
mkdir -p /var/log/myapp
mkdir -p /var/backups/myapp

# Set permissions
chown -R $USER:$USER /var/www/myapp
chown -R $USER:$USER /var/log/myapp

# Setup firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

echo "✅ Lightweight server setup complete!"
echo "📝 Server is ready for pre-built deployments"
``` run build
            pm2 reload myapp-production || pm2 start ecosystem.config.js --only myapp-production
            
            # Test and reload nginx
            sleep 5
            curl -f http://localhost:3000/api/health || exit 1
            sudo nginx -t && sudo systemctl reload nginx
          EOF
      
      - name: Final health check
        run: |
          sleep 15
          curl -f https://yourdomain.com/api/health