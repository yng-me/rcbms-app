import { dialog } from 'electron'
import fs from 'fs-extra'
import { join, extname } from 'path'
import { withJustification } from '../../utils/helpers'

export const justificationCheck = () => {
    
    const { path, isAvailable } = withJustification()

    if(isAvailable) {
        
        try {
        
            const res = fs.readdirSync(path, { withFileTypes: true }) 
            
            let xlsx: string[] = []
        
            res.forEach(item => {
                if(item.isFile()) xlsx.push(item.name);
            })

            const xlsxValidFiles = xlsx.filter(el => extname(el) === '.xlsx' || extname(el) === '.XLSX')
            if(xlsxValidFiles.length > 0) {
                return true
            } else {
                return false
            }

        } catch {            
            dialog.showErrorBox('Loading Justification', 'There was an error loading the justification files.')
            return false
        }

    } else {
        
        return false
    }
}

