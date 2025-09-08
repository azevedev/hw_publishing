module.exports = {
  apps: [{
    name: 'hw-publishing-backend',
    script: 'server.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3001
    },
    // Restart policy
    restart_delay: 4000,
    max_restarts: 10,
    min_uptime: '10s',
    
    // Logging
    log_file: '/var/log/pm2/hw-publishing-backend.log',
    out_file: '/var/log/pm2/hw-publishing-backend-out.log',
    error_file: '/var/log/pm2/hw-publishing-backend-error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    
    // Monitoring
    watch: false,
    ignore_watch: ['node_modules', 'logs'],
    
    // Memory management
    max_memory_restart: '1G'
  }]
}
