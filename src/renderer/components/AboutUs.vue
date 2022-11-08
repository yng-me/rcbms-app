<script lang="ts" setup>

const infoLead : any = [
    { name: 'Pat San Buenaventura', role: 'Supervisor', avatar: 'pat.jpg' },
    { name: 'Bhas Abdulsamad', role: 'Lead Developer', avatar: 'ba.jpg' }
]

const infoDev : any = [
    { name: 'Jet Curioso', role: 'Developer / Code Reviewer', avatar: 'jet.jpg' },
    { name: 'Fritz Taong', role: 'Tester / R Script Writer', avatar: 'fritz.jpg' },
    { name: 'Mark Basay', role: 'Tester / R Script Writer', avatar: 'mark.jpg' },
]

const infoRWriter = [
    { name: 'Ella Bereña', role: 'Reviewer / R Script Writer', avatar: 'ella.jpg' },
    { name: 'Czar Blanco', role: 'R Script Writer', avatar: 'czar.png' },
    { name: 'Lea Chavez', role: 'R Script Writer', avatar: 'lea.jpg' },
    { name: 'Riza Calixtro', role: 'R Script Writer', avatar: 'riza.jpg' },
    { name: 'Keziah Odtujan', role: 'R Script Writer', avatar: 'keziah.jpg' },
    { name: 'Joanna Sabino', role: 'R Script Writer', avatar: 'joanna.jpg' },
    { name: 'Arlyn Gozun', role: 'R Script Writer', avatar: 'arlyn.jpg' },
    { name: 'Jasper Velasco', role: 'R Script Writer', avatar: 'jasper.jpg' },
]

const techSupport = [
    { goTo: 'mailto:aeabdulsamad.cbsd@gmail.com', media: 'Email Address', info: 'aeabdulsamad.cbsd@gmail.com', icon: '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>' },
    { goTo: 'tel:8376 1909', media: 'Telephone Number', info: '8376 1909', icon: '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>' },
    { goTo: 'tel:0905 467 0809', media: 'Phone Number', info: '0905 467 0809', icon: '<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>' },
]

</script>


<template>
    <div class="bg-white rounded-xl overflow-hidden">
        <div class="pl-6 py-3 pr-5 flex justify-between w-full bg-gray-50">
            <div class="">About <span class="font-mono">R</span>CBMS</div>
            <button 
                @click.prevent="$emit('close')" 
                title="Quit"
                class="p-1 rounded-lg hover:bg-gray-100 hover:text-red-500">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>
        </div>
        <div class="px-6 border-t pb-2 pt-4 flex justify-between w-full">
            <h1 class="tracking-wide"><span class="font-mono">R</span>CBMS Team</h1>
        </div>
        <div class="px-6 pt-4 pb-6 grid grid-cols-3 gap-6">
            <div v-for="(i, index) in infoLead" :key="index" class="flex items-center space-x-2">
                <div class="h-14 w-14 shrink-0 bg-gray-100 border rounded-2xl overflow-hidden">
                    <img :src="`./avatar/${i.avatar}`" alt="">
                </div>
                <div class="">
                    <p class="text-xs uppercase text-teal-700 whitespace-nowrap font-semibold tracking-widest">{{ i.name }}</p>
                    <p class="text-gray-500" style="font-size: 11px">{{ i.role }}</p>
                </div>
            </div>
        </div>
        <div class="px-6 border-t border-dashed border-gray-200 py-6 grid grid-cols-3 gap-6">
            <div v-for="(i, index) in infoDev" :key="index" class="flex items-center space-x-2">
                <div class="h-14 w-14 shrink-0 bg-gray-100 border rounded-2xl overflow-hidden">
                    <img :src="`./avatar/${i.avatar}`" alt="">
                </div>
                <div class="">
                    <p class="text-xs uppercase text-teal-700 whitespace-nowrap font-semibold tracking-widest">{{ i.name }}</p>
                    <p class="text-gray-500" style="font-size: 11px">{{ i.role }}</p>
                </div>
            </div>
        </div>
        <div class="px-6 border-t border-dashed border-gray-200 py-6 grid grid-cols-3 gap-6">
            <div v-for="(i, index) in infoRWriter" :key="index" class="flex items-center space-x-2">
                <div class="h-14 w-14 shrink-0 bg-gray-100 border rounded-2xl overflow-hidden">
                    <img :src="`./avatar/${i.avatar}`" alt="">
                </div>
                <div class="">
                    <p class="text-xs uppercase text-teal-700 whitespace-nowrap font-semibold tracking-widest">{{ i.name }}</p>
                    <p class="text-gray-500" style="font-size: 11px">{{ i.role }}</p>
                </div>
            </div>
        </div>
        <div class="pt-3 pb-4 border-t px-6 border-gray-200 space-y-3 bg-gray-50">
            <h2 class="tracking-wide">Technical Support</h2>
            <div class="flex gap-x-8">
                <div v-for="(i, index) in techSupport" :key="index" class="flex items-center space-x-2">
                    <span v-html="i.icon" class="text-gray-400"></span>
                    <!-- <div class=""> -->
                        <a :href="i.goTo" class="text-xs text-teal-700 hover:text-teal-500 whitespace-nowrap font-semibold tracking-widest">{{ i.info }}</a>
                        <!-- <p class="text-gray-500" style="font-size: 11px">{{ i.info }}</p> -->
                    <!-- </div> -->
                </div>
            </div>
        </div>
    </div>
</template>