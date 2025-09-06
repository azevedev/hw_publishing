#!/bin/bash

# HW Publishing Update Script
# This script updates the deployed application

set -e  # Exit on any error

# Configuration
APP_NAME="hw_publishing"
DEPLOY_USER="www-data"
DEPLOY_DIR="/var/www/$APP_NAME"
SERVICE_NAME="hw-publishing-backend"

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

echo_info "Starting update of HW Publishing application..."

# Update backend
echo_info "Updating backend..."
sudo cp -r backend $DEPLOY_DIR/
sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend

# Install/update backend dependencies
echo_info "Installing backend dependencies..."
cd $DEPLOY_DIR/backend
sudo -u $DEPLOY_USER npm install --production

# Update frontend
echo_info "Building and updating frontend..."
cd /home/$USER/dev/$APP_NAME/frontend

# Build frontend for production
echo_info "Building frontend for production..."
npm run build

# Copy built frontend to deployment directory
sudo cp -r dist $DEPLOY_DIR/frontend/
sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/frontend

# Restart backend service
echo_info "Restarting backend service..."
sudo systemctl restart $SERVICE_NAME

# Reload Nginx
echo_info "Reloading Nginx..."
sudo systemctl reload nginx

# Check service status
echo_info "Checking service status..."
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    echo_info "Backend service is running successfully!"
else
    echo_error "Backend service failed to start. Check logs with: sudo journalctl -u $SERVICE_NAME -f"
fi

echo_info "Update completed!"
