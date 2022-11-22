<script lang="ts" setup>
import { ref, PropType } from "vue";
import { TableOptions, SavedTables } from "../utils/types";

const viewStatus = ref(true)

const props = defineProps({
    savedTables: {
        type: Array as PropType<SavedTables[]>,
        required: true
    }
})
const emits = defineEmits(['selected-table', 'close'])

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
                        <!-- <button 
                            @click.prevent="viewStatus = false"
                            :class="!viewStatus ? 'text-teal-600' : 'text-gray-300'" class="hover:text-teal-700 font-semibold tracking-widest uppercase hover:font-medium">
                            <span class="">Options</span>
                        </button>  -->
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
                        <li v-for="(i, index) in savedTables" :key="index" class="px-4 py-2 border-t hover:bg-gray-50 flex items-center justify-between">
                            <button @click.prevent="selectedTable(i.title)" class="flex hover:text-teal-600 text-left space-x-1.5">
                                <span class="opacity-50">{{ index + 1 }}. </span>
                                <span class="">{{ i.title }}</span>
                            </button>
                            <button 
                                class="hover:text-teal-600 text-gray-600">
                                <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path></svg>
                            </button>
                        </li>
                    </ul>
                    <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50 w-full">
                        <button 
                            @click.prevent="$emit('close')" 
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                            <!-- @click.prevent="filterApplied" -->
                        <button 
                            :disabled="!savedTables.length"
                            :class="[
                                !savedTables.length? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'
                            ]"
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-gradient-to-tr">
                            Export Table
                        </button>
                    </div>
                </template>
            </div>
        </div>
    </transition>
</template>
