<script setup lang="ts">

import { ipcRenderer } from '../electron'
import { onMounted, reactive, ref, onBeforeMount, computed, watch } from 'vue';
import { RConfig, UpdateConfig } from '../utils/types'

// @ts-ignore
import Dashboard from './Dashboard.vue';
// @ts-ignore
import BaseModal from './BaseModal.vue'
// @ts-ignore
import NavMenu from './Menu.vue'
// @ts-ignore
import DialogBox from './Dialog.vue'
// @ts-ignore
import Footer from './Footer.vue';
// @ts-ignore
import Hero from './Hero.vue';
// @ts-ignore
import Generate from './Generate.vue';
// @ts-ignore
import AboutUs from './AboutUs.vue'

const g = 'b13c4cbb792ef13d5a60a916'

defineEmits(['tabulate'])

// BEFORE MOUNT
const doneCopyingResources = ref(false)

interface IData  { 
  errors: any
  exportLog: any,
  csdbeList: any
}

const data = reactive<IData>({
  errors : [],
  exportLog: [],
  csdbeList: []
})

onBeforeMount(() => {
  doneCopyingResources.value = true
  ipcRenderer.send('before-mount')
})

ipcRenderer.on('done-copying-resources', (event, data) => {
  doneCopyingResources.value = !data.loading
  if(data.error) data.errors.push(data.status)
})

// MOUNTED
const rConfig = reactive<RConfig>({
  run_after_edit: false,
  use_rdata: false,
  include_justifiction: false,
  clear: false,
  convert_to_rdata: false,
  use_raw_data_from_tablet: false,
  use_pilot_data: false
})

const checks = reactive({
  withData: { isAvailable: false },
  withRData: { isAvailable: false },
  textDataCheck: { isAvailable: false },
  withDownloadedData: { isAvailable: false },
  withEditedData: { isAvailable: false },
  withJustification: { isAvailable: false },
  withOutputFolder: { isAvailable: false },
  withRInstalled: { isAvailable: false },
  withRStudioInstalled: { isAvailable: false },
  withQuartoInstalled: { isAvailable: false },
  withCSProInstalled: { isAvailable: false },
  withPilotData: { isAvailable: false }
})

const loading = ref(false)
const withParquetData = ref(false)
onMounted(() => ipcRenderer.send('mounted'))

