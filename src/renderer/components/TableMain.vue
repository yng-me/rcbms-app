<script lang="ts" setup>

import { computed, onMounted, reactive, ref, watch } from '@vue/runtime-core'
import { ipcRenderer } from '../electron'
import { TableOptions, Geo, DataDictionary, TableOptionsGrouping } from '../utils/types'
import { records } from '../assets/constants' 
// @ts-ignore
import TableFilter from './TableFilter.vue';
// @ts-ignore
import TableGroup from './TableGroup.vue';
// @ts-ignore
import TableBody from './TableBody.vue';
import BaseModal from './BaseModal.vue'
// @ts-ignore
import DialogBox from './Dialog.vue'

const loading = ref(false)

const state = reactive({
    geo: [] as Geo[],
    dictionary: [] as DataDictionary[],
    data: [] as any,
})

const show = reactive({
    groupBy: false,
    geoFilter: false,
    joinBy: false
})

const tableOptions = reactive<TableOptions>({
    rowRecord: 'section_a',
    colRecord: 'section_a',
    colRecordLabel: 'Section A',
    joinType: 'Left join',
    joinAll: false,
    joinVariables: ['case_id'] as string[],
    row: '',
    col: '',
    geoFilter: {
        province: '',
        city_mun: '',
        brgy: ''
    },
    groupBy: {
        province: false,
        city_mun: false,
        brgy: false,
        ean: false
    }
})

onMounted(() => {
    loading.value = true
    ipcRenderer.send('load-dictionary')
})

ipcRenderer.on('dictionary', (event, payload) => {
    state.dictionary = payload.dictionary 
    state.geo = payload.geo
    setTimeout(() => {
        loading.value = false
    }, 500);
})

defineEmits(['back'])

const activeDictionary = computed(() => {

    const group = Object.entries({...tableOptions.groupBy}).filter(item => item[1] === true).map(el => el[0])
    const g = [...group, 'case_id', 'line_number_id', 'a13_pcn1', 'a13a_pcn', 'a13_pcn']

    const row = state.dictionary.filter(el => el.record === tableOptions.rowRecord && el.variable !== tableOptions.col && !g.includes(el.variable))
    const col = state.dictionary.filter(el => el.record === tableOptions.colRecord && el.variable !== tableOptions.row && !g.includes(el.variable))
    return { row, col }
})

const applyFilter = (evt : any, type : 'groupBy' | 'geoFilter') => {

    tableOptions[type] = evt
    setTimeout(() => {
        show[type] = false    
    }, 700);
    ipcRenderer.send('arrow', JSON.parse(JSON.stringify(tableOptions)))
}

ipcRenderer.on('return-arrow', (event, payload) => {
    loading.value = false
    state.data = payload
})

watch(() => tableOptions.row && tableOptions.col, () => {
    loading.value = true
    ipcRenderer.send('arrow', JSON.parse(JSON.stringify(tableOptions)))
}, { deep: true })


watch(() => tableOptions.colRecord, (newValue) => {
    tableOptions.colRecordLabel = records.find(el => el.value === newValue)?.label
})

const rowName = computed(() => {
    return state.dictionary.find(el => el.variable === tableOptions.row)?.label
})

const matchedVariables = computed(() => {
    const geo = ['region', 'province', 'city_mun', 'brgy', 'ean', 'bsn', 'husn', 'hsn', 'age', 'b06_ofi']
    const g = [...Object.entries({...tableOptions.groupBy}).filter(item => item[1] === true).map(el => el[0]), ...geo]
    const row = state.dictionary.filter(el => el.record === tableOptions.rowRecord && el.variable !== tableOptions.col && !g.includes(el.variable))
    const col = state.dictionary
        .filter(el => el.record === tableOptions.colRecord && el.variable !== tableOptions.row && !g.includes(el.variable))
        .map(item => item.variable)

    return row.filter(el => col.includes(el.variable))

})

watch(() => tableOptions.joinAll, (newValue) => {
    if(newValue === true) {
        tableOptions.joinVariables = matchedVariables.value.map(el => el.variable)
    }
    if(newValue === false && matchedVariables.value.length === tableOptions.joinVariables?.length) { 
        tableOptions.joinVariables = []
    }
})

watch(() => tableOptions.joinVariables, (newValue, oldValue) => {
    if(matchedVariables.value.length > newValue.length) tableOptions.joinAll = false
    if(matchedVariables.value.length == newValue.length) tableOptions.joinAll = true
})

