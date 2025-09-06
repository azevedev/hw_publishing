import axios from 'axios';
// using this work around because of the CORS policy and different ports
const api = axios.create({
  baseURL: 'http://localhost:3001/api',
  timeout: 10000,
});

export default api;