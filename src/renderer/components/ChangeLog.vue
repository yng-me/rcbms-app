<script lang="ts" setup>

import { reactive, ref } from '@vue/reactivity';

// @ts-ignore
import ChangeLogItem from './ChangeLogItem.vue';

type Mode = 'changelog' | 'upcoming'

const changeLogs = [
    {
        version: 'RCBMS v1.0.10',
        releaseDate: '23 December 2022',
        logs: [
            { 
                feature: 'R script',
                type: 'bug fix',
                info: [
                    'Fixed R script of Sections G and P.'
                ]
            },
            {
                feature: 'Merging of csdbe files from tablet and DPS',
                type: 'enhancement',
                info: [
                    'Concatenated csdbe files taken from tablet (after loading from RCBMS) can now be merged/concatenated with csdbe files downloaded from DPS.',
                ]
            },
        ]  
    },
    {
        version: 'RCBMS v1.0.9',
        releaseDate: '10 December 2022',
        logs: [
            {
                feature: 'Sortable tables in the Data Tabulation module',
                type: 'enhancement',
                info: [
                    'Output tables can now be sorted based on selected row and/or grouping variables.',
                ]
            },
            {
                feature: 'Dynamic Ouput Folder location',
                type: 'enhancement',
                info: [
                    'All output files generated (either Export Logs or List of Cases with Inconsistencies) is now be based on the Output Folder configuration.',
                ]
            },
            {
                feature: 'Minimize/maximize window states',
                type: 'enhancement',
                info: [
                    'When generating inconsistencies, you can now minimize the pop-up window so you can access other features of RCBMS while waiting for the execution to finish.',
                    'You can now also maximize the entire window of RCBMS for maximum productivity.'
                ]
            },
            { 
                feature: '2021 Pilot CBMS module',
                type: 'bug fix',
                info: [
                    'Fixed R script of Sections J, L, and Q.',
                    'Show error prompt when loading csdb with incorrect file name.'
                ]
            }
        ]  
    },
    {
        version: 'RCBMS v1.0.8',
        releaseDate: '28 November 2022',
        logs: [
            {
                feature: 'DPS Manual', 
                type: 'news',
                info: [
                    'The 2022 CBMS Data Processing System (DPS) Manual is now available in <span class="font-semibold">CBMS Resources</span> at <a href="https://cbmsr.app/dps/" target="_blank" class="font-semibold text-teal-600">https://cbmsr.app/dps</a>'
                ]
            },
            {
                feature: 'Allow mutliple justification files from different DPs',
                type: 'enhancement',
                info: [
                    'Instead on one (1) Excel justification file, you can now load multiple files.',
                    'Make sure to save all justification files in one folder and set the correct path from the Settings menu > Configuration tab > Justification file path.'
                ]
            },
            {
                feature: 'Export Logs reset',
                type: 'bug fix',
                info: [
                    'Export logs will now be appended everytime you generate cases with inconsistencies.'
                ]
            },
            { 
                feature: 'R Script 2021 Pilot CBMS',
                type: 'enhancement',
                // info: [
                //     'Removed Priority C and add '
                // ]
            }
        ]  
    },
    {
        version: 'RCBMS v1.0.7',
        releaseDate: '23 November 2022',
        logs: [ 
            {
                feature: 'Mismatch data type in justification reference file',
                type: 'bug fix',
                info: [
                    // 'Fixed error when generating inconsistencies with Excel justification file.',
                ]
            },
        ]  
    },
    {
        version: 'RCBMS v1.0.6',
        releaseDate: '22 November 2022',
        logs: [ 
            {
                feature: 'Cross tabulation of distinct record types',
                type: 'enhancement',
                info: [
                    'You can now cross tabulate two distinct record types or sections. Just join them by defining common variables present in these records, like <span class="font-semibold">Case ID</span> or <span class="font-semibold">Line Number</span>.'
                ]
            },
            {
                feature: 'Justification file not detected',
                type: 'bug fix',
                info: [
                    'Fixed error when generating inconsistencies with Excel justification file.',
                    'Make sure also to retain the original tab/sheet name, which is <span class="font-semibold">Cases with Inconsistencies</span>.'
                ]
            },
        ]  
    },
    {
        version: 'RCBMS v1.0.5',
        releaseDate: '21 November 2022',
        logs: [ 
            {
                feature: 'Integration with 2021 Pilot CBMS',
                type: 'feature',
                info: [
                    '2021 Pilot CBMS data can now be loaded to RCBMS to generate list of cases with inconsistencies',
                    'To enable the feature, go to Settings > Options > toggle ON the <span class="font-semibold">Use 2021 Pilot CBMS data<span>.',
                    'You will be prompted to load the data file. Go to Settings > Configuration > define the <span class="font-semibold">2021 Pilot CBMS data folder</span>.'
                ]
            },
            {
                feature: 'Mismatch EA number',
                type: 'bug fix',
                info: [
                    'EA number generated in Excel file is now consistent with the Case ID.',
                ]
            },
        ]  
    },
    {
        version: 'RCBMS v1.0.4',
        releaseDate: '18 November 2022',
        logs: [ 
            {
                feature: 'Rdata configuration',
                type: 'enhancement',
                info: [
                    'The Rdata file path configuration now only accepts valid Rdata format/extension to avoid unexpected errors.'
                ]
            },
            {
                feature: 'Execution progress',
                type: 'bug fix',
                info: [
                    'If installation of R packages fails, the execution process will now be terminated.',
                ]
            },
        ]  
    },
    {
        version: 'RCBMS v1.0.3',
        releaseDate: '12 November 2022',
        logs: [ 
            {
                feature: 'Detect the latest CSPro installation',
                type: 'enhancement',
                info: [
                    'CSPro 7.7 will be selected as default.',
                    'If you have more than one installation of CSPro, it will no longer cause a problem.'
                ]
            },
            {
                feature: 'R Script and Excel output file',
                type: 'bug fix',
                info: [
                    'Re-instated missing values in the <span class="font-medium">Line Number</span> column of the Excel output file.',
                    'Section M, item 16 to allow zero (0) answer.',
                    'Fixed title and despcription for Section L, item 33.'
                ]
            }
        ]  
    },
    {
        version: 'RCBMS v1.0.2',
        releaseDate: '12 November 2022',
        logs: [ 
            {
                feature: 'Select csdbe files to extract',
                type: 'feature',
                info: [
                    'Before extracting the csdbe files, you can now pick specific file/s you want to include in the generation of list of cases with inconsistencies.',
                    'If these files were downloaded directly from the tablet, however, a minimum of 10 csdbe files is still required.'
                ]
            },
            // {
            //     feature: 'Dependency version requirements',
            //     type: 'enhancement',
            //     info: [
            //         'To prevent unexpected errors, you are no longer allowed to proceed if you have not installed the minimun versions of R and RStudio required by RCBMS.',
            //     ]
            // },
            {
                feature: 'Null data dictionary records',
                type: 'bug fix',
                info: [
                    'Excluded record types and items in the data dictionary file which caused error in extracting csdbe files and consequently produced null values when concatenating.'
                ]
            }
        ]  
    },
    {
        version: 'RCBMS v1.0.1',
        releaseDate: '09 November 2022',
        logs: [
            { 
                feature: 'Automatic system update',
                type: 'feature',
                info: [
                    'Starting <span class="font-semibold">v1.0.1</span>, all system updates will be automatically detected once available.',
                    'Updates will be applied at the next launch of RCBMS. When exiting the app, you will be prompted to proceed with the installation of update. Make sure to click "Yes."'
                ]
            },
            { 
                feature: 'Load data using csdbe files downloaded directly from tablet',
                type: 'feature',
                info: [
                    'If you are loading the csdbe data files downloaded directly from the tablet, make sure to configure the settings properly.',
                    'Click <svg class="w-4 h-4 inline opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg> (Settings). Make sure you are on the <span class="font-semibold">Options</span> tab, and then toggle ON the <span class="font-semibold">Use raw data from tablet</span>.',
                    'Please also make sure to have a <span class="font-semibold">minimum of 10</span> csdbe data files (HPQ) to load; otherwise, the system will not allow you to proceed.'
                ]
            },
            { 
                feature: 'R Script',
                type: 'bug fix',
                info: [
                    'Fixed mismatch data types in <span class="font-semibold">cross-section.qmd</span> and <span class="font-semibold">section-l.qmd</span>.'
                ]
            }
        ]
    }
]

