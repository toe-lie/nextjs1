# Copy script to servers and run
scp scripts/server-setup.sh root@YOUR_STAGING_IP:~/
scp scripts/server-setup.sh root@YOUR_PRODUCTION_IP:~/

# Run on each server
ssh root@YOUR_STAGING_IP 'bash ~/server-setup.sh'
ssh root@YOUR_PRODUCTION_IP 'bash ~/server-setup.sh'