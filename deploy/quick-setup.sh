#!/bin/bash

# Quick Setup Script for VPS
# This script prepares a fresh VPS for HW Publishing deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_info "Setting up VPS for HW Publishing deployment..."

# Update system
echo_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js (using NodeSource repository for latest version)
echo_info "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Nginx
echo_info "Installing Nginx..."
sudo apt install -y nginx

# Install Git
echo_info "Installing Git..."
sudo apt install -y git

# Install Certbot for SSL
echo_info "Installing Certbot for SSL certificates..."
sudo apt install -y certbot python3-certbot-nginx

# Configure firewall
echo_info "Configuring firewall..."
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw --force enable

# Start and enable Nginx
echo_info "Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Create www-data user if it doesn't exist
if ! id "www-data" &>/dev/null; then
    echo_info "Creating www-data user..."
    sudo useradd -r -s /bin/false www-data
fi

echo_info "VPS setup completed!"
echo_info "You can now run the deployment script: ./deploy/deploy.sh"
echo_warn "Don't forget to:"
echo_warn "1. Upload your code to the VPS"
echo_warn "2. Configure your environment variables"
echo_warn "3. Update the domain name in the Nginx configuration"
