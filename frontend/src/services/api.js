import axios from 'axios';

// Determine the API base URL based on environment
const getBaseURL = () => {
  // In development, use localhost
  if (import.meta.env.DEV) {
    return 'http://localhost:3001/api';
  }
  
  // In production, use the same domain
  return '/api';
};

const api = axios.create({
  baseURL: getBaseURL(),
  timeout: 10000,
  withCredentials: true // Include credentials if needed
});

// Add request interceptor to include auth tokens if needed
api.interceptors.request.use(
  (config) => {
    // You can add auth tokens here if needed
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;