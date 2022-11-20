import { dialog } from 'electron'
import fs from 'fs-extra'
import { withTextData } from '../../utils/helpers'
import { expectedTextFiles } from '../../utils/constants'

interface TXT {
    error: boolean
    status: string
    loading?: boolean
    isAvailable?: boolean
    count?: number
}

let payload : TXT = {
    error: false,
    status: '',
    loading: false,
    isAvailable: false,
    count: 0
}

export const textDataCheck = (source : string) : TXT => {

    if(withTextData().isAvailable) {

        const l = {
            '2021-pilot-cbms': 120,
            '2022-cbms': 29
        }[source]

        try {
        
            const res = fs.readdirSync(withTextData().path, { withFileTypes: true }) 
            
            let textFiles: string[] = []
        
            res.forEach(item => {
                if(item.isFile()) textFiles.push(item.name);
            })
            const validTextFiles = textFiles
                .filter(el => /\.(txt|TXT)$/g.test(el))
                .sort((a, b) => a.localeCompare(b))
        
            if(validTextFiles.length === l && JSON.stringify(validTextFiles) == JSON.stringify(expectedTextFiles[source])) {
        
                return {
                    error: false,
                    status: 'Text data available',
                    isAvailable: true,
                    count: validTextFiles.length
                }
            
            } else {
        
                return {
                    error: true,
                    isAvailable: false,
                    status: 'Extracted text data incomplete',
                    count: validTextFiles.length
                }

            }

        } catch {
            
            dialog.showErrorBox('Loading Data', 'There was an error loading the data files.')
            return {
                ...payload,
                error: true
            }
        }

    } else {
        
        return {
            error: true,
            isAvailable: false,
            status: 'Error loading extracted text data'
        }
    }
}

