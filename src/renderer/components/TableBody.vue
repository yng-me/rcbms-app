<script lang="ts" setup>

import { computed, PropType, reactive, ref } from 'vue';
// @ts-ignore
import TableItem from './TableItem.vue';
import BaseModal from './BaseModal.vue';
// @ts-ignore
import Dialog from './Dialog.vue';
import { SavedTables, TableOptions } from '../utils/types'
// @ts-ignore
import TableSort from './TableSort.vue';
import { ipcRenderer } from '../electron';

import { tableAlreadyExist } from '../helpers'

const tableTitle = ref('')
const tableDesc = ref('')
const destination = ref('')
const filename = ref('')
const progress = ref('')
const selectedTablesToExport = ref([])

const props = defineProps({
    tableOptions: {
        type: Object as PropType<TableOptions>,
        required: true
    },
    rowName: {
        type: String,
        required: true,
        default: ''
    },
    dataTable: Array as any,
    script: {
        type: String
    },
    savedTables: {
        type: Array as PropType<SavedTables[]>,
        required: true
    }
})
const emits = defineEmits(['saved-table'])

const show = reactive({
    saveTable: false,
    exportTable: false
})

const df = computed(() => {

    if(sorted.variable !== '') {
        
        return props.dataTable.sort((a : any, b : any) => {

            const v = a[sorted.variable] as string | number
            const w = b[sorted.variable] as string | number
            
            if(v !== undefined && w !== undefined) {

                if(sorted.desc) {
                    if(typeof v === 'string' && typeof w === 'string') {
                        return w.localeCompare(v)
                    } else if (typeof v === 'number' && typeof w === 'number') {
                        return w - v
                    }
                } else {
                    if(typeof v === 'string' && typeof w === 'string') {
                        return v.localeCompare(w)
                    } else if (typeof v === 'number' && typeof w === 'number') {
                        return v - w
                    }
                }
            } 
        })
    } else {        
        return props.dataTable
    }
})

const dfNoTotal = computed(() => {
    return df.value.filter((el : any) => el[sorted.variable] !== 'Total')
})

const dfTotal = computed(() => {
    return df.value.filter((el : any) => el[sorted.variable] === 'Total')
})

const tableExist = computed(() => {
    return tableAlreadyExist(props.savedTables || [], props.tableOptions)
})

const tableNameExist = computed(() => {
    return Boolean(props.savedTables.find(el => el.title == tableTitle.value))
})

const heading = computed(() => {

    const g = Object.entries({...props.tableOptions.groupBy})
        .filter(item => item[1] === true) 
        .map(el => el[0])

    return Object.keys(props.dataTable[0]).filter(el => el !== props.tableOptions.row && !g.includes(el))
})

const sorted = reactive({
    variable: '',
    desc: true
})

const sortTable = (variable: string) => {
    sorted.variable = variable
    sorted.desc = !sorted.desc
}

const saveSelectedTable = () => {
    
    progress.value = 'Saving...'

    const payload = {
        title: tableTitle.value,
        description: tableDesc.value,
        dataTable: JSON.parse(JSON.stringify(props.dataTable)) ,
        tableOptions: JSON.parse(JSON.stringify(props.tableOptions))
    }

    setTimeout(() => {        
        ipcRenderer.send('save-table', payload)
    }, 500);

}

const exportTable = () => {
    alert('Exported')
}

const chooseOutputDest = () => {
    ipcRenderer.send('select-export-path')
}

ipcRenderer.on('selected-export-path', (event, data) => {
    destination.value = data
})

ipcRenderer.on('saved-table', (event, data) => {
    progress.value = 'Saved'
    tableTitle.value = ''
    tableDesc.value = ''
    setTimeout(() => {
        progress.value = ''
        show.saveTable = false
        emits('saved-table', data)
    }, 1000);
})

</script>

