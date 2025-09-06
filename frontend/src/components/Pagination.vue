<template>
  <div class="mt-6">
    <!-- Page Size Selector -->
    <div class="flex justify-center items-center mb-4 space-x-4">
      <div class="flex items-center space-x-2">
        <label class="text-sm font-medium text-slate-600">Itens por página:</label>
        <select 
          :value="itemsPerPage" 
          @change="$emit('page-size-change', parseInt($event.target.value))"
          class="select select-bordered select-sm bg-white border-slate-300 text-slate-700 focus:border-emerald-500 focus:ring-emerald-500"
        >
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="20">20</option>
          <option value="50">50</option>
        </select>
      </div>
    </div>

    <!-- Pagination Controls -->
    <div class="flex justify-center items-center space-x-3">
      <!-- Previous Button -->
      <button 
        @click="$emit('page-change', currentPage - 1)"
        :disabled="currentPage === 1"
        class="group flex items-center px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-lg hover:bg-slate-50 hover:border-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white disabled:hover:border-slate-300 transition-all duration-200"
      >
        <svg class="w-4 h-4 mr-2 group-hover:-translate-x-0.5 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
        Anterior
      </button>

      <!-- Page Numbers -->
      <div class="flex space-x-1">
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="$emit('page-change', page)"
          :class="[
            'flex items-center justify-center w-10 h-10 text-sm font-medium rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500',
            page === currentPage 
              ? 'bg-emerald-500 text-white border-emerald-500 shadow-lg shadow-emerald-200' 
              : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50 hover:border-slate-400 hover:shadow-sm'
          ]"
        >
          {{ page }}
        </button>
      </div>

      <!-- Next Button -->
      <button 
        @click="$emit('page-change', currentPage + 1)"
        :disabled="currentPage === totalPages"
        class="group flex items-center px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-lg hover:bg-slate-50 hover:border-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white disabled:hover:border-slate-300 transition-all duration-200"
      >
        Próximo
        <svg class="w-4 h-4 ml-2 group-hover:translate-x-0.5 transition-transform duration-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
        </svg>
      </button>

      <!-- Page Info -->
      <div class="ml-4 text-sm text-slate-600 bg-slate-50 px-4 py-2 rounded-lg border border-slate-200 font-medium">
        Página {{ currentPage }} de {{ totalPages }} ({{ totalItems }} itens)
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Pagination',
  props: {
    currentPage: {
      type: Number,
      required: true
    },
    totalPages: {
      type: Number,
      required: true
    },
    totalItems: {
      type: Number,
      required: true
    },
    itemsPerPage: {
      type: Number,
      required: true
    },
    maxVisiblePages: {
      type: Number,
      default: 5
    }
  },
  computed: {
    visiblePages() {
      const pages = [];
      
      if (this.totalPages <= this.maxVisiblePages) {
        for (let i = 1; i <= this.totalPages; i++) {
          pages.push(i);
        }
        return pages;
      }
      
      let start = Math.max(1, this.currentPage - Math.floor(this.maxVisiblePages / 2));
      let end = Math.min(this.totalPages, start + this.maxVisiblePages - 1);
      
      if (end === this.totalPages) {
        start = Math.max(1, this.totalPages - this.maxVisiblePages + 1);
      }
      
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
      
      return pages;
    }
  },
  emits: ['page-change', 'page-size-change']
}
</script>
