<template>
  <div class="bg-base-200 rounded-2xl border border-base-300 overflow-hidden shadow-xl">
    <!-- Table header -->
    <div class="bg-primary px-8 py-6">
      <div class="flex flex-row items-center justify-between flex-wrap">
        <div class="group flex flex-col sm:flex-row sm:items-center space-x-3">
          <div class="group-hover:scale-110 transition-all duration-200 w-10 h-10 bg-primary-content rounded-lg flex items-center justify-center shadow-lg">
            <!-- User SVG Icon -->
            <svg class="w-6 h-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
            </svg>
          </div>
          <div class="sm:mt-0 mt-2">
            <h2 class="text-xl font-bold text-primary-content">Lista de Usuários</h2>
            <p class="text-primary-content/70 text-sm">Dados dos usuários do sistema</p>
          </div>
        </div>
        
        <!-- Stats -->
        <div v-if="usersLength > 0" class="hover:scale-105 transition-all duration-200 flex items-center space-x-4 ml-auto mt-auto">
          <div class="text-right">
            <div class="text-2xl font-bold text-primary-content">{{ usersLength }}</div>
            <div class="text-primary-content/70 text-xs">Total de usuários</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Table content -->
    <div class="overflow-x-auto">
      <table class="table table-zebra w-full" v-if="users.length > 0">
        <thead>
          <tr>
            <th class="text-base-content/70">ID</th>
            <th class="text-base-content/70">Name</th>
            <th class="text-base-content/70">E-mail</th>
            <th class="text-base-content/70">Phone</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(user, index) in users" 
            :key="user.id"
            class="hover:bg-base-100 animate-fade-in transition-colors duration-200"
            :class="{'bg-neutral/10': index % 2 === 0}"
          >
            <td class="font-mono text-sm text-base-content/80">#{{ user.id }}</td>
            <td>
              <div class="flex items-center space-x-3">
                <div class="avatar placeholder">
                  <div :class="['rounded-full w-10 !flex items-center justify-center', ...getAvatarClasses(user?.nome)]">
                    <span class="text-sm font-semibold">{{  (user?.nome?.split(' ')[0]?.charAt(0)?.toUpperCase() ?? '-')  + (user?.nome?.split(' ')[1]?.charAt(0)?.toUpperCase() ?? '') }}</span>
                  </div>
                </div>
                <div class="font-medium text-base-content whitespace-nowrap">{{ user.nome }}</div>
              </div>
            </td>
            <td class="text-base-content/80 whitespace-nowrap">{{ user.email }}</td>
            <td>
              <div class="flex items-center space-x-2">
                <svg class="w-4 h-4 text-base-content/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                </svg>
                <span class="text-base-content/80 whitespace-nowrap">{{ formatPhone(user.phone) }}</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- No users found -->
      <div v-if="users.length === 0 && !loading" class="text-center py-16 animate-fade-in transition-all duration-200">
        <div class="w-24 h-24 mx-auto mb-6 bg-base-300 rounded-2xl flex items-center justify-center">
          <svg class="w-12 h-12 text-base-content/40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
          </svg>
        </div>
        <h3 class="text-base-content text-lg font-semibold mb-2">Nenhum usuário encontrado</h3>
        <p class="text-base-content/60 text-sm">Clique em "Executar" para carregar os dados do sistema.</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UserTableDisplay',
  props: {
    users: {
      type: Array,
      required: true
    },
    usersLength: {
      type: Number,
      required: true
    },
    loading: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    getAvatarClasses(name) {
      const palette = [
        ['bg-primary', 'text-primary-content'],
        ['bg-primary-content', 'text-primary'],
        ['bg-secondary', 'text-secondary-content'],
        ['bg-secondary-content', 'text-secondary'],
        ['bg-accent', 'text-accent-content'],
        ['bg-accent-content', 'text-accent'],
        ['bg-info', 'text-info-content'],
        ['bg-info-content', 'text-info'],
        ['bg-success', 'text-success-content'],
        ['bg-success-content', 'text-success'],
        ['bg-warning', 'text-warning-content'],
        ['bg-warning-content', 'text-warning'],
        ['bg-error', 'text-error-content'],
        ['bg-error-content', 'text-error'],
        ['bg-base-content', 'text-base-300'],
        ['bg-base-300', 'text-base-content']
      ]
      const key = String(name || '').toLowerCase().trim()
      let hash = 0
      for (let i = 0; i < key.length; i++) {
        hash = (hash * 31 + key.charCodeAt(i)) >>> 0
      }
      const idx = key.length ? hash % palette.length : 0
      return palette[idx]
    },
    // Format phone
    formatPhone(raw) {
      if (!raw) return ''
      const digits = String(raw).replace(/\D/g, '')
      if (digits.length !== 10) return raw
      const area = digits.slice(0, 3)
      const part1 = digits.slice(3, 6)
      const part2 = digits.slice(6)
      return `(${area}) ${part1}-${part2}`
    }
  }
}
</script>

