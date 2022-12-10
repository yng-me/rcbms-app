<script setup lang="ts">

import { reactive, ref } from 'vue';
// @ts-ignore
import Footer from './components/Footer.vue';
// @ts-ignore
import Home from './components/Home.vue';
// @ts-ignore
import Notification from './components/Notification.vue';
// @ts-ignore
import TableMain from './components/TableMain.vue';
// @ts-ignore
import TableIndex from './components/tabulation/Index.vue'
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
    }, 200);
  }
})
ipcRenderer.on('percent', (event, data) => {
  d.percent = parseFloat(data.percent)
})

const isPilotMode = ref(false)

ipcRenderer.on('define-mode', (event, data) => {
  isPilotMode.value = data
})

</script>


<template>
  <transition>
    <Notification 
    v-if="progress && show" 
    @toggle="show = false"
    :progress="progress"
    :show-progress="d.percent > 0 && d.percent < 100"
    :progress-width="Math.round(d.percent)"
    notif-type="close"
    class="left-3 top-3 xl:w-1/4 sm:w-1/3 w-2/3 z-50"
    />
  </transition>
  <transition>
    <div v-if="!showTable">
      <Home @table-shown="showTable = !showTable" />
    </div>
  </transition>
  <transition name="arrow">
    <div v-if="showTable" class="w-full h-full">
        <TableMain @back="showTable = false" :isPilotMode="isPilotMode" />
        <!-- <TableIndex /> -->
    </div>
  </transition>
  <Footer></Footer>
  
</template>


<style scoped>
  .v-enter-active,
  .v-leave-active {
    transition: opacity 0.3s ease;
  }

  .v-enter-from,
  .v-leave-to {
    opacity: 0;
  }

  .v-enter-active {
    transition: all 0.3s ease-out;
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