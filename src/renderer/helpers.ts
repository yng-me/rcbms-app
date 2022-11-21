import { TableOptions } from './utils/types'

export const getLogBySection = (data : any, y : string) => {

    let result : any = []

    data.map((item : any) => {
        return { section: item.Section, n: item[y] }
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


export const tableAlreadyExist = (tables: [], options: TableOptions) => {
    let match = false
    if(tables.length) {
        match = Boolean(tables.find((el : any) => {
            return el.tableOptions.col == options.col && 
                el.tableOptions.row == options.row &&
                el.tableOptions.rowRecord == options.rowRecord &&
                el.tableOptions.colRecord == options.colRecord &&
                el.tableOptions.colRecordLabel == options.colRecordLabel &&
                el.tableOptions.groupBy.brgy == options.groupBy.brgy &&
                el.tableOptions.groupBy.province == options.groupBy.province &&
                el.tableOptions.groupBy.city_mun == options.groupBy.city_mun &&
                el.tableOptions.groupBy.ean == options.groupBy.ean
        }))
    }
    return match
}