ipcRenderer.on('mounted', (event, payload) => {

  rConfig.run_after_edit = payload.rConfig.run_after_edit
  rConfig.use_rdata = payload.rConfig.use_rdata
  rConfig.include_justifiction = payload.rConfig.include_justifiction
  rConfig.clear = payload.rConfig.clear
  rConfig.convert_to_rdata = payload.rConfig.convert_to_rdata  
  rConfig.use_raw_data_from_tablet = payload.rConfig.use_raw_data_from_tablet
  rConfig.use_pilot_data = payload.rConfig.use_pilot_data

  data.csdbeList = payload.csdbeList

  selectedCSDBE.value = payload.csdbeList.map((el : any) => el.file)

  data.errors = []

  const { withDownloadedData } = payload
  const { withEditedData } = payload
  const { textDataCheck } = payload
  const { withRData } = payload
  const { withPilotData } = payload

  const b = !payload.rConfig.run_after_edit && withDownloadedData.isAvailable
  const a = payload.rConfig.run_after_edit && withEditedData.isAvailable
  // const c = payload.rConfig.use_pilot_data && withPilotData.isAvailable

  if(!a && !b && !withRData.isAvailable && !textDataCheck.isAvailable) {
    data.errors.push({ message: 'No available data to load. Please download first from DPS Server or load the <span class="font-semibold">hpq.Rdata</span> if available.' })
  }

  data.exportLog = payload.exportLog
  checks.withData = { isAvailable: withDownloadedData.isAvailable || withEditedData.isAvailable || textDataCheck.isAvailable }
  checks.withRData = { ...withRData, label: 'Rdata file path', property: 'openFile' }
  checks.textDataCheck = textDataCheck
  checks.withDownloadedData = { ...withDownloadedData, label: 'Before-edit data folder', property: 'openDirectory' }
  checks.withEditedData = { ...withEditedData, label: 'After-edit data folder', property: 'openDirectory' }
  checks.withJustification = { ...payload.withJustification, label: 'Justification file path', property: 'openFile' }
  checks.withOutputFolder = { ...payload.withOutputFolder, label: 'Output folder location', property: 'openDirectory' }
  checks.withRInstalled = { ...payload.withRInstalled, label : 'R installation path', property: 'openFile' }
  checks.withRStudioInstalled = { ...payload.withRStudioInstalled, label: 'RStudio installation path', property: 'openFile' }
  checks.withQuartoInstalled = { ...payload.withQuartoInstalled, label: 'Quarto installation path', property: 'openFile' }
  checks.withCSProInstalled = { ...payload.withCSProInstalled, label: 'CSPro installation path', property: 'openFile' }
  checks.withPilotData = { ...withPilotData, label: '2021 Pilot CBMS data folder', property: 'openDirectory' }

  withParquetData.value = payload.withParquetData

  if(!payload.withRInstalled.isAvailable) {
    data.errors.push({
      message: 'Unable to locate installation of R.',
      url: 'https://cran.r-project.org/bin/windows/base/R-4.2.2-win.exe'
    })
  }

  if(!payload.withRStudioInstalled.isAvailable) {
    data.errors.push({
      message: 'Unable to locate installation of RStudio.',
      url: 'https://download1.rstudio.org/desktop/windows/RStudio-2022.07.2-576.exe'
    })
  }

  if(!payload.withQuartoInstalled.isAvailable && payload.withRStudioInstalled.isAvailable) {
    data.errors.push({
      message: 'Unable to locate installation of Quarto.',
      url: 'https://github.com/quarto-dev/quarto-cli/releases/download/v1.2.242/quarto-1.2.242-win.msi'
    })
  }

  if(!payload.withCSProInstalled.isAvailable) {
    data.errors.push({
      message: 'Unable to locate installation of CSPro.',
      url: 'https://www.csprousers.org/downloads/cspro/cspro7.7.3.exe'
    })
  }
  
})

const updateConfig = (event : UpdateConfig) => {
  rConfig[event.key] = event.val
}

const show = reactive({
  runScript: false,
  loadDataConfirm: false,
  loadData: false,
})

const myhalf = g + '800393e28d621d9471609fd2'

// Load data ============================================================

const loadData = () => {

    show.loadData = false
    loading.value = true
    
    setTimeout(() => {      
      if(rConfig.use_pilot_data) {
        // alert('here!')
        ipcRenderer.send('load-pilot-data')
      } else {
        ipcRenderer.send('load-data', {
          myhalf,
          check: rConfig.run_after_edit,
          files: [...selectedCSDBE.value]
        })
      }
    }, 750);
}

ipcRenderer.on('data-loaded', (event, payload) => { 
  if(!payload.error) {
    const source = rConfig.use_pilot_data ? '2021-pilot-cbms' : '2022-cbms'
    ipcRenderer.send('check-text-data', source)
  } else {
    setTimeout(() => {
      loading.value = false
      data.errors.push({
        message: payload.message
      })
    }, 1000);
  }
})

ipcRenderer.on('check-text-data', (event, data) => {
  loading.value = false
  checks.textDataCheck.isAvailable = !data.error
})


// Run R ================================================================
const loadingOutput = ref(false)
// Time elapsed
const _sec = ref(0)
const _min = ref(0)
const _hr = ref(0)


const runScript = () => {
  endTimer.value = false
  loadingOutput.value = true
  show.runScript = true
  loading.value = true

  rConfig.use_pilot_data 
    ? ipcRenderer.send('run-script-pilot') 
    : ipcRenderer.send('run-script')

  setTimeout(() => {
    _sec.value++
  }, 1000);
}

