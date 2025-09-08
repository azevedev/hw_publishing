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
          :users-length="users.length"
          :loading="loading" 
        />
      </div>
  
      <!-- Pagination -->
      <div v-if="users.length > 0" class="mt-14">
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

      <!-- Toast Notifications -->
      <div v-if="toastVisible" class="toast toast-top z-50 overflow-hidden" @mouseenter="pauseToast" @mouseleave="resumeToast">
        <div class="z-50 px-4 pt-6 pb-3" :class="['alert', toastType === 'success' ? 'alert-success' : 'alert-error']">
            <!-- close button -->
            <button class="btn btn-sm btn-circle btn-ghost absolute top-1 right-1 w-6 h-6" @click="closeToast">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
            </button>
            <span class="mb-2">{{ toastMessage }}</span>
            <div class="w-full absolute bottom-0 left-0">
                <div class="h-2 w-full bg-base-300 ">
                <div
                    class="h-2"
                    :class="toastType === 'success' ? 'bg-success-content' : 'bg-error-content'"
                    :style="{ width: toastProgress + '%', transition: 'width 50ms linear' }"
                ></div>
                </div>
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
        itemsPerPage: 10,
        toastVisible: false,
        toastMessage: '',
        toastType: 'success',
        toastTimeoutId: null,
        toastIntervalId: null,
        toastDurationMs: 3000,
        toastRemainingMs: 0,
        toastStartTs: 0,
        toastProgress: 100
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
      showToast(message, type = 'success') {
        this.toastMessage = message
        this.toastType = type
        this.toastVisible = true

        // reset timers/progress
        clearTimeout(this.toastTimeoutId)
        this.toastTimeoutId = null
        clearInterval(this.toastIntervalId)
        this.toastIntervalId = null

        this.toastRemainingMs = this.toastDurationMs
        this.toastProgress = 100
        this.toastStartTs = Date.now()

        // schedule auto-close and progress updates
        this.toastTimeoutId = setTimeout(() => {
          this.toastVisible = false
          this.clearToastTimers()
        }, this.toastRemainingMs)

        this.toastIntervalId = setInterval(() => {
          const elapsed = Date.now() - this.toastStartTs
          const left = Math.max(this.toastRemainingMs - elapsed, 0)
          this.toastProgress = (left / this.toastDurationMs) * 100
          if (left <= 0) {
            this.toastProgress = 0
            this.clearToastTimers()
          }
        }, 50)
      },

      pauseToast() {
        if (!this.toastVisible) return
        const elapsed = Date.now() - this.toastStartTs
        this.toastRemainingMs = Math.max(this.toastRemainingMs - elapsed, 0)
        clearTimeout(this.toastTimeoutId)
        this.toastTimeoutId = null
        clearInterval(this.toastIntervalId)
        this.toastIntervalId = null
      },

      resumeToast() {
        if (!this.toastVisible || this.toastRemainingMs <= 0) return
        this.toastStartTs = Date.now()
        clearTimeout(this.toastTimeoutId)
        clearInterval(this.toastIntervalId)

        this.toastTimeoutId = setTimeout(() => {
          this.toastVisible = false
          this.clearToastTimers()
        }, this.toastRemainingMs)

        this.toastIntervalId = setInterval(() => {
          const elapsed = Date.now() - this.toastStartTs
          const left = Math.max(this.toastRemainingMs - elapsed, 0)
          this.toastProgress = (left / this.toastDurationMs) * 100
          if (left <= 0) {
            this.toastProgress = 0
            this.clearToastTimers()
          }
        }, 50)
      },

      clearToastTimers() {
        clearTimeout(this.toastTimeoutId)
        this.toastTimeoutId = null
        clearInterval(this.toastIntervalId)
        this.toastIntervalId = null
      },

      closeToast() {
        this.toastVisible = false
        this.toastTimeoutId = null
      },

      async executeProcess() {
        this.loading = true;
        this.error = null;
        
        try {
          const response = await api.post('/execute');
          // Refresh the user data
          this.users = response.data.decryptedData ?? [];
          this.showToast('Processo executado com sucesso', 'success')
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error executing process:', err);
          this.showToast('Algo deu errado ao executar o processo', 'error')
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
          this.showToast('Dados limpos com sucesso', 'success')
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error clearing data:', err);
          this.showToast('Algo deu errado ao limpar os dados', 'error')
        } finally {
          this.loading = false;
        }
      },
      
      async fetchUsers() {
        this.loading = true;
        this.error = null;

        try {
          const response = await api.get('/users');
          this.users = response.data;
          this.currentPage = 1;
          this.showToast('Usuários carregados com sucesso', 'success')
        } catch (err) {
          this.error = err.response?.data?.error || err.message;
          console.error('Error fetching users:', err);
          this.showToast('Algo deu errado ao carregar usuários', 'error')
        } finally {
          this.loading = false;
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
  