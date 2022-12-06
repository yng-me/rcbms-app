<script lang="ts" setup>

import TableCard from './TableCard.vue'
// @ts-ignore
import TableButton from './TableButton.vue'

import { sidebarMenu, iconSize } from '../../assets/dashboardMenu'

</script>

<template>
    <div class="h-screen flex flex-col overflow-hidden w-full bg-gray-50">
        <header class="px-4 py-3 w-full border-b border-gray-200">
            <h1 class="font-medium tracking-wider">
                Data Tabulation
            </h1>
        </header>
        <div class="flex h-full w-full">
            <nav class="bg-gray-100 md:w-64 border-r border-gray-200 p-4">
                <div class="flex flex-col h-full justify-between">
                    <div class="flex flex-col space-y-3">
                        <template v-for="(item, index) in sidebarMenu" :key="index">
                            <TableButton :isActive="item.isActive" :label="item.label">
                                <span v-html="item.icon"></span>
                            </TableButton>
                        </template>                
                    </div>
                    <div class="pb-6 w-full">
                        <TableButton :isActive="false" label="Hide" class="w-full">                    
                            <svg :width="iconSize" :height="iconSize" viewBox="0 0 48 48"><g fill="none" stroke="currentColor" stroke-linejoin="round" stroke-width="4"><path d="M24 44c11.046 0 20-8.954 20-20S35.046 4 24 4S4 12.954 4 24s8.954 20 20 20Z"/><path stroke-linecap="round" d="m21 33l9-9l-9-9"/></g></svg>
                        </TableButton>
                    </div>
                </div>
            </nav>
            <main class="w-full p-4">
                <div class="grid xl:grid-cols-4 lg:grid-cols-3 grid-cols-2 gap-4">
                    <TableCard />
                    <TableCard />
                    <TableCard />
                    <TableCard />
                    <TableCard />
                    <TableCard />
                </div>
            </main>
            <!-- <aside class="lg:w-96 w-80 border-l bg-gray-200">c</aside> -->
        </div>
    </div>
</template>