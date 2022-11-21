<script lang="ts" setup>
// @ts-ignore
import Dialog from './Dialog.vue';
// @ts-ignore
import quotes from '../assets/quotes.json'

import { ipcRenderer } from '../electron'
import { reactive, ref, computed } from 'vue';

const shuffleArray = (arr : any) => {
    const newArr = arr.slice()
    for (let i = newArr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [newArr[i], newArr[j]] = [newArr[j], newArr[i]];
    }
    return newArr
}

const q = shuffleArray(quotes)

const showOutputFolder = ref(false)
const showLogs = ref(false)

const emits = defineEmits(['close', 'stop-processing', 'done-processing'])
const props = defineProps(['loading', 'timeElapsed', 'isPilotMode'])

const data : any = reactive({
    logs: []
})

const rStatus = reactive({
  error: false,
  message: 'Now processing...'
})

ipcRenderer.on('rstatus', (event, payload) => {
    data.logs.push({
        text: payload.log,
        time: props.timeElapsed
    })
    rStatus.error = payload.error
    rStatus.message = payload.message
    progress.value = progress.value + payload.count
    if(payload.error) {
        emits('done-processing')
        showOutputFolder.value = false
    }
})

ipcRenderer.on('done-processing', (event, data) => {
    ipcRenderer.send('mounted')
    progress.value++
    showOutputFolder.value = true
    rStatus.message = 'Done processing'
    emits('done-processing')
})

ipcRenderer.on('stop-processing', (event, data) => emits('stop-processing'))

const progress = ref(0)
const n = 18 + 6
const progressIndicator = computed(() => (progress.value / n) * 100)

const quote = computed(() => {
    return `<span class="block text-gray-700">“${q[progress.value].quote}”</span><span class="block text-right italic text-xs text-gray-500">&mdash; ${q[progress.value].from}</span>`
})

const killProcess = () => {
    progress.value = 0
    showOutputFolder.value = false
    showLogs.value = false
    ipcRenderer.send('kill-rspawn')
    data.logs = []
    emits('close')
}

const openOutputFile = () => ipcRenderer.send('open-output-folder', props.isPilotMode)



</script>

<template>
    <Dialog 
        @close="killProcess"
        title="Generating List of Cases with Inconsistencies"
        :message="quote"
        height="h-32"
    >
        <template #progress>
            <div class="relative w-full">
                <span class="absolute w-full bg-gray-300 h-0.5 bottom-0"></span>
                <span 
                    :style="`width: ${progressIndicator}%`" 
                    :class="rStatus.error ? 'bg-red-600 bg-opacity-50' : 'bg-teal-500'"
                    class="absolute h-0.5 bottom-0 transition-opacity ease-in delay-500"></span>
            </div>
        </template>
        <div class="border-t px-4 py-2.5 flex justify-between space-x-2 bg-gray-50">
            <div class="flex items-center space-x-2">
                <div v-if="loading" class="flex items-center justify-center">
                    <div class="w-5 h-5 border-l border-teal-600 rounded-full animate-spin"></div>
                </div>
                <svg v-if="rStatus.error" class="w-4 h-4 text-red-600 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                <span v-if="rStatus.message" :class="rStatus.error? 'text-red-700' : 'text-gray-600'" class="text-sm ">{{ rStatus.message }}</span>
            </div>
            <button v-if="showOutputFolder && !rStatus.error" @click.prevent="openOutputFile" 
                class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-teal-600 hover:bg-teal-700">
                Open Output Folder
            </button>
            <div v-if="loading" class="flex items-center space-x-4">
                <slot></slot>
            </div>
            <button v-else-if="rStatus.error" @click.prevent="showLogs = !showLogs" class="flex text-xs items-center space-x-0.5">
                <span>Show logs</span>
                <svg class="w-3.5 h-3.5 opacity-40" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
            </button>
            <!-- <button 
                @click.prevent="$emit('close')" 
                class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">
                Pause
            </button> -->
        </div>
        <div v-if="showLogs" class="border-t max-h-96 overflow-auto px-4 py-3 text-xs space-y-1 bg-gray-100">
            <p v-for="(i, index) in data.logs" :key="i" class="text-sm flex space-x-1.5 items-start">
                <span>{{ index + 1 }}. </span> <span>[<span>{{ i.time }}</span>] <span v-html="i.text"></span></span>
            </p>
        </div>
    </Dialog>
</template>