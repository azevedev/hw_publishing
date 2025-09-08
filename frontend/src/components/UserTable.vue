<template>
    <div class="space-y-8">
      <!-- Action Buttons -->
      <div class="flex justify-center">
        <ActionButtons 
          :loading="loading" 
          @execute="executeProcess" 
          @clear="clearData" 
        />
      </div>
  
      <!-- Error Message -->
      <div v-if="error" class="mx-auto max-w-4xl">
        <div class="alert alert-error">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <div>
            <h3 class="font-semibold">Erro no Sistema</h3>
            <p class="text-sm">{{ error }}</p>
          </div>
        </div>
      </div>
  
      <!-- User Table -->
      <div>
        <UserTableDisplay 
          :users="paginatedUsers" 
          :loading="loading" 
        />
      </div>
  
      <!-- Pagination -->
      <div v-if="users.length > 0" class="mt-18">
        <Pagination
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-items="users.length"
          :items-per-page="itemsPerPage"
          @page-change="handlePageChange"
          @page-size-change="handlePageSizeChange"
        />
      </div>
  
      <!-- Loading Overlay -->
      <div v-if="loading" class="fixed inset-0 bg-base-100/80 backdrop-blur-sm flex items-center justify-center z-50">
        <div class="bg-base-200 border border-base-300 rounded-2xl p-8 text-center shadow-2xl max-w-sm mx-4">
          <div class="relative">
            <div class="w-16 h-16 mx-auto mb-6">
              <div class="loading loading-spinner loading-lg text-primary"></div>
            </div>
            <h3 class="text-base-content font-semibold text-lg mb-2">Processando</h3>
            <p class="text-base-content/70 text-sm">Aguarde enquanto processamos sua solicitação...</p>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  import ActionButtons from './ActionButtons.vue';
  import UserTableDisplay from './UserTableDisplay.vue';
  import Pagination from './Pagination.vue';
  
  export default {
    name: 'UserTable',
    components: {
      ActionButtons,
      UserTableDisplay,
      Pagination
    },
    data() {
      return {
        users: [],
        loading: false,
        error: null,
        currentPage: 1,
        itemsPerPage: 10
      }
    },
    computed: {
      totalPages() {
        return Math.ceil(this.users.length / this.itemsPerPage);
      },
      paginatedUsers() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = start + this.itemsPerPage;
        return this.users.slice(start, end);
      }
    },
    methods: {
      async executeProcess() {
        this.loading = true;
        this.error = null;
        
        try {
          const response = await api.post('/execute');
          // Refresh the user data
          this.users = response.data.users ?? [];
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error executing process:', err);
        } finally {
          this.loading = false;
        }
      },
      
      async clearData() {
        this.loading = true;
        this.error = null;
        
        try {
          await api.post('/clear');
          this.users = [];
          this.currentPage = 1;
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error clearing data:', err);
        } finally {
          this.loading = false;
        }
      },
      
      async fetchUsers() {
        try {
          const response = await api.get('/users');
          console.log("Response from API:", response);
          this.users = response.data;
          this.currentPage = 1;
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error fetching users:', err);
        }
      },
  
      handlePageChange(page) {
        if (page >= 1 && page <= this.totalPages) {
          this.currentPage = page;
        }
      },
  
      handlePageSizeChange(newSize) {
        this.itemsPerPage = newSize;
        this.currentPage = 1;
      }
    },
    
    mounted() {
      this.fetchUsers();
    }
  }
  </script>
  