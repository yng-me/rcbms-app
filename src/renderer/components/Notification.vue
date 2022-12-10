<script lang="ts" setup>

defineProps(['show', 'progress', 'title', 'notifType', 'showProgress', 'progressWidth'])
defineEmits(['toggle'])

</script>

<template>
    <div class="fixed">
        <div class="px-4 py-2.5 shadow-xl rounded-xl bg-gradient-to-bl from-teal-600 to-cyan-700 text-white border-gray-50 border-2 opacity-80">
            <div class="items-start flex space-x-2 justify-between">
                <div class="">
                    <p v-if="title" class="uppercase text-xs font-semibold tracking-widest mb-2 text-teal-400">
                        {{ title }}
                    </p>
                    <p class="tracking-wider text-xs">{{ progress }}</p>
                </div>
                <button 
                    @click.prevent="$emit('toggle')"
                    class="rounded-lg hover:text-red-300">
                    <svg v-if="notifType == 'close'" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    <svg v-else-if="notifType == 'maximize'" class="w-4 h-4 transform !rotate-90" style="-webkit-transform: scaleX(-1); transform: scaleX(-1); rotate: 180;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path></svg>
                </button>
            </div>
            <div v-if="showProgress" class="relative w-full py-2">
                <span class="absolute w-full bg-gray-400 bg-opacity-40 h-0.5 bottom-0 rounded"></span>
                <span 
                    :style="`width: ${progressWidth}%`" 
                    class="absolute h-0.5 bg-white bottom-0 transition-opacity ease-in delay-500 rounded">
                </span>
            </div>
        </div>
    </div>
</template>