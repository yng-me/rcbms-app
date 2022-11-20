<script lang="ts" setup>

import { computed, reactive, ref } from 'vue';
import { ipcRenderer } from '../electron'
import { RConfig, UpdateConfig } from '../utils/types'

// @ts-ignore
import Configuration from './Configuration.vue';

const isWritingFile = ref(false)
const showMenu = ref(false)

const props = defineProps(['checks'])

const rConfig = reactive<RConfig>({
  run_after_edit: false,
  use_rdata: false,
  include_justifiction: false,
  clear: false,
  convert_to_rdata: true,
  use_raw_data_from_tablet: false,
  use_pilot_data: false
})

const show = ref(false)
const modal = reactive({
  title: '',
  message: ''
})

const prompt = [
  { id: 'use_rdata', title: 'Use RData', message: 'No RData available. Check C:/rcmbs/data folder.' },
  { id: 'run_after_edit', title: 'Run after-edit checks', message: 'No data available.' },
  { 
    id: 'include_justifiction', 
    title: 'Include justifications', 
    message: 'Cannot locate justification file. Please save it in C:/rcmbs/references. Rename it to justification.xlsx' 
  },
  { id: 'clear', title: 'Clear data', message: 'No available data to clear.' },
  { id: 'before_edit_path', title: 'Tablet data', message: 'No available data to.' },
]

const emit = defineEmits(['updateConfig'])

const updateConfigR = (config : string, val: keyof RConfig) => {

  if(!props.checks[config].isAvailable) {

    const msg : any = prompt.find(el => el.id === val)
    const msgPrompt = `${msg.title}: ${msg.message}`
    alert(msgPrompt)

    rConfig[val] = false

  } else {
    
      isWritingFile.value = true
      emit('updateConfig', {
        key: val,
        val: rConfig[val]
      })
      ipcRenderer.send('update-r-config', { ...rConfig })

  }
}

ipcRenderer.on('mounted', (event, data) => {
  rConfig.use_rdata = data.rConfig.use_rdata
  rConfig.run_after_edit = data.rConfig.run_after_edit
  rConfig.convert_to_rdata = data.rConfig.convert_to_rdata
  rConfig.include_justifiction = data.rConfig.include_justifiction
  rConfig.clear = data.rConfig.clear
  rConfig.use_raw_data_from_tablet = data.rConfig.use_raw_data_from_tablet,
  rConfig.use_pilot_data = data.rConfig.use_pilot_data
})

ipcRenderer.on('yaml-config-saved', () => isWritingFile.value = false)

const viewStatus = ref(false)

const checksConfig = computed(() => {
  const keys = Object.keys(props.checks)
  return keys.filter(el => el !== 'withData' && el != 'csdbeCheck' && el != 'textDataCheck')
    .map(item => {

      let path = props.checks[item].path ? props.checks[item].path : ''

      if (path.length > 45) {
        path = path.substr(0, 25) + '...' + path.substr(path.length-20, path.length);
      }
      
      return {
        isAvailable: props.checks[item].isAvailable,
        path,
        label: props.checks[item].label,
        property: props.checks[item].property,
        config: props.checks[item].key
      }
    })
})

const loadingConfig = ref(false)
ipcRenderer.on('saved-path-config', (event, name) => {
    setTimeout(() => {
      loadingConfig.value = false
    }, 1000);
})

</script>