watch(_sec, (newValue) => {
  if(loading.value && !endTimer.value) {
    setTimeout(() => {
      if(newValue < 59) {
        _sec.value++
      } else {
        _sec.value = 0
        if(_min.value < 59) {
          _min.value++
        } else {
          _min.value = 0
          _hr.value++
        }
      }
    }, 1000);
  }
})

const sec = computed(() => {
  return _sec.value.toString().length == 1 ? `0${_sec.value}` : _sec.value
})

const min = computed(() => {
  return _min.value.toString().length == 1 ? `0${_min.value}` : _min.value
})

const hr = computed(() => {
  return _hr.value.toString().length == 1 ? `0${_hr.value}` : _hr.value
})


const stopProcessing = () => {
  _sec.value = 0
  _min.value = 0
  _hr.value = 0
  endTimer.value = true
  loading.value = false
  loadingOutput.value = false
  show.runScript = false
}

const cannotRunScript = computed(() => {
  return loading.value || data.errors.length > 0 || // loading or with error
  (!checks.textDataCheck.isAvailable && !rConfig.use_rdata) || // no text data
  (!checks.withRData.isAvailable && rConfig.use_rdata) || // no Rdata
  !checks.withRInstalled.isAvailable || 
  !checks.withRStudioInstalled.isAvailable || 
  !checks.withQuartoInstalled.isAvailable // R, RStudio, and Quarto not installed
})

const cannotLoadData = computed(() => {
  const before = checks.withDownloadedData.isAvailable && !rConfig.run_after_edit
  const after = checks.withEditedData.isAvailable && rConfig.run_after_edit

  // return (!before && !after) || rConfig.use_rdata
  return false
})

const endTimer = ref(true)
const doneProcessing = () => {
  loading.value = false
  endTimer.value = true
}

ipcRenderer.on('load-export-logs', (event, data) => {
  data.exportLog = data
})

//  Output preview =====================================================

const withOutputFolder = ref(false)
const openOutputFile = () => ipcRenderer.send('open-output-folder')
ipcRenderer.on('with-output-folder', (event, data) => withOutputFolder.value = data)

const refreshing = ref(false)
const refreshApp = () => {
  data.errors = []
  refreshing.value = true
  setTimeout(() => {
    refreshing.value = false
    ipcRenderer.send('mounted')
  }, 1500);
}


const loadDataDialog = () => {
  if(rConfig.use_pilot_data) {
    loadData()
  } else {
    if(checks.textDataCheck.isAvailable && !data.errors.length) {
      show.loadDataConfirm = true
    } else {
      show.loadData = true
    }
  }
}

const selectedCSDBE = ref([])
const selectAllCSDBE = ref(true)

const showLoadData = () => {
  show.loadDataConfirm = false
  setTimeout(() => {
    show.loadData = true
  }, 1000);
}

watch(selectAllCSDBE, (newValue) => {
  if(newValue === true) {
    selectedCSDBE.value = data.csdbeList.map((el : any) => el.file)
  }
  
  if(newValue === false && selectedCSDBE.value.length === data.csdbeList.length) { 
    selectedCSDBE.value = []
  }
})

watch(selectedCSDBE, (newValue) => {
  if(selectedCSDBE.value.length === data.csdbeList.length) selectAllCSDBE.value = true
  if(selectedCSDBE.value.length < data.csdbeList.length) selectAllCSDBE.value = false
})

</script>


