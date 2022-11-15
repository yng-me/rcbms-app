<script lang="ts" setup>
import { ref } from "@vue/reactivity"

const bg : any = {
    'new feature': 'bg-teal-600',
    'bug fix': 'bg-red-600',
    'enhancement': 'bg-orange-600'
}

defineProps(['item', 'order'])

const show = ref(false)

</script>


<template>
    <div class="flex items-start justify-between">
        <h2 class="inline-flex space-x-1 items-center tracking-wider">
            <span class="text-lg font-semibold text-teal-600">{{ item.version }}</span>
            <span class="text-gray-400">&bull;</span>
            <span class="text-sm text-gray-500">{{ item.releaseDate }}</span>
        </h2>
        <button v-if="order > 0" @click.prevent="show = !show" class="hover:text-teal-600">
            <svg :class="show ? 'tranform rotate-180' : ''" class="w-5 h-5 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
        </button>
    </div>
    <ul v-if="show || order == 0" class="pt-4 tracking-wide">
        <li v-for="j in item.logs" :key="j.feature" class="pb-6 pt-1">
            <span class="inline-flex space-x-2 items-center font-semibold">
                <span :class="bg[j.type]" class="uppercase tracking-widest font-mono px-2 py-0.5 rounded-lg text-white" style="font-size: 11px">
                    {{ j.type }}
                </span>
                <span class="">{{ j.feature }}</span>
            </span>
            <ul v-for="k in j.info" :key="k" class="space-y-1 list-disc px-6 ">
                <li v-html="k" class="py-1 text-sm"></li>
            </ul>
        </li>
    </ul>
</template>