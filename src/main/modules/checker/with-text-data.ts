import { dialog } from 'electron'
import fs from 'fs-extra'
import { join, extname } from 'path'
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

export const textDataCheck = (source = '2022-cbms') : TXT => {


    let path = withTextData().path
    let count = 28

    if(source == '2021-pilot-cbms') {
        path = join('C:', 'rcbms', 'scripts', '2021-pilot-cbms', 'data', 'text')
        count = 120
    }

    const sourceDir = {
        '2021-pilot-cbms': fs.existsSync(path),
        '2022-cbms': withTextData().isAvailable
    }[source] 

    if(sourceDir) {
        
        try {
        
            const res = fs.readdirSync(path, { withFileTypes: true }) 
            
            let textFiles: string[] = []
        
            res.forEach(item => {
                if(item.isFile()) textFiles.push(item.name);
            })
            const validTextFiles = textFiles
                .filter(el => extname(el) === '.txt' || extname(el) === '.TXT')
                .sort((a, b) => a.localeCompare(b))
        
            if(validTextFiles.length === count && JSON.stringify(validTextFiles) == JSON.stringify(expectedTextFiles[source])) {
        
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

