<script lang="ts" setup>

import { computed, onMounted, reactive, ref, watch } from '@vue/runtime-core'
import { ipcRenderer } from '../electron'
// @ts-ignore
import TableItem from './TableItem.vue';
import { records } from '../assets/constants' 

interface DataDict {
    Variable: string,
    Label: string,
    Items: string
}

const state : any = reactive({
    geo: [],
    dictionary: [] as DataDict[],
    heading: [] as string[],
    data: [],
    variables: [] as string[]
})

const show = ref(false)
const record = ref('section_a')
const row = ref('')
const col = ref('')
const loading = ref(false)
const showGroup = ref(false)
const showFilter = ref(false)
const groupBy = reactive({
    province: false,
    city_mun: false,
    brgy: false,
    ean: false
})
defineEmits(['back'])


onMounted(() => {
    loading.value = true
    ipcRenderer.send('load-dictionary', {
        record: record.value,
        include: true
    })
})

ipcRenderer.on('dictionary', (event, payload) => {
    state.dictionary = payload.dictionary 
    state.geo = payload.geo
    setTimeout(() => {
        loading.value = false
    }, 500);
})

ipcRenderer.on('variables', (event, data) => {
    state.variables = data
    setTimeout(() => {
        loading.value = false
    }, 500);
})

watch([row, col], () => {
    loading.value = true
    ipcRenderer.send('arrow', {
        record: record.value,
        row: row.value,
        col: col.value,
        prov: geo.prov,
        cityMun: geo.cityMun,
        brgy: geo.brgy,
        group: { ...groupBy }
    })
})

watch(record, () => {
    loading.value = true
    ipcRenderer.send('load-dictionary', {
        record: record.value,
        include: false
    })
    state.data = []
    row.value = ''
    col.value = ''
})

const dict = computed(() => {
    const d = state.variables.map((el : any) => {

        const dict : any = state.dictionary.find((eg: any) => eg.Variable == el.toUpperCase())
            ? state.dictionary.find((eg : any) => eg.Variable == el.toUpperCase())
            : { Variable: el, Label: el, Items: null }

        return {
            value: dict.Variable.toLowerCase(),
            label: dict.Label,
            item: el === 'age' ? 'A07' : dict.Items
        }
    })

    const a = Object.values({...groupBy})
    const b = Object.keys({...groupBy})
    let g : string[] = []

    a.forEach((el, key) => {
        if(el) g.push(b[key])
    })

    return {
        col: d.filter((el: any) => el.value !== row.value && !g.includes(el.value)),
        row: d.filter((el: any) => el.value !== col.value && !g.includes(el.value))
    }
})

const rowName = computed(() => {
    return state.dictionary.find((eg : any) => eg.Variable == row.value.toUpperCase())
})

ipcRenderer.on('return-arrow', (event, payload) => {
    state.data = payload.data;

    const a = Object.values({...groupBy})
    const b = Object.keys({...groupBy})
    let g : string[] = []

    a.forEach((el, key) => {
        if(el) g.push(b[key])
    })

    if(payload.data.length > 0) {
        
        state.heading = Object.keys(payload.data[0]).filter(el => el !== row.value && !g.includes(el))
    }
    state.variables = payload.variables
    loading.value = false
})

const geo = reactive({
    prov: '',
    cityMun: '',
    brgy: ''
})

const provinces = computed(() => {  
    return [...new Set(state.geo.map((el : any) => el.province))]
})

const cityMun = computed(() => {
    const cm = state.geo.filter((el : any) => el.province === geo.prov)    
    return [...new Set(cm.map((item : any) => item.city_mun))]
})

const brgys = computed(() => {
    const bg = state.geo.filter((el : any) => el.province === geo.prov && el.city_mun === geo.cityMun)
    return [...new Set(bg.map((item : any) => item.brgy))]
})

