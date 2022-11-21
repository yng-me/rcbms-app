<script lang="ts" setup>

import { watch, reactive, PropType, ref } from "vue"
import { TableOptions, TableOptionsGrouping } from '../utils/types'

const props = defineProps({
    tableOptions: {
        type: Object as PropType<TableOptions>,
        required: true
    },
    showGroup: Boolean
})

const grouping = reactive<TableOptionsGrouping>({
    province: false,
    city_mun: false,
    brgy: false,
    ean: false
})

const emit = defineEmits(['closeGroup', 'groupingApplied'])

const pulse = ref(false)



const applyGrouping = () => {
    
    if(valueChanged) valueChanged.value = false

    pulse.value = true
    emit('groupingApplied', { ...grouping })
    setTimeout(() => {
        pulse.value = false
    }, 1000);
}


const valueChanged = ref(false)

watch(
    () => grouping, 
    () => valueChanged.value = true,
    { deep: true }
)

</script>


<template>
    <div v-show="showGroup" class="border tracking-wide rounded-xl bg-white shadow-xl space-y-4 overflow-hidden w-96">
        <div class="space-y-3">
            <h2 class="pl-5 pr-4 py-2 border-b flex tracking-widest uppercase items-center justify-between">
                <span class="text-xs">GROUPING</span>
                <button 
                    @click.prevent="$emit('closeGroup')"
                    title="Quit"
                    class="p-1 rounded-lg hover:text-red-600">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </h2>
            <label for="gProv" 
                :class="tableOptions.row === 'province' || tableOptions.col === 'province' ? 'text-gray-500 opacity-30' : ''"
                class="px-5 flex items-center space-x-2">
                <input 
                    :disabled="tableOptions.row === 'province' || tableOptions.col === 'province'" 
                    v-model="grouping.province" 
                    type="checkbox" name="gProv" id="gProv" class="rounded text-teal-600" 
                />
                <span>Province</span>
            </label>
            <label 
                :class="tableOptions.row === 'city_mun' || tableOptions.col === 'city_mun' ? 'text-gray-500 opacity-30' : ''"
                for="gCityMun" class="px-5 flex items-center space-x-2">
                <input 
                    :disabled="tableOptions.row === 'city_mun' || tableOptions.col === 'city_mun'" 
                    v-model="grouping.city_mun" 
                    type="checkbox" name="gCityMun" id="gCityMun" class="rounded text-teal-600" 
                />
                <span>City/Municipality</span>
            </label>
            <label 
                :class="tableOptions.row === 'brgy' || tableOptions.col === 'brgy' ? 'text-gray-500 opacity-30' : ''"
                for="gBrgy" class="px-5 flex items-center space-x-2">
                <input 
                    :disabled="tableOptions.row === 'brgy' || tableOptions.col === 'brgy'" 
                    v-model="grouping.brgy" 
                    type="checkbox" name="gBrgy" id="gBrgy" class="rounded text-teal-600" 
                />
                <span>Barangay</span>
            </label>
            <label 
                :class="tableOptions.row === 'ean' || tableOptions.col === 'ean' ? 'text-gray-500 opacity-30' : ''" for="gEA" class="px-5 flex items-center space-x-2">
                <input :disabled="tableOptions.row === 'ean' || tableOptions.col === 'ean'" 
                v-model="grouping.ean" 
                type="checkbox" name="gEA" id="gEA" class="rounded text-teal-600">
                <span>Enumeration Area (EA)</span>
            </label>
            <div class="border-t px-5 py-2.5 flex justify-end space-x-2 bg-gray-50">
                <!-- <button class="text-xs uppercase tracking-widest font-medium hover:text-teal-600">
                    Advanced 
                </button> -->
                <div class="flex space-x-2 items-center">
                    <button 
                        @click.prevent="$emit('closeGroup')" 
                        class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium whitespace-nowrap rounded-xl bg-gray-500 text-white hover:bg-gray-600">Cancel</button>
                    <button 
                        @click.prevent="applyGrouping"
                        :disabled="!valueChanged" 
                        :class="[
                            !valueChanged? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700',
                            pulse? 'animate-pulse' : ''
                        ]"
                        class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium whitespace-nowrap rounded-xl text-white bg-gradient-to-tr">
                        Apply
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>