watch(() => tableOptions.rowRecord, (newValue, oldValue) => {
    tableOptions.colRecord = newValue
    tableOptions.row = ''
    tableOptions.col = ''
    tableOptions.colRecordLabel = records.find(el => el.value === newValue)?.label
})

</script>

<template>
    <div v-if="show.geoFilter || show.groupBy" @click.prevent="[show.geoFilter = false, show.groupBy = false]" class="fixed z-10 h-screen inset-0 bg-stone-700 opacity-75"></div>
    <div class="pr-6 pl-4 pt-6 pb-4 flex items-center relative justify-between w-full">
        <div class="flex sm:items-center items-start space-x-2">
            <button @click.prevent="$emit('back')" class="p-1 hover:text-teal-500">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
            </button>
            <h2 class="text-lg tracking-wider font-semibold text-teal-600 inline-flex sm:flex-row flex-col sm:items-center sm:space-x-2">
                <span>Data Tabulation</span>
                <span v-if="tableOptions.geoFilter.province" class="text-gray-500 font-normal flex sm:space-x-2 text-sm">
                    <span v-if="tableOptions.geoFilter.brgy || tableOptions.geoFilter.city_mun || tableOptions.geoFilter.province" class="sm:block hidden opacity-50">&bull; </span>
                    <span v-if="tableOptions.geoFilter.brgy">Brgy. {{ tableOptions.geoFilter.brgy }}, </span>
                    <span v-if="tableOptions.geoFilter.city_mun">{{ tableOptions.geoFilter.city_mun }}, </span>
                    <span v-if="tableOptions.geoFilter.province">{{ tableOptions.geoFilter.province }}</span>
                </span>
            </h2>
        </div>
        <div class="flex items-center space-x-3">
            <button 
                @click.prevent="show.groupBy = true" 
                :disabled="show.geoFilter"
                :class="show.geoFilter ? 'bg-opacity-20' : 'hover:text-teal-600  hover:bg-gray-50  border'"
                class="flex z-40 items-center space-x-1  bg-white text-gray-600 pr-3.5 pl-3 py-1.5 rounded-xl">
                 <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>
                <span class="uppercase tracking-widest text-xs font-semibold">Grouping</span>
            </button>
            <button 
                @click.prevent="show.geoFilter = true" 
                :disabled="show.groupBy"
                :class="show.groupBy ? 'bg-opacity-20' : 'hover:text-teal-600  hover:bg-gray-50  border'"
                class="flex z-40 items-center space-x-1  bg-white text-gray-600 pr-3.5 pl-3 py-1.5 rounded-xl">
                <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"></path></svg>
                <span class="uppercase tracking-widest text-xs font-semibold">Filter</span>
            </button>
            <transition name="slide-fade">
                <div v-show="show.groupBy || show.geoFilter" class="absolute z-50 right-6 sm:top-16 top-20">
                    <TableGroup
                        @grouping-applied="applyFilter($event, 'groupBy')"
                        @close-group="show.groupBy = false"
                        :show-group="show.groupBy"
                        :table-options="tableOptions"
                    />
                    <TableFilter 
                        @filter-applied="applyFilter($event, 'geoFilter')"
                        @close-filter="show.geoFilter = false"
                        :show-filter="show.geoFilter" 
                        :geo="state.geo"
                    />
                </div>
            </transition>
        </div>
    </div>
    <pre>
        <!-- {{ tableOptions }} -->
    </pre>
     <div class="grid md:grid-cols-4 grid-cols-1 items-end gap-4 px-6 pt-4 pb-6 border-t border-b bg-gray-50">
        <div class="flex flex-col space-y-1.5">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Row Record</label>
            <select name="" id="" 
                v-model="tableOptions.rowRecord" class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option v-for="(i, index) in records" :key="index" :value="i.value">{{ i.label }}</option>
            </select>
        </div>
        <div class="flex flex-col space-y-1.5">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Row variable</label>
            <select v-model="tableOptions.row" 
                class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option value="">-- Select Row --</option>
                <option v-for="(i, index) in activeDictionary.row" :key="index" :value="i.variable">{{ i.item ? `${i.item} - ` : '' }}{{ i.label }}</option>
            </select>
        </div>
        <div class="flex flex-col space-y-1.5 w-full relative">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Column Record</label>
            <input 
                type="text" :value="tableOptions.colRecordLabel" name="" id="" 
                disabled
                :class="tableOptions.row === '' ? 'bg-gray-100 text-gray-400' : ''"
                class="px-3.5 py-1.5 bg-white rounded-xl text-sm border-gray-300"
            />
            <button 
                :disabled="tableOptions.row === ''" 
                @click.passive="show.joinBy = true" 
                :class="tableOptions.row === '' ? 'opacity-50' : 'hover:text-teal-600 '"
                class="px-3 absolute bottom-2 pb-px pl-2 right-0 flex items-center space-x-2 text-sm whitespace-nowrap">
                <svg class="w-4 h-4 opacity-60" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path></svg>
            </button>
        </div>
        <div class="flex flex-col space-y-1.5">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Column variable</label>
            <select 
                v-model="tableOptions.col" 
                :disabled="tableOptions.row === ''" 
                :class="tableOptions.row === '' ? 'bg-gray-100 text-gray-400' : ''"
                class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option value="">-- Select Column --</option>
                <option v-for="(i, index) in activeDictionary.col" :key="index" :value="i.variable">{{ i.item ? `${i.item} - ` : '' }}{{ i.label }}</option>
            </select>
        </div>
    </div>
    <div v-if="loading" class="py-12 flex items-center justify-center w-full">
        <span class="flex space-x-2 items-center">
            <span class="flex items-center justify-center">
                <span class="w-5 h-5 border-l border-teal-600 rounded-full animate-spin"></span>
            </span>
            <span>Loading...</span>
        </span>
    </div>
    <template v-else>
        <TableBody 
            :table-options="tableOptions"
            :rowName="rowName"
            :data-table="state.data"
        />
    </template>
    <BaseModal :closeable="false" :show="show.joinBy" usage="dialog" max-width="2xl">
        <DialogBox @close="show.joinBy = false" title="Joining Records">
            <div class="p-5 w-full space-y-6 overflow-auto relative" style="max-height: 600px">
                <div class="flex flex-col space-y-1.5">
                    <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Column Record</label>
                    <select v-model="tableOptions.colRecord" 
                        class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl w-full text-sm border-gray-300">
                        <option v-for="(i, index) in records" :key="index" :value="i.value">{{ i.label }}</option>
                    </select>
                </div>
                <template v-if="tableOptions.colRecord !== tableOptions.rowRecord">
                    <div class="flex flex-col space-y-1.5">
                        <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Join type</label>
                        <div class="grid lg:grid-cols-4 grid-cols-2 gap-3.5">
                            <div v-for="i in ['Left join', 'Right join', 'Full join', 'Inner join']" :key="i" class="w-full">
                                <button @click.prevent="tableOptions.joinType = i" :class="{ 'text-teal-600 bg-gray-50 border-teal-500 font-bold' : i === tableOptions.joinType }"
                                    class="hover:bg-teal-100 px-3.5 py-2 border hover:border-teal-400 rounded-xl w-full flex items-center justify-between">
                                    <span class="uppercase tracking-widest text-xs">{{ i }}</span>
                                    <svg v-if="i === tableOptions.joinType" class="w-4 h-4 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="flex flex-col space-y-2">
                        <div class="flex items-center justify-between w-full">
                            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Joining variables</label>
                            <div class="flex items-center space-x-2">
                                <input v-model="tableOptions.joinAll" type="checkbox" id="select-all" class="text-teal-600 rounded flex items-center">
                                <label for="select-all" class="text-sm tracking-wider text-gray-500">Select all</label>
                            </div>
                        </div>
                        <div class="border rounded-xl p-3.5 space-y-3">
                            <div v-for="(i, index) in matchedVariables" :key="index" class="flex items-center space-x-2">
                                <input 
                                    type="checkbox" 
                                    v-model="tableOptions.joinVariables" 
                                    :value="i.variable" :name="i.variable" :id="i.variable" 
                                    class="text-teal-600 rounded flex items-center"
                                />
                                <label :for="i.variable" class="text-sm tracking-wider text-gray-700">{{ i.label }}</label>
                            </div>
                        </div>
                    </div>
                </template>
            </div>
            <div class="border-t px-4 py-2.5 flex justify-end space-x-2 bg-gray-100">
                <button @click.passive="show.joinBy = false" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">
                  Cancel
                </button>
                <button 
                    @click.prevent="show.joinBy = false"
                    :class="false ? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                    class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gradient-to-tr">
                    Join Record
                </button>
            </div>
        </DialogBox>
    </BaseModal>
</template>