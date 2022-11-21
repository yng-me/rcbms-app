<script lang="ts" setup>

defineProps(['label', 'variable'])
defineEmits(['sortTable'])

</script>

<template>
    <span class="flex items-center w-full justify-between space-x-4">
        <span>{{ label }}</span>
        <button @click.prevent="$emit('sortTable')" class="hover:text-teal-200">
            <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4"></path></svg>
        </button>
    </span>
</template>