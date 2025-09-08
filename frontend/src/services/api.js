import axios from 'axios';

// Determine the API base URL based on environment
const getBaseURL = () => {
  // In development, use localhost
  if (import.meta.env.DEV) {
    return 'http://localhost:3001/api';
  }
  
  // In production, use the API subdomain
  return 'https://hw-api.azevedev.com/api';
};

const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 10000,
});

export default api;