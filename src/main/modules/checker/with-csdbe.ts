import fs from 'fs-extra'
import { dialog } from 'electron'

const isMac = process.platform === 'darwin'

interface CSDBE {
    error: boolean
    status: string
    loading?: boolean
    isAvailable?: boolean
    count?: number
    files: any
    path: string
}

export const csdbeCheck = (path : string) :CSDBE => {

    let payload : CSDBE = {
        error: false,
        isAvailable: false,
        status: 'No available data',
        loading: false,
        count: 0,
        files: [],
        path,
    }
 
    if(isMac) { 

        const files = [
            'H141114003001000.csdbe',
            'H141114007002000.csdbe',
            'H141114008001000.csdbe'
        ]

        return { ...payload, files }
    }

    if(fs.existsSync(path)) {

        try {
            const dps : any = fs.readdirSync(path, { withFileTypes: true })
            
            if(dps.length) {

                let csdbe: string[] = []

                dps.forEach((item : any) => {
                    if(item.isFile()) csdbe.push(item.name);
                })

                const csdbeConcat = csdbe.filter(el => /\.csdbe$/g.test(el))

                if(csdbeConcat.length) {

                    return payload = { 
                        error: false, 
                        isAvailable: true,
                        status: 'Data ready to be loaded',
                        count: csdbeConcat.length,
                        files: csdbeConcat,
                        path
                    }

                } else {
                    
                    return payload
                }


            } else {

                return payload

            }

        } catch(err) {
            
            dialog.showErrorBox('Loading Data', 'There was an error loading the data files.')
            return payload
        }

    } else {
        
        return payload
    }

}