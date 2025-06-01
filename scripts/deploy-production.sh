#!/bin/bash
# scripts/deploy-production.sh

set -e

echo "🚀 Deploying pre-built production application..."

PRODUCTION_HOST="159.223.38.109"
PRODUCTION_USER="deploy"
APP_DIR="/var/www/nextjs1/production"

# Create database backup first
echo "📦 Creating database backup..."
ssh $PRODUCTION_USER@$PRODUCTION_HOST << 'BACKUP_EOF'
    BACKUP_DIR="/var/backups/nextjs1/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR
    echo "Backup created at: $BACKUP_DIR"
BACKUP_EOF

# Deploy pre-built application to production
ssh $PRODUCTION_USER@$PRODUCTION_HOST << EOF
    cd $APP_DIR

    # Stop current application gracefully
    pm2 stop nextjs1-production || true

    # Load environment variables for database operations
    export \$(cat /etc/nextjs1/production.env | xargs)

    # Only run database operations (no building!)
    npx prisma generate
    npx prisma migrate deploy

    # Start the application with the new build
    pm2 start ecosystem.config.js --only nextjs1-production

    # Test application
    sleep 5
    curl -f http://localhost:3000/api/health || exit 1

    # Reload Nginx
    sudo nginx -t && sudo systemctl reload nginx
EOF

# Final health check
echo "🏥 Running final health check..."
sleep 10
curl -f https://nextjs1.oneplatforms.app/api/health

echo "✅ Production deployment complete!"