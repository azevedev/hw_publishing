<template>
  <div id="app" class="min-h-screen bg-gray-100 p-8">
    <h1 class="text-3xl font-bold text-center mb-8">User Management Dashboard</h1>
    <UserTable />
  </div>
</template>

<script>
import UserTable from './components/UserTable.vue'

export default {
  name: 'App',
  components: {
    UserTable
  }
}
</script>