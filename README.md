# User Management Full-Stack Application

A full-stack application built with Node.js/Express, Supabase, and Vue.js that demonstrates secure data handling, encryption/decryption, and responsive UI design.

## 🚀 Technologies Used

### Backend
- **Node.js** with Express.js framework
- **Supabase** as the database and backend service
- **AES-256-GCM** for data encryption/decryption
- **CORS** configured for production domains

### Frontend
- **Vue.js 3** with Composition API
- **Tailwind CSS** for styling
- **DaisyUI** component library (loaded via CDN)
- **Axios** for HTTP requests
- **Responsive design** with dark/light theme support

## 📋 Prerequisites

Before running this application, ensure you have installed:
- Node.js (v20 or higher)
- Supabase account and project
- npm or yarn package manager

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd user-management-app
```

### 2. Backend Setup
```bash
# Install dependencies
cd backend
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your actual values
```

### 3. Supabase Setup
1. **Create a Supabase project** at [supabase.com](https://supabase.com)
2. **Create the users table** in the SQL editor:
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(128) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL
);
```
3. **Get your project URL and API key** from Project Settings > API

### 4. Environment Configuration
Create environment files for both frontend and backend with the required variables (see Environment Variables section below).

### 5. Frontend Setup
```bash
cd frontend
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your API endpoints
```

## ⚙️ Environment Variables

### Backend (.env)
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key
ENCRYPTED_DATA_URL=https://n8n-apps.nlabshealth.com/webhook/data-5dYbrVSlMVJxfmco
DECRYPTION_KEY=your_decryption_key
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/users
PORT=3001
```

### Frontend (.env)
```env
# No environment variables needed for frontend
# API URL is automatically determined based on environment
# Development: http://localhost:3001/api
# Production: https://hw-api.azevedev.com/api
```

## 🔌 API Endpoints

### Backend API (Express)
- `GET /api/users` - Fetch all users from Supabase database
- `POST /api/execute` - Execute the workflow (fetch encrypted data, decrypt, send to N8N)
- `POST /api/clear` - Clear all users from database via N8N webhook

## 📊 Database Schema

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(128) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL
);
```

*Note: This table is created in Supabase, not a local PostgreSQL instance.*

## 🚀 Running the Application

### 1. Ensure Supabase is configured
Make sure your Supabase project is set up and environment variables are configured.

### 2. Start the Backend
```bash
cd backend
npm run dev
```

### 3. Start the Frontend
```bash
cd frontend
npm run dev
```

The application will be available at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- Production Frontend: https://hw.azevedev.com
- Production API: https://hw-api.azevedev.com

## 🌐 Production Deployment

This application is deployed on a VPS using a complete infrastructure setup. Here's the step-by-step deployment process:

### 1. Cloudflare Configuration & Domain Setup

First, configure your domain with Cloudflare:

1. **Add your domain to Cloudflare**
   - Add `hw.azevedev.com` and `www.hw.azevedev.com` to your Cloudflare account
   - Set DNS records to point to your VPS IP address (e.g., `168.75.108.27`)
   - Enable SSL/TLS encryption mode to "Full (strict)"

2. **Configure DNS Records**
   ```
   Type: A
   Name: hw.azevedev.com
   Content: 168.75.108.27
   Proxy status: Proxied (orange cloud)
   
   Type: A  
   Name: www.hw.azevedev.com
   Content: 168.75.108.27
   Proxy status: Proxied (orange cloud)
   ```

### 2. VPS Setup & SSH Key Configuration

1. **Set up SSH access for GitHub**
   ```bash
   # Generate SSH key pair on VPS
   ssh-keygen -t ed25519 -C "your-email@example.com"
   
   # Add public key to GitHub
   cat ~/.ssh/id_ed25519.pub
   # Copy and add to GitHub Settings > SSH and GPG keys
   
   # Test SSH connection
   ssh -T git@github.com
   ```

2. **Clone repository on VPS**
   ```bash
   git clone git@github.com:yourusername/hw_publishing.git
   cd hw_publishing
   ```

### 3. Frontend Build Configuration

1. **Install Node.js and dependencies**
   ```bash
   # Install Node.js (v20+)
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Install frontend dependencies
   cd frontend
   npm install
   ```

2. **Build the frontend for production**
   ```bash
   # Build the Vue.js application
   npm run build
   
   # This creates the dist/ folder with optimized static files
   ```

3. **Set up directory structure**
   ```bash
   # Create web directory
   sudo mkdir -p /var/www/hw_publishing/frontend
   
   # Copy built files
   sudo cp -r dist/* /var/www/hw_publishing/frontend/
   
   # Set proper permissions
   sudo chown -R www-data:www-data /var/www/hw_publishing/
   sudo chmod -R 755 /var/www/hw_publishing/
   ```

### 4. Backend PM2 Configuration

1. **Install PM2 globally**
   ```bash
   sudo npm install -g pm2
   ```

2. **Set up backend environment**
   ```bash
   cd backend
   npm install
   
   # Create production environment file
   cp .env.example .env
   # Edit .env with production values
   ```

3. **Configure PM2 ecosystem**
   The `ecosystem.config.js` file is already configured with:
   ```javascript
   module.exports = {
     apps: [{
       name: 'backend',
       script: 'server.js',
       instances: 1,
       autorestart: true,
       watch: true,
       max_memory_restart: '1G',
       env: {
         NODE_ENV: 'production'
       }
     }]
   };
   ```

