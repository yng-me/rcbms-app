<script lang="ts" setup>

import { computed, PropType, reactive, watch, ref } from 'vue';
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
const progress = ref('')

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
    },
    tableOutputFolder: {
        type: String,
        required: true
    }
})

const show = reactive({
    saveTable: false,
})

const emits = defineEmits(['saved-table', 'show-export'])

const key = computed(() => {
    const groupBy = Object.entries({...props.tableOptions.groupBy})
    .filter(item => item[1] === true) 
    .map(el => el[0])
    
    return groupBy.length ? groupBy[0] : props.tableOptions.row
})

const df = computed(() => {

    const k = sorted.variable.length ? sorted.variable[0] : key.value

    return props.dataTable
        .filter((el : any) => el[key.value] !== 'Total' && el[k] !== undefined)
        .sort((a : any, b : any) => {

            const n = parseInt(a[k])
            const order = sorted.desc ? 1: -1
            
            if(!n) {
                if (a[k] > b[k]) return 1 * order
                if (a[k] < b[k]) return -1 * order
                return 0
            } else {
                return sorted.desc 
                    ? parseInt(a[k]) - parseInt(b[k])
                    : parseInt(b[k]) - parseInt(a[k])
            }
        }) 

})

// const dfExcludeTotal = computed(() => {

//     const groupBy = Object.entries({...props.tableOptions.groupBy})
//     .filter(item => item[1] === true) 
//     .map(el => el[0])

//     const key.value = groupBy.length ? groupBy[0] : props.tableOptions.row
//     return df.value.filter((el : any) => {

//         return Object.key.values(el).find(val => {
//             return el[key.value] !== 'Total' && el[key.value] !== undefined 
//         })
//     })
// })


const dfTotalOnly = computed(() => {
    return props.dataTable.filter((el : any) => el[key.value] === 'Total')
})

const dfMissingOnly = computed(() => {
    const k = sorted.variable.length ? sorted.variable[0] : key.value

    return props.dataTable.filter((el : any) => el[k] === undefined)
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
    variable: [] as string[],
    desc: true
})

const sortTable = (variable: string) => {

    if (!Boolean(sorted.variable.find(el => el == variable))) {
        
        sorted.variable.push(variable)
    } 

    sorted.desc = !sorted.desc
    console.log(sorted.variable);
    
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

// ipcRenderer.on('selected-export-path', (event, data) => {
//     destination.value = data
// })

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
    <div v-if="dataTable.length" class="pb-16 bg-gradient-to-t from-white to-gray-100">
        <!-- <input 
            type="text" v-model="tableTitle" 
            placeholder="Table Title"
            class="border-transparent tracking-wide bg-transparent sm:w-3/5 w-full font-semibold px-0 py-1 text-sm focus:border-b focus:border-t-transparent focus:border-l-transparent focus:border-r-transparent focus:border-teal-500 focus:border-opacity-50 focus:ring-0" > -->
        <div class="px-6 pt-4 pb-3 sm:flex items-end justify-end w-full space-y-3">
            <div class="flex items-center space-x-3 justify-end">
                <button 
                    @click="$emit('show-export')"
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
                    <svg v-if="tableExist" class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path d="M5 4a2 2 0 012-2h6a2 2 0 012 2v14l-5-2.5L5 18V4z"></path></svg>    
                    <svg v-else class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"></path></svg>
                    <span>Save{{ tableExist ? 'D' : '' }}</span>
                    <span v-if="tableExist" class="pl-1">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                    </span>
                </button>
               
            </div>
        </div>
        <!-- <button class="hover:text-teal-600">
            <svg class="w-5 h-5 opacity-60" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"></path></svg>
        </button>
         -->
        <div class="overflow-auto w-full px-6 pb-24">
            <div class="rounded-xl border overflow-auto w-full">
                <table class="w-full table-auto overflow-hidden">
                    <thead class="text-xs bg-gray-50 text-teal-700 border-b border-teal-700 uppercase tracking-widest">
                    <!-- <thead class="text-xs bg-teal-700 text-white border-b border-teal-700 uppercase tracking-widest"> -->
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.province">
                            <TableSort @sort-table="sortTable('province')" label="Province" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.city_mun">
                            <TableSort @sort-table="sortTable('city_mun')" label="City/Municipality" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.brgy">
                            <TableSort @sort-table="sortTable('brgy')" label="Barangay" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start" v-if="tableOptions.groupBy.ean">
                            <TableSort @sort-table="sortTable('ean')" label="EA" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-r font-semibold text-left items-start whitespace-nowrap">
                            <TableSort @sort-table="sortTable(tableOptions.row)" :label="rowName !== '' ? rowName : tableOptions.row" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 border-l font-semibold !w-32 whitespace-nowrap" v-for="i in heading" :key="i">
                            <!-- <TableSort @sort-table="sortTable(i)" :label="i" /> -->
                            {{ i }}
                        </th>
                    </thead>
                    <tbody class="bg-white">
                        <tr v-for="(item, index) in df" :key="index">
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <!-- <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] }}</td> -->
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] || item[tableOptions.row] == 0 ? item[tableOptions.row] : 'Missing / NA' }}</td>
                            <td class="text-sm tracking-wide border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                        <tr v-for="(item, index) in dfMissingOnly" :key="index">
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">
                                {{ item[tableOptions.row] || item[tableOptions.row] == 0 ? item[tableOptions.row] : 'Missing / NA' }}
                            </td>
                            <td class="text-sm tracking-wide border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                        <tr v-for="(item, index) in dfTotalOnly" :key="index">
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="text-sm tracking-wide border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] }}</td>
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
    </div>
</template>