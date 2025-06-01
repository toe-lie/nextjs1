#!/bin/bash
# scripts/cleanup-mongodb-complete.sh
# This script completely removes MongoDB and all its data for a fresh start

set -e

echo "🧹 MongoDB Complete Cleanup Script"
echo "=================================="
echo "⚠️  WARNING: This will DELETE ALL MongoDB data and users!"
echo "⚠️  This action is IRREVERSIBLE!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed? Type 'YES' to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

echo ""
echo "🛑 Stopping MongoDB service..."
sudo systemctl stop mongod || echo "MongoDB service was not running"

echo "🔧 Disabling MongoDB service..."
sudo systemctl disable mongod || echo "MongoDB service was not enabled"

echo "🗑️  Removing MongoDB data directories..."
sudo rm -rf /var/lib/mongodb/*
sudo rm -rf /var/log/mongodb/*

echo "🔑 Removing MongoDB keyfile..."
sudo rm -f /etc/mongodb-keyfile

echo "⚙️  Removing MongoDB configuration..."
sudo rm -f /etc/mongod.conf

echo "📦 Removing MongoDB packages..."
sudo apt-get purge -y mongodb-org*
sudo apt-get autoremove -y

echo "🗂️  Removing MongoDB repository..."
sudo rm -f /etc/apt/sources.list.d/mongodb-org-*.list
sudo rm -f /usr/share/keyrings/mongodb-server-*.gpg

echo "🔄 Updating package lists..."
sudo apt-get update

echo "👤 Removing MongoDB user and group..."
sudo userdel mongodb 2>/dev/null || echo "MongoDB user did not exist"
sudo groupdel mongodb 2>/dev/null || echo "MongoDB group did not exist"

echo "🔒 Removing firewall rules..."
sudo ufw delete allow 27017 2>/dev/null || echo "Firewall rule did not exist"

echo "🧽 Cleaning up any remaining MongoDB processes..."
sudo pkill -f mongod 2>/dev/null || true
sleep 2  # Give processes time to terminate gracefully

echo "🗁 Removing any remaining MongoDB directories..."
sudo rm -rf /var/lib/mongodb
sudo rm -rf /var/log/mongodb
sudo rm -rf /tmp/mongodb-*

echo "🔍 Checking for any remaining MongoDB files..."
REMAINING_FILES=$(find /etc /var /usr -name "*mongo*" 2>/dev/null | grep -v "/proc/" | head -10)
if [ -n "$REMAINING_FILES" ]; then
    echo "📝 Found some remaining MongoDB-related files:"
    echo "$REMAINING_FILES"
    echo ""
    read -p "Remove these files too? (y/N): " REMOVE_REMAINING
    if [ "$REMOVE_REMAINING" = "y" ] || [ "$REMOVE_REMAINING" = "Y" ]; then
        echo "$REMAINING_FILES" | xargs sudo rm -rf 2>/dev/null || true
        echo "✅ Remaining files removed"
    fi
fi

echo ""
echo "✅ MongoDB cleanup complete!"
echo ""
echo "🚀 You can now run your setup script for a fresh installation:"
echo "   ./scripts/setup-mongodb-complete.sh"
echo ""
echo "📋 What was cleaned:"
echo "   ✓ MongoDB service stopped and disabled"
echo "   ✓ All MongoDB data deleted"
echo "   ✓ All MongoDB users removed"
echo "   ✓ MongoDB keyfile deleted"
echo "   ✓ MongoDB configuration removed"
echo "   ✓ MongoDB packages uninstalled"
echo "   ✓ MongoDB repository removed"
echo "   ✓ Firewall rules removed"
echo "   ✓ System user/group removed"