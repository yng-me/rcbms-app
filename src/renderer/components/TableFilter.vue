<script lang="ts" setup>

import { reactive, computed, PropType, ref, watch } from "vue"
import { Geo } from '../utils/types'

const props = defineProps({
    geo: {
        type: Array as PropType<Geo[]>,
        required: true
    },
    showFilter: Boolean
})

const geoFilter = reactive<Geo>({
    city_mun: '',
    province: '',
    brgy: ''
})


const provinces = computed(() => {
    return [...new Set(props.geo.map(el => el.province))]
})

const cityMun = computed(() => {
    const cm = props.geo.filter(el => el.province === geoFilter.province)    
    return [...new Set(cm.map(item => item.city_mun))]
})

const brgys = computed(() => {
    const bg = props.geo.filter(el => el.province === geoFilter.province && el.city_mun === geoFilter.city_mun)
    return [...new Set(bg.map(item => item.brgy))]
})

const emit = defineEmits(['closeFilter', 'filterApplied'])

const pulse = ref(false)

const filterApplied = () => {
    
    if(valueChanged) valueChanged.value = false

    pulse.value = true
    emit('filterApplied', { ...geoFilter })
    setTimeout(() => {
        pulse.value = false
    }, 1000);
}

const valueChanged = ref(false)

watch(
    () => geoFilter, 
    () => valueChanged.value = true,
    { deep: true }
)

</script>

<template>
    <div v-show="showFilter" class="border rounded-xl bg-white shadow-xl space-y-4 overflow-hidden w-96">
        <h2 class="pl-5 pr-4 py-2 border-b flex tracking-widest uppercase items-center justify-between">
            <span class="text-xs">FILTER</span>
            <button 
                @click.prevent="$emit('closeFilter')"
                title="Quit"
                class="p-1 rounded-lg hover:text-red-600">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </h2>
        <div class="px-5 flex flex-col space-y-1">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Province</label>
            <select 
                @change="[geoFilter.city_mun = '', geoFilter.brgy = '']"
                v-model="geoFilter.province" 
                class="px-3.5 py-1.5 w-full focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option value="">-- Select Province --</option>
                <option v-for="(i, index) in provinces" :key="index" :value="i">{{ i }}</option>
            </select>
        </div>
        
        <div class="px-5 flex flex-col space-y-1">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">City/Municipality</label>
            <select name="" id="" 
                @change="geoFilter.brgy = ''"
                v-model="geoFilter.city_mun" 
                :disabled="geoFilter.province == ''" 
                :class="geoFilter.province == '' ? 'bg-gray-100 text-gray-400' : ''"
                class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option value="">-- Select City/Municipality --</option>
                <option v-for="(i, index) in cityMun" :key="index" :value="i">{{ i }}</option>
            </select>
        </div>
        <div class="px-5 flex flex-col space-y-1">
            <label for="" class="text-xs tracking-widest text-gray-500 uppercase font-semibold">Barangay</label>
            <select name="" id="" 
                v-model="geoFilter.brgy" 
                :disabled="geoFilter.province == '' || geoFilter.city_mun == ''" 
                :class="geoFilter.province == '' || geoFilter.city_mun == ''? 'bg-gray-100 text-gray-400' : ''"
                class="px-3.5 py-1.5 focus:ring-teal-600 focus:border-teal-600 rounded-xl text-sm border-gray-300">
                <option value="">-- Select Barangay --</option>
                <option v-for="(i, index) in brgys" :key="index" :value="i">{{ i }}</option>
            </select>
        </div>
        <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50">
            <!-- <button class="text-xs uppercase tracking-widest font-medium hover:text-teal-600">
                Advanced 
            </button> -->
            <div class="flex space-x-2 items-center">            
                <button 
                    @click.prevent="$emit('closeFilter')" 
                    class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                <button 
                    :disabled="!valueChanged"
                    @click.prevent="filterApplied"
                    :class="[
                        !valueChanged? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700',
                        pulse ? 'animate-pulse' : ''
                    ]"
                    class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-gradient-to-tr">
                    Apply
                </button>
            </div>
        </div>
    </div>
</template>