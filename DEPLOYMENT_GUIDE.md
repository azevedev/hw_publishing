# Vue.js App Deployment Guide for Linux VPS

This guide will walk you through deploying your Vue.js application on a Linux VPS using Nginx as a reverse proxy and PM2 for process management.

## Prerequisites

- A Linux VPS (Ubuntu 20.04+ recommended)
- Root or sudo access to the VPS
- Domain name pointing to your VPS (optional but recommended)
- SSH access to your VPS

## Step 1: Prepare Your Local Environment

### 1.1 Build the Production Version
```bash
cd /home/matheus/dev/hw_publishing/frontend
npm run build
```

This will create a `dist` folder with optimized production files.

### 1.2 Test the Production Build Locally
```bash
npm run preview
```

Visit `http://localhost:4173` to ensure everything works correctly.

## Step 2: VPS Setup

### 2.1 Connect to Your VPS
```bash
ssh root@your-vps-ip
# or
ssh username@your-vps-ip
```

### 2.2 Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
```

### 2.3 Install Node.js (Version 20+)
```bash
# Install Node.js using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### 2.4 Install Nginx
```bash
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 2.5 Install PM2 (Process Manager)
```bash
sudo npm install -g pm2
```

### 2.6 Install Git (if not already installed)
```bash
sudo apt install git -y
```

## Step 3: Deploy Your Application

### 3.1 Create Application Directory
```bash
sudo mkdir -p /var/www/your-app-name
sudo chown -R $USER:$USER /var/www/your-app-name
```

### 3.2 Upload Your Application

#### Option A: Using Git (Recommended)
```bash
cd /var/www/your-app-name
git clone https://github.com/your-username/your-repo.git .
```

#### Option B: Using SCP/SFTP
From your local machine:
```bash
scp -r /home/matheus/dev/hw_publishing/frontend/* username@your-vps-ip:/var/www/your-app-name/
```

### 3.3 Install Dependencies and Build
```bash
cd /var/www/your-app-name
npm install
npm run build
```

## Step 4: Configure Nginx

### 4.1 Create Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/your-app-name
```

Add the following configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;  # Replace with your domain or IP
    
    root /var/www/your-app-name/dist;
    index index.html;
    
    # Handle Vue.js routing (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
```

### 4.2 Enable the Site
```bash
sudo ln -s /etc/nginx/sites-available/your-app-name /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

## Step 5: SSL Certificate (Optional but Recommended)

### 5.1 Install Certbot
```bash
sudo apt install certbot python3-certbot-nginx -y
```

### 5.2 Obtain SSL Certificate
```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

## Step 6: Configure Backend API (If Applicable)

Since your Vite config shows a proxy to `localhost:3001`, you'll need to deploy your backend as well:

### 6.1 Deploy Backend Application
```bash
# Create backend directory
sudo mkdir -p /var/www/your-backend
sudo chown -R $USER:$USER /var/www/your-backend

# Upload and setup backend
cd /var/www/your-backend
# ... deploy your backend code here
npm install
```

### 6.2 Create PM2 Ecosystem File
Create `ecosystem.config.js` in your backend directory:
```javascript
module.exports = {
  apps: [{
    name: 'your-backend',
    script: 'app.js', // or your main backend file
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    }
  }]
}
```

### 6.3 Start Backend with PM2
```bash
cd /var/www/your-backend
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### 6.4 Update Nginx Configuration for API
Add to your Nginx config:
```nginx
# API proxy
location /api {
    proxy_pass http://localhost:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}
```

## Step 7: Environment Configuration

### 7.1 Update Vite Configuration for Production
Update your `vite.config.js` to handle production builds:
```javascript
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

export default defineConfig({
  plugins: [
    vue(),
    // Only include devtools in development
    process.env.NODE_ENV === 'development' ? vueDevTools() : null,
  ].filter(Boolean),
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: process.env.NODE_ENV === 'production' 
          ? 'http://your-domain.com' 
          : 'http://localhost:3001',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser'
  }
})
```

## Step 8: Firewall Configuration

### 8.1 Configure UFW (Ubuntu Firewall)
```bash
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## Step 9: Monitoring and Maintenance

### 9.1 Set up Log Rotation
```bash
sudo nano /etc/logrotate.d/your-app
```

Add:
```
/var/www/your-app-name/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
}
```

### 9.2 Monitor Application
```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs your-backend

# Monitor system resources
pm2 monit
```

## Step 10: Automated Deployment Script

Create a deployment script `deploy.sh`:
```bash
#!/bin/bash

# Configuration
APP_DIR="/var/www/your-app-name"
BACKUP_DIR="/var/backups/your-app"

# Create backup
echo "Creating backup..."
sudo mkdir -p $BACKUP_DIR
sudo cp -r $APP_DIR $BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S)

# Pull latest changes
echo "Pulling latest changes..."
cd $APP_DIR
git pull origin main

# Install dependencies and build
echo "Installing dependencies..."
npm install
npm run build

# Restart services
echo "Restarting services..."
pm2 restart your-backend
sudo systemctl reload nginx

echo "Deployment completed!"
```

Make it executable:
```bash
chmod +x deploy.sh
```

## Troubleshooting

### Common Issues:

1. **502 Bad Gateway**: Check if your backend is running on the correct port
2. **404 on refresh**: Ensure Nginx is configured with `try_files` for SPA routing
3. **Permission issues**: Check file ownership with `ls -la /var/www/your-app-name`
4. **Build failures**: Ensure Node.js version matches your `package.json` engines

### Useful Commands:
```bash
# Check Nginx status
sudo systemctl status nginx

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Check PM2 logs
pm2 logs

# Restart services
sudo systemctl restart nginx
pm2 restart all
```

## Security Considerations

1. **Keep system updated**: `sudo apt update && sudo apt upgrade`
2. **Use strong passwords**: For SSH and database access
3. **Configure fail2ban**: `sudo apt install fail2ban`
4. **Regular backups**: Set up automated backups
5. **Monitor logs**: Regularly check application and system logs

## Performance Optimization

1. **Enable Gzip compression** in Nginx
2. **Use CDN** for static assets
3. **Implement caching strategies**
4. **Monitor resource usage** with PM2 monit
5. **Optimize images** and assets

Your Vue.js application should now be successfully deployed and accessible via your domain or VPS IP address!
