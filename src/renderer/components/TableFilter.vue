<script lang="ts" setup>

import { reactive, computed, PropType, ref, watch } from "vue"
import { Geo } from '../utils/types'
// @ts-ignore
import BaseModal from "./BaseModal.vue";
// @ts-ignore
import Dialog from "./Dialog.vue";

import { Codemirror } from 'vue-codemirror'

const code = ref('')
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

const showAdvancedFilter = ref(false)

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
            <span class="text-xs">BASIC FILTER</span>
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
        <div class="border-t px-5 py-2.5 flex justify-between space-x-2 bg-gray-50">
            <button @click.prevent="showAdvancedFilter = true" class="text-xs uppercase flex items-center space-x-0.5 tracking-widest font-medium text-gray-500 hover:text-teal-600">
                <span>Advanced</span>
                <svg class="w-3.5 h-3.5 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path></svg>
            </button>
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
    <BaseModal @close="showAdvancedFilter = false" :show="showAdvancedFilter" usage="dialog" max-width="xl">
        <Dialog @close="showAdvancedFilter = false" title="Advanced Filter">
            <div class="px-5 flex space-x-3 items-center text-xs py-2 text-gray-500">
                <button class="text-xs uppercase font-semibold tracking-widest hover:text-teal-600">Select</button>
                <button class="text-xs uppercase font-semibold tracking-widest hover:text-teal-600">Code</button>
                <button class="text-xs uppercase font-semibold tracking-widest hover:text-teal-600">Options</button>
            </div>
            <div class="px-5 pt-2 pb-4">
                <div class="border">

                    <!-- <textarea class="w-full rounded-xl focus:border-teal-600 border-gray-300" rows="10" /> -->
                    <Codemirror
                    v-model="code"
                    placeholder="Code goes here..."
                    :style="{ height: '275px' }"
                    :autofocus="true"
                    :indent-with-tab="true"
                    :tab-size="2"
                    />
                </div>
            </div>
            <div class="border-t px-5 justify-end py-2.5 flex space-x-2 bg-gray-50">
                    <!-- <div class="flex items-center space-x-2">
                        <div v-if="progress == 'Saving...'" class="flex items-center justify-center">
                            <div class="w-5 h-5 border-l border-teal-600 rounded-full animate-spin"></div>
                        </div>
                        <svg v-else-if="progress == 'Saved'" class="w-5 h-5 opacity-50 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                        <span>{{ progress }}</span>
                    </div> -->
                    <div class="flex space-x-2 items-center">            
                        <button 
                            @click.prevent="showAdvancedFilter = false"
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                        <button 
                            :disabled="false"
                            :class="false ? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                            class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-gradient-to-tr">
                            Save
                        </button>
                    </div>
                </div>
        </Dialog>
    </BaseModal>
</template>