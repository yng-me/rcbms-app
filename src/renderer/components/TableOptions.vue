<script lang="ts" setup>
import { ref, PropType } from "vue";
import { TableOptions, SavedTables } from "../utils/types";

const viewStatus = ref(false)

const props = defineProps({
    savedTables: {
        type: Array as PropType<SavedTables[]>,
        required: true
    }
})
const emits = defineEmits(['selected-table'])

const selectedTable = (title: string) => {
    const payload = props.savedTables.find(el => el.title == title)?.tableOptions
    emits('selected-table', payload)
}

</script>

<template>
    <transition name="slide-fade">
        <div class="absolute right-4 top-12 z-40">
            <div class="rounded-lg border bg-white w-96 flex flex-col items-start text-xs tracking-wide shadow-2xl overflow-hidden">
                <div class="uppercase tracking-widest font-medium pl-4 pr-3 py-1.5 text-gray-500 justify-between w-full flex items-center" style="font-size: 10px">
                    <div class="flex items-center space-x-4">
                        <!-- @click.prevent="viewStatus = false" -->
                        <!-- :class="viewStatus ? 'text-gray-400' : 'text-teal-600'"  -->
                        <button 
                        @click.prevent="viewStatus = false"
                        :class="!viewStatus ? 'text-teal-600' : 'text-gray-300'" class="hover:text-teal-700 font-semibold tracking-widest uppercase hover:font-medium">
                        <span class="">Options</span>
                        </button> 
                        <!-- <span class="opacitiy-40 text-gray-200">|</span> -->
                        <button 
                        @click.prevent="viewStatus = true"
                        :class="viewStatus ? 'text-teal-600' : 'text-gray-300'" class="hover:text-teal-700 font-semibold tracking-widest uppercase hover:font-medium">
                        <span>Saved Tables</span>
                        </button>
                    </div>
                    <!-- <span v-if="isWritingFile" class="p-1 flex items-center justify-center">
                        <span class="w-4 h-4 border-l border-teal-500 rounded-full animate-spin"></span>
                    </span>
                    <button v-else @click.prevent="showMenu = false" class="hover:bg-gray-100 hover:text-red-500 p-1 rounded-lg" title="Quit">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                    </button> -->
                </div>
                <template v-if="viewStatus && savedTables.length">
                    <ul class="w-full text-sm overflow-auto" style="max-height: 500px">
                        <li v-for="(i, index) in savedTables" :key="index" class="px-4 py-1.5 border-t hover:bg-gray-50">
                            <button @click.prevent="selectedTable(i.title)" class="flex hover:text-teal-600 text-left space-x-1.5">
                                <span class="opacity-50">{{ index + 1 }}. </span>
                                <span class="">{{ i.title }}</span>
                            </button>
                        </li>
                    </ul>
                    <div class="border-t w-full px-4 py-2">
                        Export
                    </div>
                </template>
            </div>
        </div>
    </transition>
</template>
