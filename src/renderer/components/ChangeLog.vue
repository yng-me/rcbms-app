<script lang="ts" setup>

const changeLogs = [
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

const bg : any = {
    feature: 'bg-teal-600',
    'bug fix': 'bg-red-600'
}

</script>

<template>
    <div class="px-4">
        <div class="bg-white rounded-xl overflow-hidden">
            <div class="pl-5 py-3 pr-4 flex justify-between w-full bg-gray-50">
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
                    <h2 class="inline-flex space-x-1 items-baseline tracking-wider">
                        <span class="text-lg font-semibold text-teal-600">{{ i.version }}</span>
                        <span class="text-gray-400">&bull;</span>
                        <span class="text-sm">{{ i.releaseDate }}</span>
                    </h2>
                    <ul class="pt-4 tracking-wide">
                        <li v-for="j in i.logs" :key="j.feature" class="pb-6 pt-1">
                            <span class="inline-flex space-x-2 items-center font-semibold">
                                <span :class="bg[j.type]" class="uppercase tracking-wide font-mono text-xs px-2 py-px rounded-xl text-white">
                                    {{ j.type }}
                                </span>
                                <span class="">{{ j.feature }}</span>
                            </span>
                            <ul v-for="k in j.info" :key="k" class="space-y-1 list-disc px-6 ">
                                <li v-html="k" class="py-1 text-sm"></li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</template>