4. **Start the backend with PM2**
   ```bash
   # Start the application
   pm2 start ecosystem.config.js
   
   # Save PM2 configuration
   pm2 save
   
   # Set up PM2 to start on boot
   pm2 startup
   # Follow the instructions provided by the command
   ```

### 5. Caddy Web Server & SSL Configuration

1. **Install Caddy**
   ```bash
   # Add Caddy repository
   sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   
   # Install Caddy
   sudo apt update
   sudo apt install caddy
   ```

2. **Configure Caddyfile**
   The `Caddyfile` is already configured with:
   ```
   hw.azevedev.com, www.hw.azevedev.com {
       root * /var/www/hw_publishing/frontend/dist
       file_server
       try_files {path} /index.html
       
       handle_path /api/* {
           remote_ip 168.75.108.27 127.0.0.1 ::1
           reverse_proxy localhost:3001 {
               header_up Host {host}
               header_up X-Real-IP {remote}
               header_up X-Forwarded-For {remote}
               header_up X-Forwarded-Proto {scheme}
           }
       }
   }
   ```

3. **Start Caddy and enable SSL**
   ```bash
   # Copy Caddyfile to Caddy directory
   sudo cp Caddyfile /etc/caddy/
   
   # Test configuration
   sudo caddy validate --config /etc/caddy/Caddyfile
   
   # Start Caddy service
   sudo systemctl start caddy
   sudo systemctl enable caddy
   
   # Check status
   sudo systemctl status caddy
   ```

### 6. Reverse Proxy Configuration

The reverse proxy is configured in the Caddyfile to:

1. **Serve static frontend files** from `/var/www/hw_publishing/frontend/dist`
2. **Handle API routes** (`/api/*`) by proxying to the Node.js backend on `localhost:3001`
3. **Implement IP restrictions** for API access (only allowing VPS IP and localhost)
4. **Add proper headers** for backend communication

### 7. Database Setup (Production)

1. **Supabase Configuration**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Create the users table in the SQL editor:
   ```sql
   CREATE TABLE users (
       id SERIAL PRIMARY KEY,
       nome VARCHAR(128) NOT NULL,
       email VARCHAR(255) UNIQUE NOT NULL,
       phone VARCHAR(20) NOT NULL
   );
   ```

2. **Update backend environment variables**
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your_supabase_anon_key
   NODE_ENV=production
   PORT=3001
   ```

### 8. Deployment Commands Summary

```bash
# 1. Clone and setup
git clone git@github.com:yourusername/hw_publishing.git
cd hw_publishing

# 2. Build frontend
cd frontend && npm install && npm run build
sudo cp -r dist/* /var/www/hw_publishing/frontend/

# 3. Setup backend
cd ../backend && npm install
pm2 start ecosystem.config.js
pm2 save

# 4. Configure Caddy
sudo cp Caddyfile /etc/caddy/
sudo systemctl restart caddy

# 5. Verify deployment
pm2 status
sudo systemctl status caddy
curl -I https://hw.azevedev.com
```

### 9. Monitoring & Maintenance

```bash
# Check PM2 processes
pm2 status
pm2 logs backend

# Check Caddy status
sudo systemctl status caddy
sudo journalctl -u caddy -f

# Check SSL certificate
sudo caddy list-certificates

# Restart services
pm2 restart backend
sudo systemctl restart caddy
```

### 10. Environment Variables (Production)

**Backend (.env)**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key
ENCRYPTED_DATA_URL=https://n8n-apps.nlabshealth.com/webhook/data-5dYbrVSlMVJxfmco
DECRYPTION_KEY=your_decryption_key
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook/users
PORT=3001
NODE_ENV=production
```

**Frontend (build-time)**
```env
# No environment variables needed for frontend
# API URL is automatically determined based on environment
# Development: http://localhost:3001/api
# Production: https://hw-api.azevedev.com/api
```

### 11. Security Considerations

- SSL certificates are automatically managed by Caddy
- API access is restricted by IP address
- Environment variables are properly secured
- Database credentials are stored securely
- PM2 provides process monitoring and auto-restart
- Caddy handles HTTPS redirection and security headers

## 🎯 Usage

1. Open the application in your browser
2. Click "Executar" to:
   - Fetch encrypted data from the external endpoint
   - Decrypt using AES-256-GCM encryption
   - Send decrypted data to N8N webhook for processing
   - Store processed data in Supabase
   - Display results in the frontend table

3. Click "Limpar" to:
   - Clear the frontend table
   - Truncate the database table via N8N webhook

## 🔒 Security Features

- AES-256-GCM encryption/decryption
- Secure environment variable management
- Supabase Row Level Security (RLS)
- CORS configuration for production domains
- IP-based API access restrictions in production

## 📱 Responsive Design

The application features a fully responsive design that works on:
- Desktop computers
- Tablets
- Mobile devices

Using Tailwind CSS and DaisyUI components (loaded via CDN) ensures consistent styling across all screen sizes, with built-in dark/light theme support.

## 🧪 Testing

Run the test suite with:
```bash
# Backend tests
cd backend
npm test

# Frontend tests
cd frontend
npm test
```

## 📄 License

This project is created as part of a technical assessment.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📞 Support

For questions about this application, please contact the development team.
