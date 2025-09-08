const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = 3001;

// CORS configuration, production and development
const corsOptions = {
    origin: ['https://hw.azevedev.com', 'https://www.hw.azevedev.com', 'https://hw-api.azevedev.com'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
};

if (process.env.NODE_ENV === 'development') {
    console.info('Development mode');
    corsOptions.origin = ['http://localhost:3000', 'http://localhost:3001'];
}

app.use(cors(corsOptions));
app.use(express.json());

// User data
const users = require('./users.json');

const axios = require('axios');
// const { decryptData } = require('./decryption');
const { supabase } = require('./db.js');

// Simple health check endpoint
app.get('/up', (req, res) => {
    res.sendStatus(200);
});

// Endpoint to fetch, decrypt and process data
app.post('/api/execute', async (req, res) => {
  try {
    // Fetch encrypted data from endpoint
    // const response = await axios.get(process.env.ENCRYPTED_DATA_URL);
    // const encryptedData = response.data?.data?.encrypted ?? {};
    
    // Skip decryption for now
    // Decrypt the data
    // const decryptedData = decryptData(
    //   encryptedData.encrypted,
    //   encryptedData.encription_key,
    //   encryptedData.iv,
    //   encryptedData.authTag
    // );
    
    // Send data to N8N webhook
    await axios.post(process.env.N8N_WEBHOOK_URL, {users: users} );
    
    res.json({ success: true, message: 'Data processed successfully', users });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint to clear data
app.post('/api/clear', async (req, res) => {
  try {
    // Call N8N truncate webhook, with DELETE method
    await axios.delete(process.env.N8N_WEBHOOK_URL);
    res.json({ success: true, message: 'Data cleared successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint to get users from database
app.get('/api/users', async (req, res) => {
  try {
    const { data } = await supabase.from('users').select('*');
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, '127.0.0.1', () => {
    console.info('Backend running on port 3001 (localhost only)');
});