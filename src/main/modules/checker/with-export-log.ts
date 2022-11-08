import { dialog } from 'electron'
import XLSX from 'xlsx'

import { withExportLog } from '../../utils/helpers'

export const exportLogCheck = (arg : boolean = false) => {

    let payload = {
        error: false,
        data: []
    }
    
    if(withExportLog().isAvailable || arg === true) {
    
        try {         
            const workbook = XLSX.readFile(withExportLog().path);
            const sheet_name_list = workbook.SheetNames;
            const xlData : any = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]]);
    
            payload = {
                error: false,
                data: xlData
            }            

            return payload
    
        } catch {

            dialog.showErrorBox('Export Logs', 'There was an error loading the export log file.')
            return {
                error: true,
                data: []
            }
        }
    
    } else {
        return payload
    }
}

