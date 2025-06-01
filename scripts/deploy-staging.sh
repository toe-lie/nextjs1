#!/bin/bash
# scripts/deploy-staging.sh

set -e

echo "🚀 Deploying pre-built staging application..."

STAGING_HOST="159.223.38.109"
STAGING_USER="deploy"
APP_DIR="/var/www/nextjs1/staging"

# Deploy pre-built application to staging
ssh $STAGING_USER@$STAGING_HOST << EOF
    cd $APP_DIR

    # Stop current application
    pm2 stop nextjs1-staging || true

    # Load environment variables for database operations
    export \$(cat /etc/nextjs1/staging.env | xargs)

    # Only run database operations (no building!)
    npx prisma generate
    npx prisma db push --accept-data-loss

    # Start the application with the new build
    pm2 start ecosystem.config.js --only nextjs1-staging

    # Reload Nginx
    sudo nginx -t && sudo systemctl reload nginx
EOF

# Health check
echo "🏥 Running health check..."
sleep 10
curl -f https://nextjs1-staging.oneplatforms.app/api/health

echo "✅ Staging deployment complete!"