#!/bin/bash
# scripts/secure-mongodb.sh

echo "🔒 Securing MongoDB installation..."

# Update MongoDB configuration for security
sudo tee -a /etc/mongod.conf << 'EOF'

# Additional security settings
setParameter:
  authenticationMechanisms: SCRAM-SHA-1,SCRAM-SHA-256
  enableLocalhostAuthBypass: false

# Operation profiling
operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100

# Network security
net:
  maxIncomingConnections: 100
  compression:
    compressors: snappy,zlib
EOF

# Restart MongoDB
sudo systemctl restart mongod

# Create backup script
sudo tee /usr/local/bin/backup-mongodb.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/var/backups/mongodb"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$DATE"

mkdir -p $BACKUP_PATH

mongodump --out $BACKUP_PATH

# Compress backup
tar -czf $BACKUP_PATH.tar.gz -C $BACKUP_DIR $DATE
rm -rf $BACKUP_PATH

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_PATH.tar.gz"
EOF

sudo chmod +x /usr/local/bin/backup-mongodb.sh

# Add backup to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-mongodb.sh") | crontab -

echo "✅ MongoDB security hardening complete"