const applyFilter = () => {

    if(row.value !== '') {
        loading.value = true
        ipcRenderer.send('arrow', {
            record: record.value,
            row: row.value,
            col: col.value,
            prov: geo.prov,
            cityMun: geo.cityMun,
            brgy: geo.brgy,
            group: { ...groupBy }
        })    
    }
    showFilter.value = false
    showGroup.value = false
}


</script>

<template>
    <div 
        @click.prevent="[showFilter = false, showGroup = false]" 
        v-if="showFilter || showGroup" 
        class="fixed z-10 h-screen inset-0 bg-stone-700 opacity-75">
    </div>
    <div class="pr-6 pl-4 pt-6 pb-4 flex items-center relative justify-between w-full">
        <div class="flex sm:items-center items-start space-x-2">
            <button @click.prevent="$emit('back')" class="p-1 hover:text-teal-500">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path></svg>
            </button>
            <h2 class="text-lg tracking-wider font-semibold text-teal-600 inline-flex sm:flex-row flex-col sm:items-center sm:space-x-2">
                <span>Data Tabulation</span>
                <span v-if="geo.prov" class="text-gray-500 font-normal flex sm:space-x-2 text-sm">
                    <span v-if="geo.brgy || geo.cityMun || geo.prov" class="sm:block hidden opacity-50">&bull; </span>
                    <span v-if="geo.brgy">Brgy. {{ geo.brgy }}, </span>
                    <span v-if="geo.cityMun">{{ geo.cityMun }}, </span>
                    <span v-if="geo.prov">{{ geo.prov }}</span>
                </span>
            </h2>
        </div>
        <div class="flex items-center space-x-3">
            <button 
                @click.prevent="showGroup = true" 
                :disabled="showFilter"
                :class="showFilter ? 'bg-opacity-20' : 'hover:text-teal-600  hover:bg-gray-50  border'"
                class="flex z-40 items-center space-x-1  bg-white text-gray-600 pr-3.5 pl-3 py-1.5 rounded-xl">
                 <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path></svg>
                <span class="uppercase tracking-widest text-xs font-semibold">Grouping</span>
            </button>
            <button 
                @click.prevent="showFilter = true" 
                :disabled="showGroup"
                :class="showGroup ? 'bg-opacity-20' : 'hover:text-teal-600  hover:bg-gray-50  border'"
                class="flex z-40 items-center space-x-1  bg-white text-gray-600 pr-3.5 pl-3 py-1.5 rounded-xl">
                <svg class="w-4 h-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z"></path></svg>
                <span class="uppercase tracking-widest text-xs font-semibold">Filter</span>
            </button>
            <transition name="slide-fade">
                <div v-if="showGroup || showFilter" class="absolute z-50 right-6 sm:top-16 top-20">

                    <div v-if="state.geo && showFilter" class="border pt-4 rounded-xl bg-white shadow-xl space-y-4 overflow-hidden w-96">
                        <div class="px-5 flex flex-col space-y-1">
                            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Province</label>
                            <select name="" id="" v-model="geo.prov" class="px-3.5 py-2 w-full rounded-xl text-sm border-gray-300">
                                <option value="">-- Select Province --</option>
                                <option v-for="(i, index) in provinces" :key="index" :value="i">{{ i }}</option>
                            </select>
                        </div>
                       
                        <div class="px-5 flex flex-col space-y-1">
                            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">City/Municipality</label>
                            <select name="" id="" 
                                v-model="geo.cityMun" 
                                :disabled="geo.prov == ''" 
                                :class="geo.prov == '' ? 'bg-gray-100 text-gray-400' : ''"
                                class="px-3.5 py-2 rounded-xl text-sm border-gray-300">
                                <option value="">-- Select City/Municipality --</option>
                                <option v-for="(i, index) in cityMun" :key="index" :value="i">{{ i }}</option>
                            </select>
                        </div>
                        <div class="px-5 flex flex-col space-y-1">
                            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Barangay</label>
                            <select name="" id="" 
                                v-model="geo.brgy" 
                                :disabled="geo.prov == '' || geo.cityMun == ''" 
                                :class="geo.prov == '' || geo.cityMun == ''? 'bg-gray-100 text-gray-400' : ''"
                                class="px-3.5 py-2 rounded-xl text-sm border-gray-300">
                                <option value="">-- Select Barangay --</option>
                                <option v-for="(i, index) in brgys" :key="index" :value="i">{{ i }}</option>
                            </select>
                        </div>
                        <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50">
                            <button @click.prevent="showFilter = false" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                            <button @click.prevent="applyFilter" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-teal-600 hover:bg-teal-700">Apply Filter</button>
                        </div>
                    </div>
                    <div v-if="showGroup"  class="border tracking-wide rounded-xl bg-white shadow-xl space-y-4 overflow-hidden w-96">
                        <div class="space-y-3">
                            <h2 class="px-5 pt-3 flex tracking-widest uppercase items-start justify-between">
                                <span class="text-xs">GROUPING</span>
                                <button 
                                    @click.prevent="showGroup = false"
                                    title="Quit"
                                    class="p-1 rounded-lg hover:text-red-600">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                                </button>
                            </h2>
                            <label for="gProv" 
                                :class="row === 'province' || col === 'province' ? 'text-gray-500 opacity-30' : ''"
                                class="px-5 flex items-center space-x-2">
                                <input 
                                    :disabled="row === 'province' || col === 'province'" 
                                    v-model="groupBy.province" 
                                    type="checkbox" name="gProv" id="gProv" class="rounded text-teal-600" 
                                />
                                <span>Province</span>
                            </label>
                            <label 
                                :class="row === 'city_mun' || col === 'city_mun' ? 'text-gray-500 opacity-30' : ''"
                                for="gCityMun" class="px-5 flex items-center space-x-2">
                                <input :disabled="row === 'city_mun' || col === 'city_mun'" v-model="groupBy.city_mun" type="checkbox" name="gCityMun" id="gCityMun" class="rounded text-teal-600">
                                <span>City/Municipality</span>
                            </label>
                            <label 
                                :class="row === 'brgy' || col === 'brgy' ? 'text-gray-500 opacity-30' : ''"
                                for="gBrgy" class="px-5 flex items-center space-x-2">
                                <input :disabled="row === 'brgy' || col === 'brgy'" v-model="groupBy.brgy" type="checkbox" name="gBrgy" id="gBrgy" class="rounded text-teal-600">
                                <span>Barangay</span>
                            </label>
                            <label 
                                :class="row === 'ean' || col === 'ean' ? 'text-gray-500 opacity-30' : ''"
                                for="gEA" class="px-5 flex items-center space-x-2">
                                <input :disabled="row === 'ean' || col === 'ean'" v-model="groupBy.ean" type="checkbox" name="gEA" id="gEA" class="rounded text-teal-600">
                                <span>Enumeration Area (EA)</span>
                            </label>
                            <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50">
                                <button @click.prevent="showGroup = false" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                                <button @click.prevent="applyFilter" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-teal-600 hover:bg-teal-700">Apply Grouping</button>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>
        </div>
    </div>
    <div class="grid md:grid-cols-3 grid-cols-1 items-center gap-4 px-6 pt-4 pb-6 border-t border-b bg-gray-50">
        <div class="flex flex-col space-y-1">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Record Type (Section)</label>
            <select name="" id="" 
                v-model="record" class="px-3.5 py-2 rounded-xl text-sm border-gray-300">
                <option v-for="(i, index) in records" :key="index" :value="i.value">{{ i.label }}</option>
            </select>
        </div>
        <template v-if="state.variables.length">
            <div class="flex flex-col space-y-1">
                <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Row variable</label>
                <select name="" id="" 
                    v-model="row" 
                    class="px-3.5 py-2 rounded-xl text-sm border-gray-300">
                    <option value="">-- Select Row --</option>
                    <option v-for="(i, index) in dict.row" :key="index" :value="i.value">{{ i.item ? `${i.item} - ` : '' }}{{ i.label }}</option>
                </select>
            </div>
            <div class="flex flex-col space-y-1">
                <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Column variable</label>
                <select 
                    :disabled="row === ''" name="" id="" 
                    v-model="col" 
                    :class="row === '' ? 'bg-gray-100 text-gray-400' : ''"
                    class="px-3.5 py-2 rounded-xl text-sm border-gray-300">
                    <option value="">-- Select Column --</option>
                    <option v-for="(i, index) in dict.col" :key="index" :value="i.value">{{ i.item ? `${i.item} - ` : '' }}{{ i.label }}</option>
                </select>
            </div>
        </template>
    </div>
    <div v-if="loading" class="py-12 flex items-center justify-center w-full">
        <span class="flex space-x-2 items-center">
            <span class="flex items-center justify-center">
                <span class="w-5 h-5 border-l border-teal-600 rounded-full animate-spin"></span>
            </span>
            <span>Loading...</span>
        </span>
    </div>
    <div v-else class="pb-10">
        <div v-if="state.data.length && !loading" class="overflow-auto p-6">
            <table class="w-full table-auto verflow-hidden">
                <thead class="text-sm">
                    <th class="px-3 py-1.5 border font-medium text-left items-start" v-if="col && groupBy.province">Province</th>
                    <th class="px-3 py-1.5 border font-medium text-left items-start" v-if="col && groupBy.city_mun">City/Municipality</th>
                    <th class="px-3 py-1.5 border font-medium text-left items-start" v-if="col && groupBy.brgy">Barangay</th>
                    <th class="px-3 py-1.5 border font-medium text-left items-start" v-if="col && groupBy.ean">AE</th>
                    <th class="px-3 py-1.5 border font-medium text-left items-start">{{ rowName?.Label ? rowName.Label : row }}</th>
                    <th class="px-3 py-1.5 border font-medium !w-32" v-for="i in state.heading" :key="i">{{ i }}</th>
                </thead>
                <tbody>
                    <tr class="border" v-for="(item, index) in state.data" :key="index">
                        <td class="border px-3 py-1.5 text-left" v-if="col && groupBy.province">{{ item.province }}</td>
                        <td class="border px-3 py-1.5 text-left" v-if="col && groupBy.city_mun">{{ item.city_mun }}</td>
                        <td class="border px-3 py-1.5 text-left" v-if="col && groupBy.brgy">{{ item.brgy }}</td>
                        <td class="border px-3 py-1.5 text-left" v-if="col && groupBy.ean">{{ item.ean }}</td>
                        <td class="border px-3 py-1.5 text-left">{{ item[row] ? item[row] : 'Missing / NA' }}</td>
                        <td class="border px-3 py-1.5 text-right" v-for="j in state.heading" :key="j">
                            <TableItem :table="item[j]" />
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>


