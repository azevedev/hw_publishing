#!/bin/bash

# HW Publishing Remote Update Script
# This script updates the deployed application on VPS from your local machine

set -e  # Exit on any error

# Configuration - UPDATE THESE VALUES
VPS_HOST="your-vps-ip-or-domain"  # e.g., "192.168.1.100" or "myserver.com"
VPS_USER="your-username"          # e.g., "ubuntu" or "root"
VPS_SSH_KEY=""                    # Path to SSH key (optional, leave empty for password auth)
APP_NAME="hw_publishing"
DEPLOY_USER="www-data"
DEPLOY_DIR="/var/www/$APP_NAME"
SERVICE_NAME="hw-publishing-backend"

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
    exit 1
fi

echo_info "SSH connection successful!"

echo_step "Starting remote update of HW Publishing application..."

# Check if required commands exist on local machine
command -v node >/dev/null 2>&1 || { echo_error "Node.js is required but not installed locally. Aborting."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo_error "npm is required but not installed locally. Aborting."; exit 1; }

# Build frontend locally
echo_info "Building frontend locally..."
cd frontend
npm run build
cd ..

# Create temporary deployment directory
TEMP_DIR="/tmp/hw_publishing_update_$(date +%s)"
echo_info "Creating temporary update directory: $TEMP_DIR"

# Copy backend files
echo_info "Preparing backend files..."
cp -r backend "$TEMP_DIR/"

# Copy built frontend
echo_info "Preparing frontend files..."
cp -r frontend/dist "$TEMP_DIR/frontend/"

# Upload files to VPS
echo_step "Uploading updated files to VPS..."
rsync -avz --delete -e "$SSH_CMD" "$TEMP_DIR/" $VPS_USER@$VPS_HOST:/tmp/hw_publishing_update/

# Update backend
echo_step "Updating backend..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_update/backend $DEPLOY_DIR/ &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend &&
    cd $DEPLOY_DIR/backend &&
    sudo -u $DEPLOY_USER npm install --production
"

# Update frontend
echo_step "Updating frontend..."
$SSH_CMD $VPS_USER@$VPS_HOST "
    sudo cp -r /tmp/hw_publishing_update/frontend $DEPLOY_DIR/ &&
    sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/frontend
"

# Update environment file if it exists locally
if [ -f "backend/.env" ]; then
    echo_info "Updating environment file..."
    scp -o StrictHostKeyChecking=no backend/.env $VPS_USER@$VPS_HOST:/tmp/.env
    $SSH_CMD $VPS_USER@$VPS_HOST "
        sudo mv /tmp/.env $DEPLOY_DIR/backend/.env &&
        sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend/.env
    "
fi

# Restart backend service
echo_step "Restarting backend service..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo systemctl restart $SERVICE_NAME"

# Reload Nginx
echo_step "Reloading Nginx..."
$SSH_CMD $VPS_USER@$VPS_HOST "sudo systemctl reload nginx"

# Check service status
echo_step "Checking service status..."
BACKEND_STATUS=$($SSH_CMD $VPS_USER@$VPS_HOST "sudo systemctl is-active $SERVICE_NAME" 2>/dev/null || echo "inactive")

if [ "$BACKEND_STATUS" = "active" ]; then
    echo_info "Backend service is running successfully!"
else
    echo_error "Backend service failed to start. Check logs with:"
    echo_error "$SSH_CMD $VPS_USER@$VPS_HOST 'sudo journalctl -u $SERVICE_NAME -f'"
fi

# Cleanup
echo_step "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
$SSH_CMD $VPS_USER@$VPS_HOST "sudo rm -rf /tmp/hw_publishing_update"

echo_info "Remote update completed!"
echo_info "Your application is now updated at: http://$VPS_HOST"
