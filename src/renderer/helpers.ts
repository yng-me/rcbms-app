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