<script lang="ts" setup>

defineProps({
    isActive: {
        type: Boolean,
        required: true,
        default: false
    },
    label: String
})

</script>
<template>
    <button 
        :class="isActive ? 'text-teal-600' : ''"
        class="hover:text-teal-600 bg-gray-50 hover:border-gray-200 hover:bg-gray-50 md:px-3.5 p-2.5 border rounded-2xl">
        <span class="flex shrink-0 items-center space-x-3">
            <span :class="{ 'opacity-70' : !isActive }">
                <slot></slot>
            </span>
            <span v-if="label" class="text-sm md:inline hidden tracking-wide whitespace-nowrap pr-3">{{ label }}</span>
        </span>
    </button>
</template>