# DigitalOcean Droplet Sync Commands Reference

*Complete guide for file synchronization between local machine and droplets*

## 📁 Basic File Transfer Commands

### 🔼 Upload Files (Local → Droplet)

#### Single File Upload
```bash
# Basic file upload
scp /local/path/file.txt root@DROPLET_IP:/remote/path/

# Upload with specific SSH key
scp -i ~/.ssh/your_key /local/path/file.txt root@DROPLET_IP:/remote/path/

# Upload to staging server
scp myfile.txt root@STAGING_IP:/var/www/myapp/staging/

# Upload to production server
scp myfile.txt root@PRODUCTION_IP:/var/www/myapp/production/
```

#### Multiple Files Upload
```bash
# Upload multiple files
scp file1.txt file2.txt root@DROPLET_IP:/remote/path/

# Upload with wildcard
scp *.js root@DROPLET_IP:/var/www/myapp/staging/

# Upload entire directory (recursive)
scp -r /local/directory/ root@DROPLET_IP:/remote/path/
```

### 🔽 Download Files (Droplet → Local)

#### Single File Download
```bash
# Basic file download
scp root@DROPLET_IP:/remote/path/file.txt /local/path/

# Download environment file
scp root@STAGING_IP:/etc/myapp/staging.env ./downloaded-staging.env

# Download logs
scp root@PRODUCTION_IP:/var/log/myapp/production-error.log ./logs/

# Download database backup
scp root@PRODUCTION_IP:/var/backups/myapp/backup.tar.gz ./backups/
```

#### Multiple Files Download
```bash
# Download multiple files with wildcard
scp root@DROPLET_IP:/remote/path/*.log ./local/logs/

# Download entire directory
scp -r root@DROPLET_IP:/var/www/myapp/staging/ ./downloaded-staging/

# Download all environment files
scp root@DROPLET_IP:/etc/myapp/*.env ./env-backup/
```

## 🔄 Advanced Sync with Rsync

### Upload with Sync
```bash
# Basic directory sync (upload)
rsync -avz /local/directory/ root@DROPLET_IP:/remote/directory/

# Sync with delete (removes files not in source)
rsync -avz --delete /local/directory/ root@DROPLET_IP:/remote/directory/

# Sync excluding certain files
rsync -avz --exclude='node_modules' --exclude='.git' ./ root@STAGING_IP:/var/www/myapp/staging/

# Sync built application
rsync -avz .next/standalone/ root@STAGING_IP:/var/www/myapp/staging/

# Show progress during sync
rsync -avz --progress /local/directory/ root@DROPLET_IP:/remote/directory/
```

### Download with Sync
```bash
# Basic directory sync (download)
rsync -avz root@DROPLET_IP:/remote/directory/ /local/directory/

# Sync logs to local
rsync -avz root@PRODUCTION_IP:/var/log/myapp/ ./logs/

# Sync backups to local
rsync -avz root@PRODUCTION_IP:/var/backups/myapp/ ./backups/

# Sync with progress indicator
rsync -avz --progress root@DROPLET_IP:/remote/directory/ /local/directory/
```

## 🔧 Environment & Configuration Management

### Environment Files
```bash
# Upload staging environment
scp .env.staging root@STAGING_IP:/etc/myapp/staging.env

# Upload production environment  
scp .env.production root@PRODUCTION_IP:/etc/myapp/production.env

# Download environment files for backup
scp root@STAGING_IP:/etc/myapp/staging.env ./env-backup/staging.env
scp root@PRODUCTION_IP:/etc/myapp/production.env ./env-backup/production.env

# Sync all environment files
rsync -avz root@DROPLET_IP:/etc/myapp/ ./env-backup/

# Secure environment file permissions after upload
ssh root@DROPLET_IP 'chmod 600 /etc/myapp/*.env'
```

### Configuration Files
```bash
# Upload PM2 ecosystem files
scp ecosystem.config.js root@STAGING_IP:/var/www/myapp/staging/
scp ecosystem.config.js root@PRODUCTION_IP:/var/www/myapp/production/

# Upload Nginx configurations
scp nginx/staging.conf root@STAGING_IP:/etc/nginx/sites-available/staging.yourdomain.com
scp nginx/production.conf root@PRODUCTION_IP:/etc/nginx/sites-available/yourdomain.com

# Download current configs for backup
scp root@STAGING_IP:/etc/nginx/sites-available/staging.yourdomain.com ./nginx-backup/
scp root@PRODUCTION_IP:/etc/nginx/sites-available/yourdomain.com ./nginx-backup/

# Upload and enable Nginx site
scp nginx.conf root@DROPLET_IP:/etc/nginx/sites-available/mysite
ssh root@DROPLET_IP 'ln -sf /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/ && nginx -t && systemctl reload nginx'
```

## 📦 Application Deployment Sync

### Manual Deployment Upload
```bash
# Build and upload as archive
npm run build
tar -czf deployment.tar.gz -C .next/standalone .
scp deployment.tar.gz root@STAGING_IP:/tmp/

# Upload source code (excluding build artifacts)
rsync -avz --exclude='node_modules' --exclude='.git' --exclude='.next' ./ root@STAGING_IP:/var/www/myapp/staging/

# Upload only built application
rsync -avz .next/standalone/ root@STAGING_IP:/var/www/myapp/staging/

# Complete deployment package
rsync -avz --exclude='node_modules' --exclude='.git' \
  --include='.next/standalone' \
  --include='public' \
  --include='prisma' \
  --include='package.json' \
  --include='ecosystem.config.js' \
  ./ root@STAGING_IP:/var/www/myapp/staging/
```

