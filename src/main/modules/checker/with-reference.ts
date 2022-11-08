import { dialog } from 'electron'
import XLSX from 'xlsx'

import { withReferenceDictionary } from '../../utils/helpers'

export const referenceDictionaryCheck = () => {

    let payload = {
        error: false,
        data: []
    }
    
    if(withReferenceDictionary().isAvailable) {
    
        try {         
            const workbook = XLSX.readFile(withReferenceDictionary().path);
            const sheet_name_list = workbook.SheetNames;
            const xlData : any = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);

            payload = {
                error: false,
                data: xlData
            }

            return payload
    
        } catch {

            dialog.showErrorBox('Dictionary File', 'There was an error loading the dictionary reference file.')
            return {
                error: true,
                data: []
            }
        }
    
    } else {
        return payload
    }
}