const upcomingFeatures = [
    'Creating derived variables and post calculations in the Data Tabulation module.',
    'Saving and exporting tables into an Excel file.',
    'Advanced filter and grouping of variables.',
    'Select only sections you want to be included in the output when generating cases with inconsistencies.',
    'Integration of 2021 Pilot CBMS tabulation features.'
]

const depractedFeatures = [
    'HTML output generated by Quarto which will be replaced by custom UI design.',
    'Using RData file format which will be replaced by Arrow Parquet file format.'
]

const mode = ref<Mode>('changelog')


</script>

<template>
    <div class="px-4">
        <div class="bg-white rounded-xl overflow-hidden">
            <div class="pl-5 py-3 pr-4 flex items-center justify-between w-full bg-gray-50">
                <div class="flex items-center space-x-4">
                    <button 
                        @click.prevent="mode = 'changelog'" 
                        :class="mode === 'changelog' ? '' : 'text-gray-400'"
                        class="uppercase tracking-wider text-sm font-medium">
                        ChangeLog
                    </button>
                    <button 
                        @click.prevent="mode = 'upcoming'" 
                        :class="mode === 'upcoming' ? '' : 'text-gray-400'"
                        class="uppercase tracking-wide text-sm font-medium">
                        Upcoming Releases
                    </button>
                </div>
                <button 
                    @click.prevent="$emit('close')" 
                    title="Quit"
                    class="p-1 rounded-lg hover:bg-gray-100 hover:text-red-500">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>
            <div class="gap-6 overflow-auto" style="max-height: 650px !important">
                <template v-if="mode == 'changelog'">
                    <div v-for="(i, index) in changeLogs" :key="index" class="border-t px-5 py-3">
                        <ChangeLogItem :item="i" :order="index" />
                    </div>
                </template>
                <div v-if="mode == 'upcoming'" class="p-6 space-y-8 border-t">
                    <div class="space-y-2">
                        <h3 class="text-teal-600 font-semibold tracking-wider text-xs uppercase">Upcoming Features</h3>
                        <div v-for="(i, index) in upcomingFeatures" :key="index">
                            <span class="flex space-x-2 items-center">
                                <svg class="w-5 h-5 text-teal-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                <span>{{ i }}</span>
                            </span>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <h3 class="text-red-600 font-semibold tracking-wider text-xs uppercase">Features to be depracated</h3>
                        <div v-for="(i, index) in depractedFeatures" :key="index">
                            <span class="flex space-x-2 items-center">
                                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                                <span>{{ i }}</span>
                            </span>
                        </div>
                    </div>
                    <div class="pt-4 border-t">
                        Please contact us for a <span class="text-teal-600 font-medium">feature request</span>.
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>