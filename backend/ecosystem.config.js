module.exports = {
    apps: [{
      name: 'backend',
      script: 'server.js',
      instances: 1,
      autorestart: true,
      watch: true,  // This enables watching for changes
      ignore_watch: [
        'node_modules',
        'logs',
        '.git',
        '*.log'
      ],
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production'
      }
    }]
  };