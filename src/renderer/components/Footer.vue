<script lang="ts" setup>
// @ts-ignore
import { ref, watch } from 'vue';
// @ts-ignore
import { version } from '../../../package.json'
// @ts-ignore
import AboutUs from './AboutUs.vue';
import BaseModal from './BaseModal.vue'
// @ts-ignore
import ChangeLog from './ChangeLog.vue';

// const props = defineProps(['dataLoading'])


const showAbout = ref(false)
const showChangelog = ref(false)
// const props = defineProps(['newUpdateAvailable'])

// watch(() => props.newUpdateAvailable, () => {
//   showChangelog.value = true
// })

</script>

<template>
    <footer class="fixed bottom-0 text-xs px-3 py-1.5 w-full border-t border-gray-200 bg-gray-50">
          <div class="flex items-center justify-between w-full tracking-wider" style="font-size: 11px">
            <div class="flex items-center space-x-1">
              <h1 class="">&copy; RCBMS 2022</h1>
              <span class="text-gray-400">&bull;</span>
              <button @click.prevent="showChangelog = true" class="hover:text-teal-600 ">v{{ version }}</button>
            </div>
            <button @click.prevent="showAbout = true" class="flex items-center space-x-0.5 hover:text-teal-600 ">
              <svg class="w-3 h-3 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
              <span class="tracking-wider">ABOUT</span>
              <!-- <span>Data Availability: 
                <span :class="{ 'text-red-600' : dataLoading.error }" class="font-medium">{{ dataLoading.status }}</span>
              </span>  -->
              <!-- <span class="px-2">&bull; </span> -->
              <!-- <span>Last Run: <span class="font-medium">Date here...</span></span> -->
            </button>
          </div>
    </footer>
    <BaseModal @close="showAbout = false" :closeable="false" :show="showAbout" usage="dialog" max-width="4xl">
      <AboutUs @close="showAbout = false" />
    </BaseModal>
    <BaseModal @close="showChangelog = false" :closeable="false" :show="showChangelog" usage="dialog" max-width="4xl">
      <ChangeLog @close="showChangelog = false" />
    </BaseModal>
</template>