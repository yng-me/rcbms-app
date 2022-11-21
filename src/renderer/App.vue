<script setup lang="ts">

import { reactive, ref } from 'vue';
// @ts-ignore
import Footer from './components/Footer.vue';
// @ts-ignore
import Home from './components/Home.vue';
// @ts-ignore
import TableMain from './components/TableMain.vue';
// import Arrow from './components/Arrow.vue';
import { ipcRenderer } from './electron';

const showTable = ref(false)
const show = ref(true)
const progress = ref('')

const d = reactive({
  percent: 0,
  total: 0,
  transferred: 0,
  bytesPerSecond: 0,
})

const newUpdateAvailable = ref(false)

ipcRenderer.on('on-update', (event, payload) => {
  progress.value = payload

  if(payload === 'Update downloaded successfully! Please restart RCBMS to apply the changes.') {
    setTimeout(() => {
      newUpdateAvailable.value = true
    }, 1500);
  }
})
ipcRenderer.on('percent', (event, data) => {
  d.percent = parseFloat(data.percent)
})

</script>


<template>
  <transition>
    <div v-if="progress && show" class="absolute left-3 top-3 xl:w-1/3 sm:w-2/5 w-2/3 z-50">
      <div class="px-4 py-2.5 shadow-xl rounded-xl bg-gradient-to-bl from-teal-600 to-cyan-700 text-white border-gray-50 border-2 opacity-80">
        <div class="items-start flex space-x-2 justify-between">
          <p class="tracking-wider text-sm">{{ progress }}</p>
          <button 
              @click.prevent="show = false"
              class="rounded-lg hover:text-red-300">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </button>
        </div>
        <div v-if="d.percent > 0 && d.percent < 100" class="relative w-full py-2">
            <span class="absolute w-full bg-gray-400 bg-opacity-40 h-0.5 bottom-0 rounded"></span>
            <span 
                :style="`width: ${Math.round(d.percent)}%`" 
                class="absolute h-0.5 bg-white bottom-0 transition-opacity ease-in delay-500 rounded">
            </span>
        </div>
      </div>
    </div>
  </transition>
  <transition>
  <div v-if="!showTable">
      <Home @table-shown="showTable = !showTable" />
    </div>
  </transition>
  <transition name="arrow">
    <div v-if="showTable" class="w-full h-full">
        <TableMain @back="showTable = false" />
    </div>
  </transition>
  <Footer></Footer>
</template>


<style scoped>
  .v-enter-active,
  .v-leave-active {
    transition: opacity 0.5s ease;
  }

  .v-enter-from,
  .v-leave-to {
    opacity: 0;
  }

  .v-enter-active {
    transition: all 0.5s ease-out;
  }

  .v-leave-active {
    transition: all 0.3s ease-in;
  }

  .v-enter-from,
  .v-leave-to {
    transform: translateX(-100px);
    opacity: 0;
  }
  .y-scroll-bar::-webkit-scrollbar-track {
      background-color: #A8A29E;
  }

  .y-scroll-bar::-webkit-scrollbar {
      width: 8px;
      background-color: #E7E5E4;
  }

  .y-scroll-bar::-webkit-scrollbar-thumb {
      background-color: #44403C;
  }

</style>