<template>
  <div class="bg-base-200 rounded-2xl border border-base-300 p-6 gap-6 relative flex md:flex-row flex-col justify-center items-center">
    <!-- Page Size Selector -->
    <div class="flex justify-center items-center">
      <div class="flex items-center space-x-3">
        <label class="text-sm font-medium text-base-content/70 whitespace-nowrap">Itens por página:</label>
        <select 
          :value="itemsPerPage" 
          @change="$emit('page-size-change', parseInt($event.target.value))"
          class="select select-bordered select-sm"
        >
          <option value="5">5</option>
          <option value="10">10</option>
          <option value="20">20</option>
          <option value="50">50</option>
        </select>
      </div>
    </div>

    <!-- Pagination Controls -->
    <div class="flex justify-center items-center sm:flex-row flex-col gap-4">
      <!-- Previous Button -->
      <button 
        @click="$emit('page-change', currentPage - 1)"
        :disabled="currentPage === 1"
        class="btn btn-outline btn-sm"
      >
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
        Anterior
      </button>

      <!-- Page Numbers -->
      <div class="join">
        <button
          v-for="page in visiblePages"
          :key="page"
          @click="$emit('page-change', page)"
          :class="[
            'join-item btn btn-sm',
            page === currentPage ? 'btn-active bg-primary text-white rounded-lg' : ''
          ]"
        >
          {{ page }}
        </button>
      </div>

      <!-- Next Button -->
      <button 
        @click="$emit('page-change', currentPage + 1)"
        :disabled="currentPage === totalPages"
        class="btn btn-outline btn-sm"
      >
        Próximo
        <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
        </svg>
      </button>
    </div>

    <!-- Page Info -->
    <div class="mt-8 text-center absolute top-[-84px] left-1/2 -translate-x-1/2 w-[225px]">
      <div class="badge badge-outline badge-lg">
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
        </svg>
        Página {{ currentPage }} de {{ totalPages }} ({{ totalItems }} itens)
      </div>
    </div>
  </div>
</template>

<script>
/* eslint-disable vue/multi-word-component-names */
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
