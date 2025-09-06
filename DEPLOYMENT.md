# HW Publishing - VPS Deployment Guide

This guide will help you deploy both the frontend and backend applications to a single VPS with the frontend exposed to the web and the backend only accessible locally.

## Architecture Overview

```
Internet → Nginx (Port 80/443) → Frontend (Static Files)
                              → Backend API (localhost:3001)
```

- **Frontend**: Vue.js application served as static files by Nginx
- **Backend**: Node.js/Express API running on localhost:3001
- **Nginx**: Reverse proxy that serves frontend and proxies API calls to backend

## Prerequisites

### VPS Requirements
- Ubuntu 20.04+ or similar Linux distribution
- Root or sudo access
- At least 1GB RAM
- At least 10GB disk space

### Software Requirements
- Node.js 18+ (for building frontend and running backend)
- Nginx (web server and reverse proxy)
- Git (for code deployment)

## Installation Steps

### 1. Prepare Your VPS

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required software
sudo apt install -y nginx nodejs npm git

# Install PM2 for process management (optional but recommended)
sudo npm install -g pm2
```

### 2. Upload Your Code

Upload your project to the VPS. You can use:
- Git clone
- SCP/SFTP
- rsync

Example with Git:
```bash
git clone <your-repository-url> /home/your-user/hw_publishing
```

### 3. Configure Environment Variables

```bash
# Copy the example environment file
cp deploy/env.example backend/.env

# Edit the environment file with your actual values
nano backend/.env
```

Required environment variables:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `ENCRYPTED_DATA_URL`: URL to fetch encrypted data
- `N8N_WEBHOOK_URL`: Your N8N webhook URL

### 4. Run the Deployment Script

```bash
# Make sure you're in the project directory
cd /home/your-user/hw_publishing

# Run the deployment script
./deploy/deploy.sh
```

The deployment script will:
- Create deployment directories
- Install dependencies
- Build the frontend
- Set up systemd service for the backend
- Configure Nginx
- Start all services

### 5. Configure Your Domain

Edit the Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/hw-publishing
```

Replace `your-domain.com` with your actual domain name.

### 6. Set Up SSL (Recommended)

Install Certbot for free SSL certificates:
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Service Management

### Backend Service Commands

```bash
# Check service status
sudo systemctl status hw-publishing-backend

# Start service
sudo systemctl start hw-publishing-backend

# Stop service
sudo systemctl stop hw-publishing-backend

# Restart service
sudo systemctl restart hw-publishing-backend

# View logs
sudo journalctl -u hw-publishing-backend -f
```

### Nginx Commands

```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Updating Your Application

To update your application with new code:

```bash
# Pull latest changes (if using Git)
git pull origin main

# Run the update script
./deploy/update.sh
```

## File Structure After Deployment

```
/var/www/hw_publishing/
├── backend/                 # Backend application
│   ├── server.js
│   ├── package.json
│   ├── node_modules/
│   └── .env                 # Environment variables
└── frontend/                # Built frontend
    └── dist/                # Static files served by Nginx
        ├── index.html
        ├── assets/
        └── ...
```

## Security Considerations

1. **Firewall**: Configure UFW to only allow necessary ports:
   ```bash
   sudo ufw allow 22    # SSH
   sudo ufw allow 80    # HTTP
   sudo ufw allow 443   # HTTPS
   sudo ufw enable
   ```

2. **Environment Variables**: Never commit `.env` files to version control.

3. **SSL**: Always use HTTPS in production.

4. **Updates**: Keep your system and dependencies updated.

## Troubleshooting

### Backend Not Starting
```bash
# Check service logs
sudo journalctl -u hw-publishing-backend -f

# Check if port 3001 is in use
sudo netstat -tlnp | grep 3001
```

### Frontend Not Loading
```bash
# Check Nginx configuration
sudo nginx -t

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Verify frontend files exist
ls -la /var/www/hw_publishing/frontend/dist/
```

### API Calls Failing
- Verify backend is running on localhost:3001
- Check Nginx proxy configuration
- Verify CORS settings in backend

## Monitoring

### Health Check
Your application includes a health check endpoint:
- `http://your-domain.com/health`

### Log Monitoring
```bash
# Monitor all application logs
sudo journalctl -f

# Monitor specific service
sudo journalctl -u hw-publishing-backend -f
```

## Backup

Regular backups are recommended:
```bash
# Backup application files
sudo tar -czf hw_publishing_backup_$(date +%Y%m%d).tar.gz /var/www/hw_publishing

# Backup Nginx configuration
sudo cp -r /etc/nginx/sites-available /home/your-user/nginx_backup
```

## Performance Optimization

1. **Enable Gzip compression** in Nginx
2. **Set up caching** for static assets
3. **Use a CDN** for static files
4. **Monitor resource usage** with `htop` or similar tools

## Support

If you encounter issues:
1. Check the logs first
2. Verify all environment variables are set
3. Ensure all services are running
4. Check firewall and network connectivity
