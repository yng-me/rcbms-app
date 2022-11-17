<script lang="ts" setup>

import { reactive } from '@vue/reactivity';

// @ts-ignore
import ChangeLogItem from './ChangeLogItem.vue';

const changeLogs = reactive([
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
])

</script>

<template>
    <div class="px-4">
        <div class="bg-white rounded-xl overflow-hidden">
            <div class="pl-5 py-3 pr-4 flex justify-between w-full bg-gray-50 border-b">
                <div class="uppercase tracking-wider text-sm font-semibold">ChangeLog</div>
                <button 
                    @click.prevent="$emit('close')" 
                    title="Quit"
                    class="p-1 rounded-lg hover:bg-gray-100 hover:text-red-500">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                </button>
            </div>
            <div class="gap-6 overflow-auto " style="max-height: 600px !important">
                <div v-for="(i, index) in changeLogs" :key="index" class="px-5 py-3 border-t">
                    <ChangeLogItem :item="i" :order="index" />
                </div>
            </div>
        </div>
    </div>
</template>