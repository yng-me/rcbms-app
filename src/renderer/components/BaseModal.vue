<template>
    <transition leave-active-class="duration-500">
        <div v-show="show" :class="outerClass" class="z-50">
            <transition 
                    enter-active-class="ease-out duration-500"
                    enter-class="opacity-0"
                    enter-to-class="opacity-100"
                    leave-active-class="ease-in duration-500"
                    leave-class="opacity-100"
                    leave-to-class="opacity-0">
                <div v-show="show" class="fixed inset-0 transform transition-all" @click="close">
                    <div class="absolute inset-0 bg-stone-700 opacity-75 h-full"></div>
                </div>
            </transition>

            <transition name="modal" 
                    enter-active-class="ease-in transition-all duration-500"
                    enter-class="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                    enter-to-class="opacity-100 ease-out sm:scale-100"
                    leave-active-class="ease-in duration-500"
                    leave-class="opacity-100 translate-y-0 sm:scale-100"
                    leave-to-class="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95">
                <div 
                    v-show="show" 
                    class="transform transition-all duration-500 ease-in w-full overflow-auto y-scroll-bar z-50" 
                    :class="[maxWidthClass, innerClass]">
                    <slot></slot>
                </div>
            </transition>
        </div>
    </transition>
</template>

<script lang="ts">
    export default {
        props: {
            show: {
                default: false
            },
            maxWidth: {
                default: '6xl'
            },
            closeable: {
                default: true
            },
            usage: {
                default: 'basic'
            }
        },

        methods: {
            close() {
                if (this.closeable) {
                    this.$emit('close')
                }
            }
        },

        watch: {
            show: {
                immediate: true,
                handler: (show) => {
                    if (show) {
                        document.body.style.overflow = 'hidden'
                    } else {
                        document.body.style.overflow = ''
                    }
                }
            }
        },

        created() {
            const closeOnEscape = (e: any) => {
                if (e.key === 'Escape' && this.show) {
                    this.close()
                }
            }

            document.addEventListener('keydown', closeOnEscape)

        },

        computed: {
            maxWidthClass() {
                return {
                    'sm': 'sm:max-w-sm',
                    'md': 'sm:max-w-md',
                    'lg': 'sm:max-w-lg',
                    'xl': 'sm:max-w-xl',
                    '2xl': 'sm:max-w-2xl',
                    '3xl': 'sm:max-w-3xl',
                    '4xl': 'sm:max-w-4xl',
                    '5xl': 'sm:max-w-5xl',
                    '6xl': 'sm:max-w-6xl',
                }[this.maxWidth]
            },
            outerClass() {
                return {
                    basic: 'top-0 px-3 md:pt-6 pt-4 lg:px-0 flex sm:items-top sm:justify-center fixed flex inset-x-0 w-full max-h-screen pb-20',
                    multipurpose: 'md:px-3 md:pt-6 md:top-0 md:bottom-auto bottom-0 md:items-top md:justify-center fixed flex inset-x-0 w-full max-h-screen',
                    nav: 'md:top-0 md:bottom-auto bottom-0 md:items-top md:justify-center fixed flex inset-x-0 w-full max-h-screen',
                    full: 'justify-center fixed flex inset-0',
                    dialog: 'justify-center fixed flex items-center inset-0' 
                }[this.usage]
            },
            innerClass() {
                return {
                    basic: 'rounded-xl sm:shadow-xl',
                    multipurpose: 'rounded-t-md md:rounded-xl sm:shadow-xl',
                    nav: 'rounded-t-xl',
                    full: 'h-full'
                }[this.usage]
            }
        }
    }
</script>


<style scoped>
.y-scroll-bar::-webkit-scrollbar-track {
    background-color: #A8A29E;
}

.y-scroll-bar::-webkit-scrollbar {
    width: 8px;
    background-color: #E7E5E4;
}

.y-scroll-bar::-webkit-scrollbar-thumb {
    background-color: #44403C;
}

.modal-enter-active {
  transition: all 0.5s ease-out 
}

.modal-leave-active {
  transform: translateX(-20px);
  transition: all 0.5s ease-in
}

.modal-enter-from {
  transform: translateY(-20px);
  opacity: 0;
}

.modal-fade-leave-to {
  transform: translateY(100px);
  transition:  all 1s ease-in-out;

}
</style>