### Scripts and Tools Upload
```bash
# Upload deployment scripts
scp scripts/deploy-staging.sh root@STAGING_IP:/var/www/myapp/staging/
scp scripts/deploy-production.sh root@PRODUCTION_IP:/var/www/myapp/production/

# Upload monitoring scripts
scp scripts/monitor-system.sh root@STAGING_IP:/usr/local/bin/
scp scripts/backup-mongodb.sh root@PRODUCTION_IP:/usr/local/bin/

# Upload and make scripts executable
scp script.sh root@DROPLET_IP:/usr/local/bin/ && ssh root@DROPLET_IP 'chmod +x /usr/local/bin/script.sh'

# Upload multiple scripts at once
rsync -avz scripts/ root@DROPLET_IP:/usr/local/bin/
ssh root@DROPLET_IP 'chmod +x /usr/local/bin/*.sh'
```

## 📊 Logs and Monitoring

### Download Logs
```bash
# Download specific log files
scp root@STAGING_IP:/var/log/myapp/staging-error.log ./logs/
scp root@PRODUCTION_IP:/var/log/myapp/production-combined.log ./logs/

# Download system logs
scp root@PRODUCTION_IP:/var/log/nginx/error.log ./logs/nginx-error.log
scp root@PRODUCTION_IP:/var/log/mongodb/mongod.log ./logs/mongodb.log

# Download PM2 logs
scp root@DROPLET_IP:~/.pm2/logs/*.log ./logs/pm2/

# Sync all application logs
rsync -avz root@PRODUCTION_IP:/var/log/myapp/ ./logs/myapp/
rsync -avz root@PRODUCTION_IP:/var/log/nginx/ ./logs/nginx/

# Download recent logs only (last 24 hours)
ssh root@DROPLET_IP 'find /var/log/myapp -name "*.log" -mtime -1 -exec tar -czf /tmp/recent-logs.tar.gz {} \;'
scp root@DROPLET_IP:/tmp/recent-logs.tar.gz ./logs/
```

### Real-time Log Monitoring
```bash
# Follow logs in real-time via SSH
ssh root@DROPLET_IP 'tail -f /var/log/myapp/production-error.log'
ssh root@DROPLET_IP 'tail -f /var/log/nginx/error.log'
ssh root@DROPLET_IP 'pm2 logs myapp-production --lines 50'

# Monitor multiple logs simultaneously
ssh root@DROPLET_IP 'tail -f /var/log/myapp/*.log'
```

## 💾 Database Backups

### Download Backups
```bash
# Download latest backup
scp root@PRODUCTION_IP:/var/backups/myapp/$(ssh root@PRODUCTION_IP 'ls -t /var/backups/myapp/*.tar.gz | head -1') ./backups/

# Download all backups
rsync -avz root@PRODUCTION_IP:/var/backups/myapp/ ./backups/

# Upload backup to server
scp ./local-backup.tar.gz root@PRODUCTION_IP:/var/backups/myapp/

# Create and download fresh backup
ssh root@PRODUCTION_IP '/usr/local/bin/backup-mongodb.sh'
sleep 30  # Wait for backup to complete
scp root@PRODUCTION_IP:/var/backups/myapp/$(ssh root@PRODUCTION_IP 'ls -t /var/backups/myapp/*.tar.gz | head -1') ./backups/
```

### Backup Automation
```bash
# Download backup script and modify locally
scp root@PRODUCTION_IP:/usr/local/bin/backup-mongodb.sh ./scripts/
# Edit locally, then upload back
scp ./scripts/backup-mongodb.sh root@PRODUCTION_IP:/usr/local/bin/
ssh root@PRODUCTION_IP 'chmod +x /usr/local/bin/backup-mongodb.sh'
```

## 🔐 SSH Key Management

### SSH Configuration Setup
```bash
# Create SSH config for easier access
cat > ~/.ssh/config << EOF
Host staging
    HostName STAGING_IP
    User root
    IdentityFile ~/.ssh/staging_key
    Port 22

Host production
    HostName PRODUCTION_IP
    User root
    IdentityFile ~/.ssh/production_key
    Port 22

Host droplet-*
    User root
    Port 22
    IdentitiesOnly yes
EOF

# Use simplified commands after config
scp file.txt staging:/var/www/myapp/staging/
scp file.txt production:/var/www/myapp/production/
rsync -avz ./ staging:/var/www/myapp/staging/
```

### SSH Key Upload
```bash
# Upload SSH public key to server
ssh-copy-id -i ~/.ssh/id_rsa.pub root@DROPLET_IP

# Manually upload key
scp ~/.ssh/id_rsa.pub root@DROPLET_IP:/tmp/
ssh root@DROPLET_IP 'cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

## 🚀 Quick Deployment Workflows

### Complete Application Deployment
```bash
# Full staging deployment
rsync -avz --exclude='node_modules' --exclude='.git' ./ root@STAGING_IP:/var/www/myapp/staging/
ssh root@STAGING_IP 'cd /var/www/myapp/staging && npm ci --only=production && npm run build && pm2 restart myapp-stagin