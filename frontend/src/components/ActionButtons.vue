<template>
  <div class="flex flex-col sm:flex-row items-center justify-center gap-6 w-full">
    <!-- Execute Button -->
    <button 
      @click="$emit('execute')" 
      :disabled="loading"
      class="btn btn-success btn-lg sm:w-auto w-full shadow-lg hover:shadow-xl transition-all duration-300 text-white"
    >
      <div v-if="loading" class="loading loading-spinner loading-sm "></div>
      <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-6 4h1m4 0h1m6-6V7a3 3 0 00-3-3H6a3 3 0 00-3 3v1.5"></path>
      </svg>
      Executar
    </button>

    <!-- Clear Button -->
    <button 
      @click="$emit('clear')" 
      :disabled="loading"
      class="btn btn-error btn-lg sm:w-auto w-full shadow-lg hover:shadow-xl transition-all duration-300 text-white"
    >
      <div v-if="loading" class="loading loading-spinner loading-sm"></div>
      <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
      </svg>
      Limpar
    </button>
  </div>
</template>

<script>
export default {
  name: 'ActionButtons',
  props: {
    loading: {
      type: Boolean,
      default: false
    }
  },
  emits: ['execute', 'clear']
}
</script>
