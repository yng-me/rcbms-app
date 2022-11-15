<script lang="ts" setup>

const emit = defineEmits(['close'])
const props = defineProps(['title', 'message', 'loading', 'height'])

</script>

<template>
    <div class="px-4">
        <div class="bg-white rounded-xl overflow-hidden">
          <div class="px-4 py-3 flex items-center justify-between border-b">
            <span class="text-teal-600 font-medium tracking-wide transition-opacity ease-in-out delay-700">{{ title }}</span>
            <button 
                :disabled="loading"
                @click.prevent="$emit('close')" 
                :class="loading? ' opacity-50' : 'hover:bg-gray-100 hover:text-red-500'"
                title="Quit"
                class="p-1 rounded-lg">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
          </div>
          <slot name="progress"></slot>
          <div v-if="message" class="px-4 py-5" :class="height">
            <p v-html="message"></p>
          </div>
          <slot></slot>
        </div>
    </div>
</template>