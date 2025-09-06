#!/bin/bash

# HW Publishing Remote VPS Setup Script
# This script prepares a fresh VPS for HW Publishing deployment from your local machine

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES
VPS_HOST="168.75.108.27"  # e.g., "192.168.1.100" or "myserver.com"
VPS_USER="ubuntu"          # e.g., "ubuntu" or "root"
VPS_SSH_KEY="~/.ssh/id_rsa_hw-publishing_oracle"                    # Path to SSH key (optional, leave empty for password auth)
GIT_REPO="https://github.com/azevedev/hw_publishing.git"            # Git repository URL (e.g., "https://github.com/user/hw_publishing.git")
GIT_BRANCH="main"                 # Git branch to deploy (default: main)
APP_NAME="hw_publishing"
DEPLOY_USER="www-data"
DEPLOY_DIR="/var/www/$APP_NAME"
SERVICE_NAME="hw-publishing-backend"
NGINX_SITE="hw-publishing"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if configuration is set
if [ "$VPS_HOST" = "your-vps-ip-or-domain" ] || [ "$VPS_USER" = "your-username" ] || [ -z "$GIT_REPO" ]; then
    echo_error "Please update the configuration variables at the top of this script:"
    echo_error "- VPS_HOST: Your VPS IP address or domain"
    echo_error "- VPS_USER: Your VPS username"
    echo_error "- VPS_SSH_KEY: Path to your SSH key (required for this deployment)"
    echo_error "- GIT_REPO: Git repository URL (required for this deployment)"
    exit 1
fi

# Build SSH command
SSH_CMD="ssh"
if [ -n "$VPS_SSH_KEY" ]; then
    SSH_CMD="ssh -i $VPS_SSH_KEY"
fi

# Test SSH connection
echo_step "Testing SSH connection to $VPS_USER@$VPS_HOST..."
if ! $SSH_CMD -o ConnectTimeout=10 -o BatchMode=yes $VPS_USER@$VPS_HOST "echo 'SSH connection successful'" >/dev/null 2>&1; then
    echo_error "Cannot connect to $VPS_USER@$VPS_HOST"
    echo_error "Please check:"
    echo_error "1. VPS is running and accessible"
    echo_error "2. SSH credentials are correct"
    echo_error "3. SSH key is properly configured (if using key auth)"
    exit 1
fi

echo_info "SSH connection successful!"

echo_step "Setting up VPS for HW Publishing deployment..."

# Update system
echo_info "Updating system packages..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo apt update && sudo apt upgrade -y"

# Install Node.js (using NodeSource repository for latest version)
echo_info "Installing Node.js..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&
    sudo apt-get install -y nodejs
"

# Install Nginx
echo_info "Installing Nginx..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo apt install -y nginx"

# Install Git
echo_info "Installing Git..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo apt install -y git"

# Install Certbot for SSL
echo_info "Installing Certbot for SSL certificates..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo apt install -y certbot python3-certbot-nginx"

# Configure firewall
echo_info "Configuring firewall..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo ufw allow 22 &&    # SSH
    sudo ufw allow 80 &&    # HTTP
    sudo ufw allow 443 &&   # HTTPS
    sudo ufw --force enable
"

# Start and enable Nginx
echo_info "Starting Nginx..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo systemctl start nginx &&
    sudo systemctl enable nginx
"

# Create www-data user if it doesn't exist
echo_info "Ensuring www-data user exists..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    if ! id 'www-data' &>/dev/null; then
        sudo useradd -r -s /bin/false www-data
    fi
"

# Check installed versions
echo_info "Checking installed versions..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    echo 'Node.js version:' \$(node --version) &&
    echo 'npm version:' \$(npm --version) &&
    echo 'Nginx version:' \$(nginx -v 2>&1)
"

echo_info "VPS setup completed!"
echo_step "Starting application deployment from Git repository..."

# Clone repository on VPS
echo_info "Cloning repository from $GIT_REPO..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo rm -rf /tmp/hw_publishing_source &&
    git clone --branch $GIT_BRANCH $GIT_REPO /tmp/hw_publishing_source
"

# Create deployment directory
echo_info "Creating deployment directory..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo mkdir -p $DEPLOY_DIR && sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR"

# Build frontend on VPS
echo_info "Building frontend on VPS..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    cd /tmp/hw_publishing_source/frontend &&
    npm install &&
    npm run build
"

# Deploy backend
echo_info "Deploying backend..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_source/backend $DEPLOY_DIR/ &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend &&
    cd $DEPLOY_DIR/backend &&
    sudo -u $DEPLOY_USER npm install --production
"

# Deploy frontend
echo_info "Deploying frontend..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_source/frontend/dist $DEPLOY_DIR/frontend &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/frontend
"

# Create environment file template
echo_info "Creating environment file template..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    if [ -f /tmp/hw_publishing_source/deploy/env.example ]; then
        sudo cp /tmp/hw_publishing_source/deploy/env.example $DEPLOY_DIR/backend/.env.example &&
        sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend/.env.example
    fi
"

# Install systemd service
echo_info "Installing systemd service..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp /tmp/hw_publishing_source/deploy/backend.service /etc/systemd/system/$SERVICE_NAME.service &&
    sudo systemctl daemon-reload &&
    sudo systemctl enable $SERVICE_NAME
"

# Configure Nginx
echo_info "Configuring Nginx..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp /tmp/hw_publishing_source/deploy/nginx.conf /etc/nginx/sites-available/$NGINX_SITE &&
    sudo ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/ &&
    sudo rm -f /etc/nginx/sites-enabled/default
"

# Test Nginx configuration
echo_info "Testing Nginx configuration..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo nginx -t"

# Start services
echo_info "Starting services..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo systemctl start $SERVICE_NAME &&
    sudo systemctl reload nginx
"

# Check service status
echo_info "Checking service status..."
BACKEND_STATUS=$($SSH_CMD $VPS_USER@$VPS_HOST "sudo systemctl is-active $SERVICE_NAME" 2>/dev/null || echo "inactive")
NGINX_STATUS=$($SSH_CMD $VPS_USER@$VPS_HOST "sudo systemctl is-active nginx" 2>/dev/null || echo "inactive")

if [ "$BACKEND_STATUS" = "active" ]; then
    echo_info "Backend service is running successfully!"
else
    echo_error "Backend service failed to start. Check logs with:"
    echo_error "$SSH_CMD $VPS_USER@$VPS_HOST 'sudo journalctl -u $SERVICE_NAME -f'"
fi

if [ "$NGINX_STATUS" = "active" ]; then
    echo_info "Nginx is running successfully!"
else
    echo_error "Nginx failed to start. Check logs with:"
    echo_error "$SSH_CMD $VPS_USER@$VPS_HOST 'sudo journalctl -u nginx -f'"
fi

# Cleanup
echo_info "Cleaning up temporary files..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo rm -rf /tmp/hw_publishing_source"

echo_info "Complete VPS setup and deployment finished!"
echo_info "Your application should be accessible at: http://$VPS_HOST"
echo_info "Backend API is available at: http://$VPS_HOST/api/"
echo_warn "Don't forget to:"
echo_warn "1. Configure your environment variables in $DEPLOY_DIR/backend/.env"
echo_warn "2. Update the domain name in /etc/nginx/sites-available/$NGINX_SITE"
echo_warn "3. Set up SSL certificates for HTTPS"
echo_warn "4. Restart the backend service after configuring .env: sudo systemctl restart $SERVICE_NAME"
