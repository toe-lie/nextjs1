#!/bin/bash
# scripts/simple-backup.sh

echo "📦 Creating backup..."

BACKUP_DIR="/var/backups/myapp/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup application code
echo "💾 Backing up application..."
tar -czf $BACKUP_DIR/app-backup.tar.gz /var/www/myapp

# Backup environment files
echo "🔐 Backing up environment..."
sudo tar -czf $BACKUP_DIR/env-backup.tar.gz /etc/myapp

# Backup Nginx config
echo "⚙️ Backing up Nginx config..."
sudo tar -czf $BACKUP_DIR/nginx-backup.tar.gz /etc/nginx/sites-available

# Clean old backups (keep 7 days)
find /var/backups/myapp -type d -mtime +7 -exec rm -rf {} \;

echo "✅ Backup completed: $BACKUP_DIR"