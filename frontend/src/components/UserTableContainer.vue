<template>
  <div class="container mx-auto px-4 py-8 bg-gradient-to-br from-slate-50 to-slate-100 min-h-screen">
    <!-- Header -->
    <div class="text-center mb-8">
      <h1 class="text-3xl font-bold text-slate-800 mb-2">Sistema de Usuários</h1>
      <p class="text-slate-600">Gerencie e visualize dados de usuários</p>
    </div>

    <!-- Action Buttons -->
    <ActionButtons 
      :loading="loading" 
      @execute="executeProcess" 
      @clear="clearData" 
    />

    <!-- Error Message -->
    <div v-if="error" class="alert alert-error bg-rose-100 border-rose-300 text-rose-800 mb-6">
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
      </svg>
      <span>{{ error }}</span>
    </div>

    <!-- User Table -->
    <UserTableDisplay 
      :users="paginatedUsers" 
      :loading="loading" 
    />

    <!-- Pagination -->
    <Pagination
      v-if="users.length > 0"
      :current-page="currentPage"
      :total-pages="totalPages"
      :total-items="users.length"
      :items-per-page="itemsPerPage"
      @page-change="handlePageChange"
      @page-size-change="handlePageSizeChange"
    />

    <!-- Loading Overlay -->
    <div v-if="loading" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 text-center shadow-xl">
        <div class="loading loading-spinner loading-lg text-emerald-500 mb-4"></div>
        <p class="text-slate-700 font-medium">Processando...</p>
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
  name: 'UserTableContainer',
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
        await api.post('/execute');
        // Refresh the user data
        await this.fetchUsers();
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