<style scoped>
.v-enter-active,
.v-leave-active {
  transition: opacity 0.5s ease;
}

.v-enter-from,
.v-leave-to {
  opacity: 0;
}
.slide-fade-enter-active {
  transition: all 0.5s ease-out;
}

.slide-fade-leave-active {
  transition: all 0.3s cubic-bezier(1, 0.5, 0.8, 1);
}

.slide-fade-enter-from, .slide-fade-leave-to {
  transform: translateY(-10px);
  opacity: 0;
}

.switch {
    position: relative;
    display: inline-block;
    width: 38px;
    height: 20px;
  }

  .switch input { 
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #ccc;
    -webkit-transition: .4s;
    transition: .4s;
  }

  .slider:before {
    position: absolute;
    content: "";
    height: 16px;
    width: 16px;
    left: 3px;
    bottom: 2px;
    background-color: white;
    -webkit-transition: .4s;
    transition: .4s;
  }

  input:checked + .slider {
    background-color: #0d9488;
  }

  input:disabled + .slider {
    background-color: #eeeeee;
  }

  input:focus + .slider {
    box-shadow: 0 0 1px #0d9488;
  }

  input:checked + .slider:before {
    -webkit-transform: translateX(16px);
    -ms-transform: translateX(16px);
    transform: translateX(16px);
  }

</style>