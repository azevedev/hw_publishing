const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config();

const app = express();
const port = 3001;

app.use(cors({
    origin: ['https://hw.azevedev.com', 'https://www.hw.azevedev.com', 'https://hw-api.azevedev.com'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Sample user data
const users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Developer' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'Designer' },
  { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'Manager' },
  { id: 4, name: 'Alice Williams', email: 'alice@example.com', role: 'QA Engineer' },
  { id: 5, name: 'Charlie Brown', email: 'charlie@example.com', role: 'DevOps' }
];

const axios = require('axios');
const { decryptData } = require('./decryption');
const { supabase } = require('./db.js');

// Endpoint to fetch, decrypt and process data
app.post('/api/execute', async (req, res) => {
  try {
    // Fetch encrypted data from endpoint
    const response = await axios.get(process.env.ENCRYPTED_DATA_URL);
    console.log("Response from encrypted data:", response.data?.data?.encrypted ?? {});
    const encryptedData = response.data?.data?.encrypted ?? {};
    
    // Decrypt the data
    const decryptedData = decryptData(
      encryptedData.encrypted,
      'data-5dYbrVSlMVJxfmco',
      encryptedData.iv,
      encryptedData.authTag
    );
    
    // Send data to N8N webhook
    console.log("URL:", process.env.N8N_WEBHOOK_URL);
    await axios.post(process.env.N8N_WEBHOOK_URL, decryptedData);
    
    res.json({ success: true, message: 'Data processed successfully' });
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
    console.log("Supabase client:", supabase);
    const { data } = await supabase.from('users').select('*');
    console.log("Users from Supabase:", data);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, '127.0.0.1', () => {
    console.log('Backend running on port 3001 (localhost only)');
});