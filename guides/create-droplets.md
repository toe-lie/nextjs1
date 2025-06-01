# Install DigitalOcean CLI
# macOS: brew install doctl
# Linux: snap install doctl

# Authenticate
doctl auth init

# Create SSH key (if needed)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
doctl compute ssh-key import mykey --public-key-file ~/.ssh/id_rsa.pub

# Create staging droplet
doctl compute droplet create myapp-staging \
  --image ubuntu-22-04-x64 \
  --size s-2vcpu-2gb \
  --region nyc1 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header)

# Create production droplet
doctl compute droplet create myapp-production \
  --image ubuntu-22-04-x64 \
  --size s-2vcpu-4gb \
  --region nyc1 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header)

# Get droplet IPs
doctl compute droplet list --format Name,PublicIPv4