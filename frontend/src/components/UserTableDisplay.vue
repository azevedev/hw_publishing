<template>
  <div class="bg-base-200 rounded-2xl border border-base-300 overflow-hidden shadow-xl">
    <!-- Table header -->
    <div class="bg-primary px-8 py-6">
      <div class="flex items-center justify-between">
        <div class="flex items-center space-x-3">
          <div class="w-10 h-10 bg-primary-content rounded-lg flex items-center justify-center shadow-lg">
            <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-primary-content">Lista de Usuários</h2>
            <p class="text-primary-content/70 text-sm">Dados dos usuários do sistema</p>
          </div>
        </div>
        
        <!-- Stats -->
        <div v-if="users.length > 0" class="flex items-center space-x-4">
          <div class="text-right">
            <div class="text-2xl font-bold text-primary-content">{{ users.length }}</div>
            <div class="text-primary-content/70 text-xs">Total de usuários</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Table content -->
    <div class="overflow-x-auto">
      <table class="table w-full">
        <thead>
          <tr>
            <th class="text-base-content/70">ID</th>
            <th class="text-base-content/70">Nome</th>
            <th class="text-base-content/70">Email</th>
            <th class="text-base-content/70">Telefone</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(user) in users" 
            :key="user.id"
            class="hover:bg-base-300/50 transition-colors duration-200"
          >
            <td class="font-mono text-sm text-base-content/80">#{{ user.id }}</td>
            <td>
              <div class="flex items-center space-x-3">
                <div class="avatar placeholder">
                  <div class="bg-secondary text-primary-content rounded-full w-10 !flex items-center justify-center">
                    <span class="text-sm font-semibold">{{  (user.nome?.split(' ')[0]?.charAt(0)?.toUpperCase() ?? '-')  + (user.nome.split(' ')[1]?.charAt(0)?.toUpperCase() ?? '') }}</span>
                  </div>
                </div>
                <div class="font-medium text-base-content">{{ user.nome }}</div>
              </div>
            </td>
            <td class="text-base-content/80">{{ user.email }}</td>
            <td>
              <div class="flex items-center space-x-2">
                <svg class="w-4 h-4 text-base-content/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path>
                </svg>
                <span class="text-base-content/80">{{ user.phone }}</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- No users found -->
      <div v-if="users.length === 0 && !loading" class="text-center py-16">
        <div class="w-24 h-24 mx-auto mb-6 bg-base-300 rounded-2xl flex items-center justify-center">
          <svg class="w-12 h-12 text-base-content/40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
          </svg>
        </div>
        <h3 class="text-base-content text-lg font-semibold mb-2">Nenhum usuário encontrado</h3>
        <p class="text-base-content/60 text-sm">Clique em "Executar" para carregar dados do sistema.</p>
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
    loading: {
      type: Boolean,
      default: false
    }
  }
}
</script>

