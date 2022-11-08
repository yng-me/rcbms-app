<script lang="ts">

import { Bar } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import { ipcRenderer } from '../electron'
  
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)
  
export default {
    name: 'Dashboard',
    components: { Bar },
    props: {
        keys: {
            type: Object
        },
        logs: {
            type: Array
        },
        chartId: {
            type: String,
            default: 'bar-chart'
        },
        datasetIdKey: {
            type: String,
            default: 'label'
        },
        width: {
            type: Number,
            default: 1920
        },
        height: {
            type: Number,
            default: 800
        },
        cssClasses: {
            default: '',
            type: String
        },
        styles: {
            type: Object,
            default: () => {}
        },
        plugins: {
            type: Object,
            default: () => {}
        }
    },
    data() {
        return {
            chartOptions: {
                responsive: true
            },
            dateSelected: 'All'
        }
    },
    methods: {
        openOutput (file : string) {
          ipcRenderer.send('view-output', file)
        },
        getLogBySection(data : any, y : any) {

            let result : any = []

            data.map((item : any) => {
                return { 
                    section: item.Section, 
                    n: item[y] == undefined ? 0 : item[y] 
                }
            // @ts-ignore
            }).reduce((res : any, value : any) => {
                if (!res[value.section]) {

                    res[value.section] = { section: value.section, n: 0 }
                    result.push(res[value.section])
                }
                res[value.section]['n'] += +value.n;

                return res;
            }, {})

            return result.map((el : any) => {
                return {
                    section: el.section,
                    n: el.n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ','),
                    val: el.n
                }
            })
        }
    },
    computed: {
        dateGenerated() {
            // @ts-ignore
            return Object.keys(this.keys).filter((a : string, b : number) => b !== 0 && b !== 1)
                .map((el : any) => el.replace(/(.*\()(.*)(\))/g, '$2'))
        },
        logsBySection() {
            // @ts-ignore
            const x = Object.keys(this.keys)
            // const end = x.pop()
            const end : any = this.dateSelected === 'All' ? x.pop() : `Number of Cases (${this.dateSelected})`

            return this.getLogBySection(this.logs, end)
        },
        chartData() {
            // @ts-ignore
            const x = Object.keys(this.keys)
            const end : any = this.dateSelected === 'All' ? x.pop() : `Number of Cases (${this.dateSelected})`

            const df = this.getLogBySection(this.logs, end)

            const dataLabels : string[] = df.map((el : any) => el.section == 'Cross-section' ? 'Cross' : el.section.slice(-1))

            const datasets : any = []

            const color = [
                'rgba(248, 113, 113, 0.2)', 
                'rgba(20, 184, 166, 0.2)', 
                'rgba(227, 182, 0, 0.2)', 
                'rgba(16, 161, 35, 0.2)', 
                'rbga(149, 4, 212, 0.2)'
            ]
            const borderColor = ['#f87171', '#14b8a6', '#e3b600', '#10a123', '#9504d4']

            this.dateGenerated.forEach((key : any, index : any) => {
                const nkey = `Number of Cases (${key})`
                const d = {
                    label: key,
                    borderWidth: 1,
                    backgroundColor: color[index],
                    borderColor: borderColor[index],
                    // @ts-ignore
                    data: this.getLogBySection(this.logs, nkey).map((i : any) => +i.val)
                }

                datasets.push(d)
            })

            return {
                labels: dataLabels,
                datasets: this.dateSelected === 'All'
                    ? datasets
                    : [{ label:  this.dateSelected, borderWidth: 1, backgroundColor: 'rgba(248, 113, 113, 0.2)', borderColor: '#f87171', data: df.map((el : any) => +el.val) }]
            }
            
        }
    }
  }
  </script>



<template>
    <div v-if="logs?.length" class="mt-8 border-t pb-8 bg-gradient-to-b from-gray-100">
        <div class="px-5 pt-4">
          <div class="flex items-center justify-between mb-2">
            <h3 class="">Frequency of inconsistences by section</h3>
            <select name="" id="" v-model="dateSelected" class="px-3.5 py-1.5 rounded-xl border-gray-300 w-36 text-xs">
                <option value="All">All</option>
                <option v-for="i in dateGenerated" :key="i" :value="i">{{ i }}</option>
            </select>
          </div>
          <div class="bg-white rounded-xl overflow-hidden border p-3">
            <Bar
                :chart-options="chartOptions"
                :chart-data="chartData"
                :chart-id="chartId"
                :dataset-id-key="datasetIdKey"
                :css-classes="cssClasses"
                :styles="styles"
                :width="width"
                :height="height"
            />
          </div>
        </div>
        <div class="grid lg:grid-cols-5 md:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-4 p-5">
            <div v-for="(i, index) in logsBySection" :key="index" class="aspect-video rounded-lg border bg-white">
                <p style="font-size: 11px" class="border-b leading-tight px-2.5 py-2">
                  <button 
                    @click.prevent="openOutput(i.section)"
                    class="hover:text-teal-600 font-semibold">
                    {{ i.section }}
                  </button>
                </p>
                <div class="p-4">
                  <span class="lg:text-5xl md:text-4xl text-3xl">{{ i.n ? i.n : 0 }}</span>
                  <span class="text-xs text-gray-400">&nbsp;item{{ i.n == 1 ? '' : 's' }}</span>
                </div>
            </div>
        </div>
    </div>
    <div v-else class="h-full border-t mt-12 px-8 py-12 flex justify-center bg-gradient-to-b from-gray-100">
        <img src="../assets/undraw_statistics_re_kox4.svg" alt="" class="lg:w-2/5 w-3/5">
    </div>
</template>
  