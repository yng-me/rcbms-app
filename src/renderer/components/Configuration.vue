<script lang="ts" setup>

import { ref } from 'vue';
import { ipcRenderer } from '../electron'

const props = defineProps(['isAvailable', 'title', 'description', 'config', 'property'])

const loading = ref(false)
const configurePath = () => {
    loading.value = true
    ipcRenderer.send('configure-path', {
        property: props.property,
        config: props.config
    })
}

ipcRenderer.on('saved-path-config', (event, name) => {
    setTimeout(() => {
        loading.value = false
    }, 1000);
})

</script>

<template>
    <li :class="loading? 'animate-pulse bg-gray-200' : ''" class="flex items-center px-4 py-1.5 space-x-1.5 border-t w-full justify-between">
        <span class="flex items-start space-x-1">
            <span>
                <svg v-if="isAvailable" class="w-4 h-4 text-teal-600 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                <svg v-else class="w-4 h-4 text-red-600 opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </span>
            <div class="flex flex-col">
                <span class="font-semibold">{{ title }}</span>
                <span class="text-gray-500" style="font-size: 9px">{{ description }}</span>
                <!-- <span v-else class="text-gray-500" style="font-size: 9px">Not available</span> -->
            </div>
        </span>
        <button @click.prevent="configurePath" class="hover:text-teal-600 text-gray-600">
            <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path></svg>
        </button>
    </li>
</template>