<template>
    <div class=" y-scroll-bar">
        <NavMenu @updateConfig="updateConfig($event)" :checks="checks">
        <button 
            title="Refresh the app"
            @click.prevent="refreshApp"
            class="hover:text-teal-600 transform hover:rotate-12 ">
            <svg :class="refreshing ? 'animate-spin text-teal-600' : ''" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
        </button>
        <template #tabulation>
            <button 
            title="Tabulation" 
            :disabled="!withParquetData"
            @click.prevent="$emit('tabulate')" 
            :class="!withParquetData ? 'text-gray-300' : 'hover:text-teal-600 transform hover:rotate-12'">
            <svg class="w-5 h-5 text-current" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"></path></svg>
            </button>
        </template>
        </NavMenu>
        <Hero :isPilotMode="rConfig.use_pilot_data" />
        <div v-if="!doneCopyingResources" class="mx-auto max-w-sm mt-8">
        <p class="text-center text-xs">Loading files and folders...</p>
        </div>
        <template v-else>
          <div class="mx-auto max-w-4xl px-10 sm:flex items-center sm:space-y-0 space-y-3 gap-3 justify-center mt-3">
              <button 
                @click.prevent="loadDataDialog"
                :disabled="loading || cannotLoadData"
                :class="cannotLoadData? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                class="sm:w-auto w-full flex items-center justify-center text-xs space-x-2 rounded-xl px-4 py-2 bg-gradient-to-tr tracking-wider"
              >
                <span class=" whitespace-nowrap truncate">
                    <span v-if="checks.textDataCheck.isAvailable && !data.errors.length && !loading">{{rConfig.use_pilot_data ? 'Pilot ' : ''}}Data Loaded</span>
                    <span v-else>{{ loading ? `Loading ${rConfig.use_pilot_data ? 'Pilot' : ''} Data` : `Load ${rConfig.use_pilot_data ? 'Pilot' : ''} Data` }} </span>
                </span>
                <span v-if="loading" class="flex items-center justify-center">
                    <span class="w-3.5 h-3.5 border-l border-teal-500 rounded-full animate-spin"></span>
                </span>
                <svg v-if="(checks.textDataCheck.isAvailable && !loading && !data.errors.length)" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
              </button>
              <button 
                :disabled="cannotRunScript"
                @click.prevent="runScript"
                :class="cannotRunScript? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                title="Generate list of HPQ cases with inconsistencies using R"
                class="sm:w-auto w-full flex items-center justify-center text-xs space-x-2 rounded-xl px-4 py-2 bg-gradient-to-tr tracking-wider"
              >
                <span class=" whitespace-nowrap truncate">Generate Cases with Inconsistencies</span>
                <span v-if="loadingOutput" class="flex items-center justify-center">
                    <span class="w-3.5 h-3.5 border-l border-teal-500 rounded-full animate-spin"></span>
                </span>
              </button>
              <button 
                :disabled="!checks.withOutputFolder.isAvailable"
                @click.prevent="openOutputFile"
                :class="!checks.withOutputFolder.isAvailable ? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                title="Preview list of cases with inconsistencies (Excel file)"
                class="sm:w-auto w-full flex items-center justify-center text-xs space-x-2 rounded-xl px-4 py-2 bg-gradient-to-tr tracking-wider"
              >
                <span class=" whitespace-nowrap truncate">Open Output Folder</span>
              </button>
          </div>
          <div class="px-6">
            <div v-if="data.errors.length" class="mx-auto max-w-xl px-6 py-4 my-8 rounded-xl border border-red-200 text-red-600">
                <div class="divide-y divide-dashed">
                <div v-for="(i, index) in data.errors" :key="index" class="text-sm flex space-x-1.5 items-start py-3">
                    <span>{{ index + 1 }}. </span>
                    <p class="flex items-start w-full justify-between">
                    <span v-html="i.message"></span>
                    <a v-if="i.url" :href="i.url" class="text-xs px-3 py-1 border rounded-xl text-gray-700 hover:text-teal-600 hover:border-gray-300">Download</a>
                    </p>
                </div>
                </div>
            </div>
          </div>
          <Dashboard :is-pilot-mode="rConfig.use_pilot_data" :logs="data.exportLog" :keys="data.exportLog[0]" />
        
        </template>

        <!-- Dialog windows -->
        <BaseModal @close="show.loadDataConfirm = false" :show="show.loadDataConfirm" usage="dialog" max-width="md">
          <DialogBox 
              @close="show.loadDataConfirm = false"
              title="Extraction Option" 
              message="You already loaded the data files and it's now ready for use. <span class='font-medium'>Do you want to perform it again</span>?"
          >
          <div class="border-t px-4 py-2.5 flex justify-end space-x-2 bg-gray-100">
              <button @click.prevent="show.loadDataConfirm = false" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">Exit</button>
              <button @click.prevent="showLoadData" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl text-white bg-teal-600 hover:bg-teal-700">Proceed</button>
          </div>
          </DialogBox>
        </BaseModal>

        <BaseModal @close="show.loadData = false" :show="show.loadData" usage="dialog" max-width="2xl">
          <DialogBox @close="show.loadData = false" title="Select CSDBE Files to Extract">
            <div class="pt-4 flex flex-col space-y-4 overflow-auto max-h-96">
               <table class="w-full ">
                <thead>
                  <th class="py-1.5 pl-6 text-left font-medium">
                    <input v-model="selectAllCSDBE" type="checkbox" id="selectAll" class="text-teal-600 rounded flex items-center">
                  </th>
                  <th class="py-1.5 px-3 text-left font-medium"><label for="selectAll">File</label></th>
                  <th class="py-1.5 px-3 text-left font-medium">City/Municipality</th>
                  <th class="py-1.5 px-3 text-left font-medium">Barangay</th>
                  <th class="py-1.5 pl-3 pr-6 text-left font-medium">EA</th>
                </thead>
                <tbody>
                  <tr v-for="(i, index) in data.csdbeList" :key="index" class="border-t hover:bg-gray-100">
                    <td class="py-1.5 pl-6">
                      <input 
                        type="checkbox" 
                        v-model="selectedCSDBE" 
                        :value="i.file" :name="i.file" :id="i.file" 
                        class="text-teal-600 rounded flex items-center">
                    </td>
                    <td class="py-1.5 px-3"><label :for="i.file" class=" whitespace-nowrap">{{ i.file }}</label></td>
                    <td class="py-1.5 px-3"><label :for="i.file" class=" whitespace-nowrap">{{ i.cityMun }}</label></td>
                    <td class="py-1.5 px-3"><label :for="i.file" class=" whitespace-nowrap">{{ i.brgy }}</label></td>
                    <td class="py-1.5 pl-3 pr-6 text-center"><label :for="i.file" class=" whitespace-nowrap">{{ i.ean }}</label></td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="border-t px-4 py-2.5 flex justify-end space-x-2 bg-gray-100">
                <button @click.prevent="show.loadData = false" class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gray-500 text-white hover:bg-gray-600">
                  Cancel
                </button>
                <button 
                  :disabled="selectedCSDBE.length === 0"
                  @click.prevent="loadData" 
                  :class="selectedCSDBE.length === 0 ? 'text-gray-300 from-gray-400 to-gray-400' : 'from-teal-600 to-cyan-600 text-white hover:from-teal-700 hover:to-cyan-700'"
                  class="px-4 py-1.5 text-xs uppercase tracking-widest font-medium rounded-xl bg-gradient-to-tr">
                    Load Data
                </button>
            </div>
          </DialogBox>
        </BaseModal>

        <BaseModal @close="stopProcessing" :closeable="false" :show="show.runScript" usage="dialog" max-width="xl">
          <Generate 
              @close="stopProcessing" 
              :loading="loading" 
              @done-processing="doneProcessing"
              @stop-processing="stopProcessing"
              :time-elapsed="`${hr}:${min}:${sec}`"
          >
              <span v-if="loading" class="flex items-center space-x-1">
              <span class="text-xs text-gray-400 font-mono">{{ hr }}:{{ min }}:{{ sec }}</span>
              <span class="flex shrink-0 h-1.5 w-1.5 animate-pulse rounded-full bg-red-600"></span>
              </span>
          </Generate>
        </BaseModal>
  </div>
</template>
