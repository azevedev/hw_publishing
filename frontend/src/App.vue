<template>
  <div class="min-h-screen bg-base">  
    <!-- Main Content -->
    <div class="relative z-10">
      <!-- Header Section -->
      <header class="border-b border-base-300 backdrop-blur-sm">
        <div class="max-w-7xl mx-auto px-6 py-8">
          <div class="flex flex-col sm:flex-row items-center justify-between">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-primary rounded-xl flex items-center justify-center shadow-lg">
                <svg class="w-7 h-7 text-primary-content" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                </svg>
              </div>
              <div>
                <h1 class="text-3xl font-bold text-base-content tracking-tight">H&W Publishing</h1>
                <p class="text-base-content/70 text-sm font-medium">Full Stack Application</p>
              </div>
            </div>
            
            <!-- Status Indicator & Theme Toggle -->
            <div class="flex items-center space-x-3 mt-8 sm:mt-0">
              <!-- Status Indicator -->
              <div class="flex items-center space-x-2 px-4 py-2 bg-base-200 rounded-lg border border-base-300">
                <div class="w-2 h-2 bg-success rounded-full animate-pulse"></div>
                <span class="text-base-content/70 text-sm font-medium">Application Online</span>
              </div>

              <!-- Theme Toggle -->
              <div class="dropdown dropdown-end">
                <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
                  <svg v-if="isDark" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                  </svg>
                  <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>
                  </svg>
                </div>
                <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52 border border-base-300">
                  <li><a @click="setTheme('light')" :class="{ 'active': !isDark }">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>
                    </svg>
                    Light
                  </a></li>
                  <li><a @click="setTheme('dark')" :class="{ 'active': isDark }">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
                    </svg>
                    Dark
                  </a></li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </header>

      <!-- Main Content -->
      <main class="max-w-7xl mx-auto px-6 py-8">
        <UserTable />
      </main>
    </div>
  </div>
</template>

<script>
import UserTable from './components/UserTable.vue'

export default {
  name: 'App',
  components: {
    UserTable
  },
  data() {
    return {
      currentTheme: 'dark'
    }
  },
  computed: {
    isDark() {
      return this.currentTheme === 'dark'
    }
  },
  methods: {
    setTheme(theme) {
      this.currentTheme = theme
      // Set specific theme
      document.documentElement.setAttribute('data-theme', theme)
      // Store preference
      localStorage.setItem('theme', theme)
    },
    
    initTheme() {
      // Get saved theme or default to dark
      const savedTheme = localStorage.getItem('theme') || 'dark'
      this.setTheme(savedTheme)
    }
  },
  
  mounted() {
    this.initTheme()
  }
}
</script>