<template>
  <div class="bg-white rounded-lg shadow-lg border border-slate-200 overflow-hidden">
    <!-- Table header -->
    <div class="bg-gradient-to-r from-slate-600 to-slate-700 px-6 py-4">
      <h2 class="text-xl font-bold text-white flex items-center">
        <svg class="w-6 h-6 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
        </svg>
        Lista de Usuários
      </h2>
    </div>

    <!-- Table content -->
    <div class="overflow-x-auto">
      <table class="table w-full">
        <thead class="bg-slate-50">
          <tr>
            <th class="text-slate-700 font-semibold border-b border-slate-200">ID</th>
            <th class="text-slate-700 font-semibold border-b border-slate-200">Nome</th>
            <th class="text-slate-700 font-semibold border-b border-slate-200">Email</th>
            <th class="text-slate-700 font-semibold border-b border-slate-200">Telefone</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(user, index) in users" 
            :key="user.id"
            :class="[
              'hover:bg-slate-50 transition-colors duration-200',
              index % 2 === 0 ? 'bg-white' : 'bg-slate-25'
            ]"
          >
            <td class="font-mono text-sm text-slate-600 border-b border-slate-100">{{ user.id }}</td>
            <td class="font-medium text-slate-800 border-b border-slate-100">{{ user.nome }}</td>
            <td class="text-slate-700 border-b border-slate-100">{{ user.email }}</td>
            <td class="text-slate-700 border-b border-slate-100">{{ user.phone }}</td>
          </tr>
        </tbody>
      </table>
      
      <!-- No users found -->
      <div v-if="users.length === 0 && !loading" class="text-center py-12">
        <div class="text-slate-400 mb-4">
          <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
          </svg>
        </div>
        <p class="text-slate-600 text-lg font-medium">Nenhum usuário encontrado</p>
        <p class="text-slate-500 text-sm mt-2">Clique em "Executar" para carregar dados.</p>
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

<style scoped>
.bg-slate-25 {
  background-color: #f8fafc;
}
</style>
