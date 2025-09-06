#!/bin/bash

# HW Publishing Remote Deployment Script
# This script deploys both frontend and backend to a VPS from your local machine

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES
VPS_HOST="your-vps-ip-or-domain"  # e.g., "192.168.1.100" or "myserver.com"
VPS_USER="ubuntu"          # e.g., "ubuntu" or "root"
VPS_SSH_KEY=""                    # Path to SSH key (optional, leave empty for password auth)
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
if [ "$VPS_HOST" = "your-vps-ip-or-domain" ] || [ "$VPS_USER" = "your-username" ]; then
    echo_error "Please update the configuration variables at the top of this script:"
    echo_error "- VPS_HOST: Your VPS IP address or domain"
    echo_error "- VPS_USER: Your VPS username"
    echo_error "- VPS_SSH_KEY: Path to your SSH key (optional)"
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

# Check if required commands exist on local machine
command -v node >/dev/null 2>&1 || { echo_error "Node.js is required but not installed locally. Aborting."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo_error "npm is required but not installed locally. Aborting."; exit 1; }

echo_step "Starting remote deployment of HW Publishing application..."

# Build frontend locally
echo_info "Building frontend locally..."
cd frontend
npm run build
cd ..

# Create temporary deployment directory
TEMP_DIR="/tmp/hw_publishing_deploy_$(date +%s)"
echo_info "Creating temporary deployment directory: $TEMP_DIR"

# Copy backend files
echo_info "Preparing backend files..."
cp -r backend "$TEMP_DIR/"

# Copy built frontend
echo_info "Preparing frontend files..."
cp -r frontend/dist "$TEMP_DIR/frontend/"

# Copy deployment files
echo_info "Preparing deployment configuration..."
cp -r deploy "$TEMP_DIR/"

# Create deployment directory on VPS
echo_step "Creating deployment directory on VPS..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo mkdir -p $DEPLOY_DIR && sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR"

# Upload files to VPS
echo_step "Uploading files to VPS..."
rsync -avz --delete -e "$SSH_CMD" "$TEMP_DIR/" $VPS_USER@$VPS_HOST:/tmp/hw_publishing_upload/

# Install backend dependencies on VPS
echo_step "Installing backend dependencies on VPS..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_upload/backend $DEPLOY_DIR/ &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend &&
    cd $DEPLOY_DIR/backend &&
    sudo -u $DEPLOY_USER npm install --production
"

# Deploy frontend
echo_step "Deploying frontend..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_upload/frontend $DEPLOY_DIR/ &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/frontend
"

# Copy environment file if it exists
echo_step "Checking for environment file..."
if [ -f "backend/.env" ]; then
    echo_info "Uploading environment file..."
    scp -o StrictHostKeyChecking=no backend/.env $VPS_USER@$VPS_HOST:/tmp/.env
    $SSH_CMD $VPS_USER@$VPS_HOST "
        sudo mv /tmp/.env $DEPLOY_DIR/backend/.env &&
        sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend/.env
    "
else
    echo_warn "No .env file found. Please create one on the VPS at $DEPLOY_DIR/backend/.env"
fi

# Install systemd service
echo_step "Installing systemd service..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp /tmp/hw_publishing_upload/deploy/backend.service /etc/systemd/system/$SERVICE_NAME.service &&
    sudo systemctl daemon-reload &&
    sudo systemctl enable $SERVICE_NAME
"

# Configure Nginx
echo_step "Configuring Nginx..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp /tmp/hw_publishing_upload/deploy/nginx.conf /etc/nginx/sites-available/$NGINX_SITE &&
    sudo ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/ &&
    sudo rm -f /etc/nginx/sites-enabled/default
"

# Test Nginx configuration
echo_step "Testing Nginx configuration..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo nginx -t"

# Start services
echo_step "Starting services..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo systemctl start $SERVICE_NAME &&
    sudo systemctl reload nginx
"

# Check service status
echo_step "Checking service status..."
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
echo_step "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
$SSH_CMD $VPS_USER@$VPS_HOST "sudo rm -rf /tmp/hw_publishing_upload"

echo_info "Remote deployment completed!"
echo_info "Your application should be accessible at: http://$VPS_HOST"
echo_info "Backend API is available at: http://$VPS_HOST/api/"
echo_warn "Don't forget to:"
echo_warn "1. Update the domain name in /etc/nginx/sites-available/$NGINX_SITE on the VPS"
echo_warn "2. Set up SSL certificates for HTTPS"
echo_warn "3. Configure your environment variables in $DEPLOY_DIR/backend/.env on the VPS"
