<script lang="ts" setup>

import { computed, PropType, reactive, ref } from 'vue';
// @ts-ignore
import TableItem from './TableItem.vue';

import { TableOptions } from '../utils/types'
// @ts-ignore
import TableSort from './TableSort.vue';
import { sort } from 'semver';

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
    dataTable: Array as any
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

</script>

<template>
    <div class="pb-10">
        <div v-if="dfNoTotal.length" class="overflow-auto w-full p-6">
            <div class="rounded-xl border overflow-auto w-full">
                <table class="w-full table-auto overflow-hidden">
                    <thead class="text-xs bg-teal-700 text-white border-b border-teal-700 uppercase tracking-widest">
                        <th class="px-3.5 pt-2.5 pb-2 font-medium text-left items-start" v-if="tableOptions.groupBy.province">
                            <TableSort @sort-table="sortTable('province')" label="Province" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 font-medium text-left items-start" v-if="tableOptions.groupBy.city_mun">
                            <TableSort @sort-table="sortTable('city_mun')" label="City/Municipality" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 font-medium text-left items-start" v-if="tableOptions.groupBy.brgy">
                            <TableSort @sort-table="sortTable('brgy')" label="Barangay" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 font-medium text-left items-start" v-if="tableOptions.groupBy.ean">
                            <TableSort @sort-table="sortTable('ean')" label="EA" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 font-medium text-left items-start whitespace-nowrap">
                            <TableSort @sort-table="sortTable(tableOptions.row)" :label="rowName !== '' ? rowName : tableOptions.row" />
                        </th>
                        <th class="px-3.5 pt-2.5 pb-2 font-medium !w-32 whitespace-nowrap" v-for="i in heading" :key="i">
                            <TableSort @sort-table="sortTable(i)" :label="i" />
                        </th>
                    </thead>
                    <tbody>
                        <tr v-for="(item, index) in dfNoTotal" :key="index">
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] ? item[tableOptions.row] : 'Missing / NA' }}</td>
                            <td class="border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                        <tr v-for="(item, index) in dfTotal" :key="index">
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.province">{{ item.province }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.city_mun">{{ item.city_mun }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.brgy">{{ item.brgy }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap" v-if="tableOptions.groupBy.ean">{{ item.ean }}</td>
                            <td class="border-t border-r px-3.5 py-1.5 text-left whitespace-nowrap">{{ item[tableOptions.row] ? item[tableOptions.row] : 'Missing / NA' }}</td>
                            <td class="border-t border-l px-3.5 py-1.5 text-right whitespace-nowrap" v-for="j in heading" :key="j">
                                <TableItem :table="item[j]" />
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>