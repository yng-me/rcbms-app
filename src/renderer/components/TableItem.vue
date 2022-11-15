<script lang="ts" setup>
import { computed } from "@vue/runtime-core"
const props = defineProps(['table'])
const tableItemValue = computed(() => {

    return props.table === undefined || props.table === null
        ? '&#8212;'
        : /\d\.\d/.test(props.table) 
            ? (Math.round((props.table + Number.EPSILON) * 100) / 100) < 0.01
                ? '*'
                : Math.round((props.table + Number.EPSILON) * 100) / 100
            : props.table.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    
})

</script>
<template>
    <span v-html="tableItemValue" class=" whitespace-nowrap"></span>
</template>