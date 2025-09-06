
#!/bin/bash

# HW Publishing Deployment Script
# This script deploys both frontend and backend to a VPS

set -e  # Exit on any error

# Configuration
APP_NAME="hw_publishing"
DEPLOY_USER="www-data"
DEPLOY_DIR="/var/www/$APP_NAME"
SERVICE_NAME="hw-publishing-backend"
NGINX_SITE="hw-publishing"

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo_error "This script should not be run as root. Please run as a regular user with sudo privileges."
   exit 1
fi

# Check if required commands exist
command -v node >/dev/null 2>&1 || { echo_error "Node.js is required but not installed. Aborting."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo_error "npm is required but not installed. Aborting."; exit 1; }
command -v nginx >/dev/null 2>&1 || { echo_warn "Nginx not found. You may need to install it."; }

echo_info "Starting deployment of HW Publishing application..."

# Create deployment directory
echo_info "Creating deployment directory..."
sudo mkdir -p $DEPLOY_DIR
sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR

# Deploy backend
echo_info "Deploying backend..."
sudo cp -r backend $DEPLOY_DIR/
sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend

# Install backend dependencies
echo_info "Installing backend dependencies..."
cd $DEPLOY_DIR/backend
sudo -u $DEPLOY_USER npm install --production

# Deploy frontend
echo_info "Building and deploying frontend..."
cd /home/$USER/dev/$APP_NAME/frontend

# Build frontend for production
echo_info "Building frontend for production..."
npm run build

# Copy built frontend to deployment directory
sudo cp -r dist $DEPLOY_DIR/frontend/
sudo chown -R $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/frontend

# Copy environment file if it exists
if [ -f "backend/.env" ]; then
    echo_info "Copying environment file..."
    sudo cp backend/.env $DEPLOY_DIR/backend/
    sudo chown $DEPLOY_USER:$DEPLOY_USER $DEPLOY_DIR/backend/.env
else
    echo_warn "No .env file found. Please create one in $DEPLOY_DIR/backend/.env"
fi

# Install systemd service
echo_info "Installing systemd service..."
sudo cp deploy/backend.service /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

# Configure Nginx
echo_info "Configuring Nginx..."
sudo cp deploy/nginx.conf /etc/nginx/sites-available/$NGINX_SITE
sudo ln -sf /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/

# Remove default Nginx site if it exists
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration
echo_info "Testing Nginx configuration..."
sudo nginx -t

# Start services
echo_info "Starting services..."
sudo systemctl start $SERVICE_NAME
sudo systemctl reload nginx

# Check service status
echo_info "Checking service status..."
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    echo_info "Backend service is running successfully!"
else
    echo_error "Backend service failed to start. Check logs with: sudo journalctl -u $SERVICE_NAME -f"
fi

if sudo systemctl is-active --quiet nginx; then
    echo_info "Nginx is running successfully!"
else
    echo_error "Nginx failed to start. Check logs with: sudo journalctl -u nginx -f"
fi

echo_info "Deployment completed!"
echo_info "Your application should be accessible at: http://your-domain.com"
echo_info "Backend API is available at: http://your-domain.com/api/"
echo_warn "Don't forget to:"
echo_warn "1. Update the domain name in /etc/nginx/sites-available/$NGINX_SITE"
echo_warn "2. Set up SSL certificates for HTTPS"
echo_warn "3. Configure your environment variables in $DEPLOY_DIR/backend/.env"
