<script lang="ts" setup>

defineProps(['isPilotMode'])



</script>

<template>
    <div class="mx-auto max-w-4xl px-6 pt-16">
        <div class="flex flex-col items-center justify-center">
            <img src="../assets/hero.svg" alt="" class="!lg:w-32 !w-40" />
            <div class="w-full text-center py-6">
                <p class="lg:text-base text-sm text-gray-500 sm:whitespace-nowrap">Philippine Statistics Authority</p>
                <h1 class="lg:text-2xl sm:text-xl tracking-wide text-lg sm:whitespace-nowrap font-semibold text-teal-600">
                    {{ isPilotMode ? '2021 Pilot Community-Based Monitoring System' : '2022 Community-Based Monitoring System' }}
                </h1>
            </div>
        </div>
    </div>
</template>