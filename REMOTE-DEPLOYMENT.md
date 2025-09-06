# HW Publishing - Remote Deployment Guide

This guide allows you to deploy your application to a VPS entirely from your local machine without manually SSHing into the server.

## 🚀 Quick Start

### 1. **Configure Your VPS Details**

Edit the configuration in the remote scripts:

```bash
# Edit remote-setup.sh
nano deploy/remote-setup.sh

# Edit remote-deploy.sh  
nano deploy/remote-deploy.sh

# Edit remote-update.sh
nano deploy/remote-update.sh
```

Update these variables in each script:
```bash
VPS_HOST="your-vps-ip-or-domain"  # e.g., "192.168.1.100" or "myserver.com"
VPS_USER="your-username"          # e.g., "ubuntu" or "root"
VPS_SSH_KEY=""                    # Path to SSH key (optional)
```

### 2. **Prepare Your VPS (One-time setup)**

```bash
./deploy/remote-setup.sh
```

This will:
- Update system packages
- Install Node.js, Nginx, Git, Certbot
- Configure firewall
- Start services

### 3. **Deploy Your Application**

```bash
./deploy/remote-deploy.sh
```

This will:
- Build frontend locally
- Upload all files to VPS
- Install dependencies
- Configure services
- Start the application

### 4. **Update Your Application (for future changes)**

```bash
./deploy/remote-update.sh
```

## 📋 Prerequisites

### Local Machine Requirements
- Node.js 18+ installed
- SSH access to your VPS
- rsync installed (usually pre-installed)

### VPS Requirements
- Ubuntu 20.04+ or similar Linux distribution
- SSH access with sudo privileges
- At least 1GB RAM, 10GB disk space

## 🔧 Configuration Options

### SSH Authentication

**Option 1: SSH Key (Recommended)**
```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Copy key to VPS
ssh-copy-id your-username@your-vps-ip

# Update script with key path
VPS_SSH_KEY="/home/your-user/.ssh/id_rsa"
```

**Option 2: Password Authentication**
```bash
# Leave VPS_SSH_KEY empty
VPS_SSH_KEY=""
```

### Environment Variables

Create your environment file locally:
```bash
cp deploy/env.example backend/.env
nano backend/.env
```

The deployment script will automatically upload this file to the VPS.

## 🛠️ Script Details

### `remote-setup.sh`
- **Purpose**: One-time VPS preparation
- **What it does**: Installs all required software and configures the system
- **When to run**: Only once, when setting up a new VPS

### `remote-deploy.sh`
- **Purpose**: Full application deployment
- **What it does**: Builds frontend, uploads files, configures services
- **When to run**: Initial deployment or major changes

### `remote-update.sh`
- **Purpose**: Quick application updates
- **What it does**: Updates code without full reconfiguration
- **When to run**: For code changes and updates

## 🔍 Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection manually
ssh your-username@your-vps-ip

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### Deployment Issues

```bash
# Check VPS logs remotely
ssh your-username@your-vps-ip "sudo journalctl -u hw-publishing-backend -f"

# Check Nginx status
ssh your-username@your-vps-ip "sudo systemctl status nginx"

# Test Nginx configuration
ssh your-username@your-vps-ip "sudo nginx -t"
```

### File Permission Issues

```bash
# Fix permissions remotely
ssh your-username@your-vps-ip "
    sudo chown -R www-data:www-data /var/www/hw_publishing &&
    sudo chmod -R 755 /var/www/hw_publishing
"
```

## 🔒 Security Features

- **SSH Key Authentication**: Secure, passwordless access
- **Firewall Configuration**: Only necessary ports open (22, 80, 443)
- **Process Isolation**: Backend runs as www-data user
- **SSL Ready**: Easy Certbot integration

## 📊 Monitoring

### Check Application Status

```bash
# Check if services are running
ssh your-username@your-vps-ip "
    echo 'Backend:' \$(sudo systemctl is-active hw-publishing-backend) &&
    echo 'Nginx:' \$(sudo systemctl is-active nginx)
"

# View application logs
ssh your-username@your-vps-ip "sudo journalctl -u hw-publishing-backend --since '1 hour ago'"
```

### Health Check

```bash
# Test application endpoints
curl http://your-vps-ip/health
curl http://your-vps-ip/api/users
```

## 🔄 Workflow Examples

### Initial Deployment
```bash
# 1. Configure scripts with your VPS details
nano deploy/remote-setup.sh
nano deploy/remote-deploy.sh

# 2. Set up environment variables
cp deploy/env.example backend/.env
nano backend/.env

# 3. Prepare VPS
./deploy/remote-setup.sh

# 4. Deploy application
./deploy/remote-deploy.sh
```

### Regular Updates
```bash
# 1. Make code changes locally
# 2. Update environment if needed
nano backend/.env

# 3. Deploy updates
./deploy/remote-update.sh
```

### SSL Setup (After deployment)
```bash
# Set up SSL certificates
ssh your-username@your-vps-ip "sudo certbot --nginx -d your-domain.com"

# Update Nginx config with your domain
ssh your-username@your-vps-ip "sudo nano /etc/nginx/sites-available/hw-publishing"
```

## 🎯 Benefits of Remote Deployment

1. **No Manual SSH**: Everything automated from your local machine
2. **Consistent Deployments**: Same process every time
3. **Local Building**: Frontend built locally, faster uploads
4. **Easy Updates**: One command to update your application
5. **Version Control**: All deployment logic in your repository

## 📝 Notes

- The scripts use `rsync` for efficient file transfers
- Frontend is built locally to avoid Node.js installation issues on VPS
- All temporary files are cleaned up automatically
- Scripts include comprehensive error checking and status reporting
- SSH connections are tested before deployment starts

## 🆘 Support

If you encounter issues:
1. Check SSH connectivity first
2. Verify VPS has required software installed
3. Check file permissions on VPS
4. Review application logs for specific errors
