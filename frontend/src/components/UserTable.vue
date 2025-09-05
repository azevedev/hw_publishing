<template>
    <div class="container mx-auto">
      <div class="overflow-x-auto">
        <table class="table table-zebra w-full">
          <!-- head -->
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <!-- row for each user -->
            <tr v-for="user in users" :key="user.id">
              <th>{{ user.id }}</th>
              <td>{{ user.name }}</td>
              <td>{{ user.email }}</td>
              <td>
                <span class="badge badge-outline">{{ user.role }}</span>
              </td>
              <td>
                <button class="btn btn-sm btn-primary mr-2">View</button>
                <button class="btn btn-sm btn-secondary">Edit</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- loading state -->
      <div v-if="loading" class="text-center mt-8">
        <span class="loading loading-spinner loading-lg"></span>
        <p>Loading users...</p>
      </div>
      
      <!-- error state -->
      <div v-if="error" class="alert alert-error mt-8">
        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
        <span>Error: {{ error }}</span>
      </div>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  
  export default {
    name: 'UserTable',
    data() {
      return {
        users: [],
        loading: true,
        error: null
      }
    },
    async mounted() {
      try {
        const response = await axios.get('/api/users');
        this.users = response.data;
      } catch (err) {
        this.error = err.message;
        console.error('Error fetching users:', err);
      } finally {
        this.loading = false;
      }
    }
  }
  </script>