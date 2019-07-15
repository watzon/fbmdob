import VueRouter from 'vue-router'
import Vue from 'vue'

import Home from './pages/Home.vue'

Vue.use(VueRouter)

const routes = [
  { path: '', component: Home }
]

const router = new VueRouter({
  routes
})

const app = new Vue({
  router
}).$mount('#app')