<template>
    <nav class="absolute top-3 right-4 text-gray-400 z-40">
      <div class="flex items-center space-x-1">
        <slot></slot>
        <button 
          @click.prevent="showMenu = !showMenu"
          :class="showMenu ? 'text-gray-100' : ''"
          title="Settings"
          class="hover:text-teal-600 transform hover:rotate-12">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
        </button>
        <slot name="tabulation"></slot>
        <a href="https://cbmsr.app" target="_blank"
          title="Help (go to CBMSr)"
          class="hover:text-teal-600 transform hover:rotate-45">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        </a>

        <!-- <button 
          @click.prevent="showMenu = !showMenu"
          :class="showMenu ? 'text-gray-100' : ''"
          title="Settings"
          class="hover:text-teal-600 transform hover:rotate-12">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
        </button> -->


      </div>
    </nav>
    <transition name="slide-fade">
      <div v-if="showMenu" class="absolute right-4 top-10 z-50">
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
                  <span>Configuration</span>
                </button>
              </div>
              <span v-if="isWritingFile" class="p-1 flex items-center justify-center">
                  <span class="w-4 h-4 border-l border-teal-500 rounded-full animate-spin"></span>
              </span>
              <button v-else @click.prevent="showMenu = false" class="hover:bg-gray-100 hover:text-red-500 p-1 rounded-lg" title="Quit">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
              </button>
            </div>
            <template v-if="viewStatus">
              <ul class="w-full">
                <template v-for="(i, index) in checksConfig" :key="index">
                  <Configuration 
                    @saving-config="loadingConfig = true"
                    :loading-config="loadingConfig"
                    :is-available="i.isAvailable" 
                    :title="i.label"
                    :description="i.path"
                    :isPilotMode="rConfig.use_pilot_data"
                    :property="i.property"
                    :config="i.config"
                  />
                </template>
              </ul>
            </template>
            <template v-else>
              <label :class="rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path></svg>
                  <span>Use Rdata file</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withRData', 'use_rdata')" 
                    v-model="rConfig.use_rdata"
                    :disabled="rConfig.use_pilot_data" 
                    name="use-rdata" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_rdata || rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>
                  <span >Use raw data from tablet</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withDownloadedData', 'run_after_edit')" 
                    v-model="rConfig.use_raw_data_from_tablet" 
                    :disabled="rConfig.use_rdata || rConfig.use_pilot_data"
                    name="run-after-edit" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path></svg>
                  <span >Run after-edit checks</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withEditedData', 'run_after_edit')" 
                    v-model="rConfig.run_after_edit" 
                    :disabled="rConfig.use_pilot_data"
                    name="run-after-edit" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9"></path></svg>
                  <span>Include justifications</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withJustification', 'include_justifiction')" 
                    v-model="rConfig.include_justifiction"
                    :disabled="rConfig.use_pilot_data"
                    name="include-justifiction" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_rdata || rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path></svg>
                  <span>Convert to Rdata</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withRData', 'use_rdata')" 
                    v-model="rConfig.convert_to_rdata" 
                    :disabled="rConfig.use_rdata || rConfig.use_pilot_data"
                    name="use-rdata" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_rdata || rConfig.use_pilot_data? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 13h6M3 17V7a2 2 0 012-2h6l2 2h6a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2z"></path></svg>
                  <span>Clear data files after execution</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withData', 'clear')" 
                    :disabled="rConfig.use_rdata || rConfig.use_pilot_data"
                    v-model="rConfig.clear" 
                    name="clear" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
              <label :class="rConfig.use_rdata? 'text-gray-300' : 'hover:bg-gray-50'" class="px-4 py-2.5 border-t w-full flex items-center justify-between">
                <span class="flex items-center space-x-2">
                  <svg class="w-4 h-4 opacity-30" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"></path></svg>
                  <span>Use 2021 Pilot CBMS data</span>
                </span>
                <span class="switch">
                  <input 
                    @change="updateConfigR('withPilotData', 'use_pilot_data')" 
                    :disabled="rConfig.use_rdata"
                    v-model="rConfig.use_pilot_data" 
                    name="clear" 
                    type="checkbox" 
                  />
                  <span class="slider round"></span>
                </span>
              </label>
            </template>
        </div>
      </div>
    </transition>
    <div @click.prevent="showMenu = false" v-if="showMenu"  class="z-10 absolute inset-0 bg-stone-700 opacity-75"></div>
</template>



<style>
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

  /* Rounded sliders */
  .slider.round {
    border-radius: 25px;
  }

  .slider.round:before {
    border-radius: 50%;
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
</style>