<template>
    <div v-if="dfNoTotal.length" class="pb-16 pt-6 bg-gradient-to-t from-white to-gray-100">
        <!-- <input 
            type="text" v-model="tableTitle" 
            placeholder="Table Title"
            class="border-transparent tracking-wide bg-transparent sm:w-3/5 w-full font-semibold px-0 py-1 text-sm focus:border-b focus:border-t-transparent focus:border-l-transparent focus:border-r-transparent focus:border-teal-500 focus:border-opacity-50 focus:ring-0" > -->
        <div class="px-6 pt-4 pb-3 sm:flex items-end justify-end w-full space-y-3">
            <div class="flex items-center space-x-3 justify-end">
                <button 
                    @click="show.exportTable = true"
                    :disabled="savedTables?.length === 0"
                    :class="savedTables?.length === 0 ? 'bg-gray-50 text-gray-400' : 'hover:text-teal-600 text-gray-600  bg-white hover:bg-gray-50'"
                    class="pl-3 pr-3.5 py-1.5 flex items-center space-x-1 text-xs tracking-widest border rounded-xl uppercase font-semibold">
                    <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-3m-1 4l-3 3m0 0l-3-3m3 3V4"></path></svg>
                    <span>Export</span>
                </button>
                <button 
                    :disabled="tableExist"
                    @click="show.saveTable = true" 
                    :class="tableExist ? 'text-white bg-teal-600 ' : 'border text-gray-600 bg-white hover:text-teal-600 hover:bg-gray-50 '"
                    class="pl-3 pr-3.5 py-1.5 flex items-center space-x-1 text-xs tracking-widest rounded-xl uppercase font-semibold">
                    <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"></path></svg>
                    <span>Save{{ tableExist ? 'D' : '' }}</span>
                    <span v-if="tableExist" class="pl-1">
                        <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    </span>
                </button>
               
            </div>
        </div>
        <!-- <button class="hover:text-teal-600">
            <svg class="w-5 h-5 opacity-60" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"></path></svg>
        </button> -->
        
        <div class="overflow-auto w-full px-6 pb-24">
            <div class="rounded-xl border overflow-auto w-full">
                <table class="w-full table-auto overflow-hidden">
                    <thead class="text-xs bg-gray-50 text-teal-700 border-b border-teal-700 uppercase tracking-widest">
                    <!-- <thead class="text-xs bg-teal-700 text-white border-b border-teal-700 uppercase tracking-widest"> -->
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.province">
                            <!-- <TableSort @sort-table="sortTable('province')" label="Province" /> -->Province
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.city_mun">
                            <!-- <TableSort @sort-table="sortTable('city_mun')" label="City/Municipality" /> -->City/Municipality
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.brgy">
                            <!-- <TableSort @sort-table="sortTable('brgy')" label="Barangay" /> -->Barangay
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.ean">
                            <!-- <TableSort @sort-table="sortTable('ean')" label="EA" /> -->EA
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start whitespace-nowrap">
                            <!-- <TableSort @sort-table="sortTable(tableOptions.row)" :label="rowName !== '' ? rowName : tableOptions.row" /> -->{{ rowName !== '' ? rowName : tableOptions.row }}
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-l font-semibold !w-32 whitespace-nowrap" v-for="i in heading" :key="i">
                            <!-- <TableSort @sort-table="sortTable(i)" :label="i" /> -->
                            {{ i }}
                        </th>
                    </thead>
                    <tbody class="bg-white">
                        <tr v-for="(item, index) in dfNoTotal" :key="index">
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] ? item[tableOptions.row] : 'Missing / NA' }}</td>
                            <td class="text-sm tracking-wide border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                        <tr v-for="(item, index) in dfTotal" :key="index">
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] ? item[tableOptions.row] : 'Missing / NA' }}</td>
                            <td class="text-sm tracking-wide border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <BaseModal @close="show.saveTable = false" :show="show.saveTable" usage="dialog" max-width="xl">
            <Dialog @close="show.saveTable = false" title="Save Table">
                <div class="pt-4 pb-5 space-y-5">
                    <div class="px-5 flex flex-col space-y-1.5">
                        <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Table Title</label>
                        <input 
                            type="text" v-model="tableTitle" 
                            placeholder="Table Title"
                            class="px-3.5 py-1.5 rounded-xl text-sm focus:border-teal-600 w-full border-gray-300" 
                        />
                        <span v-if="tableNameExist" class="text-red-600 text-xs tracking-wide">Table name already exists.</span>
                    </div>
                    <div class="px-5 flex flex-col space-y-1.5">
                       <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Table Description (Optional)</label>    
                        <textarea 
                            v-model="tableDesc" 
                            class="px-3.5 py-1.5 rounded-xl text-sm focus:border-teal-600 w-full border-gray-300" 
                            placeholder="Table Description" />
                    </div>
                </div>
                <div :class="progress ? 'justify-between' : 'justify-end'"
                    class="border-t px-5 py-2.5 flex space-x-2 bg-gray-50">
                    <div class="flex items-center space-x-2">
                        <div v-if="progress == 'Saving...'" class="flex items-center justify-center">
                            <div class="w-5 h-5 border-l border-teal-600 rounded-full animate-spin"></div>
                        </div>
                        <svg v-else-if="progress == 'Saved'" class="w-5 h-5 opacity-50 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        <span>{{ progress }}</span>
                    </div>
                    <div class="flex space-x-2 items-center">            
                        <button 
                            @click.prevent="show.saveTable = false" 
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                        <button 
                            :disabled="!tableTitle || tableNameExist || progress != ''"
                            @click.prevent="saveSelectedTable"
                            :class="!tableTitle || tableNameExist || progress != ''? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-gradient-to-tr">
                            Save
                        </button>
                    </div>
                </div>
            </Dialog>
        </BaseModal>
        <BaseModal @close="show.exportTable = false" :show="show.exportTable" usage="dialog" max-width="xl">
            <Dialog @close="show.exportTable = false" title="Export Table">
                <div class="pt-4 pb-5 space-y-5">
                    <div class="px-5 flex flex-col space-y-1.5">
                        <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">File Name</label>
                        <input 
                            type="text" v-model="filename" 
                            placeholder="Table Title"
                            class="px-3.5 py-1.5 rounded-xl text-sm focus:border-teal-60 focus:border-teal-600 font-semibold w-full border-gray-300" 
                        />
                    </div>
                    <div class="px-5 flex flex-col space-y-1.5 relative">
                        <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Output Destination</label>
                        <input 
                            type="text" v-model="destination" 
                            placeholder=""
                            disabled
                            class="px-3.5 py-1.5 rounded-xl text-sm focus:border-teal-600 w-full font-semibold border-gray-300" 
                        />
                        <button 
                            @click.prevent="chooseOutputDest"
                            class="absolute right-8 bottom-2 hover:text-teal-600">
                            <svg class="w-5 h-5 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3M3 17V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"></path></svg>
                        </button>
                    </div>
                    <!-- <div class="px-5 flex flex-col space-y-1.5">
                        <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">File type</label>
                        <div class="grid sm:grid-cols-4 grid-cols-2 gap-3.5">
                            <div v-for="i in ['Excel', 'CSV']" :key="i" class="w-full">
                                <button @click.prevent="tableOptions.joinType = i" :class="{ 'text-teal-600 bg-gray-50 border-teal-500 font-bold' : i === tableOptions.joinType }"
                                    class="hover:bg-teal-100 px-3.5 py-2 border hover:border-teal-400 rounded-xl w-full flex items-center justify-between">
                                    <span class=" tracking-wider text-xs">{{ i }}</span>
                                    <svg v-if="i === tableOptions.joinType" class="w-4 h-4 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                                </button>
                            </div>
                        </div>
                    </div> -->
                    <div class="px-5">
                        <div class="px-5 py-4 space-y-4 rounded-xl border h-64 overflow-auto">
                            <div v-for="(i, index) in savedTables" :key="index" class="flex items-start space-x-2">
                                <input 
                                    type="checkbox" 
                                    v-model="selectedTablesToExport" 
                                    :value="i.title" :name="i.title" :id="i.title" 
                                    class="text-teal-600 rounded mt-1" 
                                />
                                <label :for="i.title" class="flex flex-col">
                                    <span>{{ i.title }}</span>
                                    <!-- <span class="text-xs text-gray-500 tracking-wide">{{ i.description }}</span> -->
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50">
                    <div class="flex space-x-2 items-center">            
                        <button 
                            @click.prevent="show.exportTable = false" 
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                        <button 
                            :disabled="!filename || !destination"
                            @click.prevent="exportTable"
                            :class="!filename || !destination? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-gradient-to-tr">
                            Export
                        </button>
                    </div>
                </div>
            </Dialog>
        </BaseModal>
    </div>
</template>