import { dialog } from 'electron'
import fs from 'fs-extra'
import { withTextData } from '../../utils/helpers'

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

export const textDataCheck = () : TXT => {

    if(withTextData().isAvailable) {

        try {
        
            const res = fs.readdirSync(withTextData().path, { withFileTypes: true }) 
            
            let textFiles: string[] = []
        
            res.forEach(item => {
                if(item.isFile()) textFiles.push(item.name);
            })
            const validTextFiles = textFiles
                .filter(el => /\.(txt|TXT)$/g.test(el))
                .sort((a, b) => a.localeCompare(b))
        
            const expectedTextFiles = [
                'CERTIFICATION.TXT',    'GEO_ID.TXT',
                'INTERVIEW_RECORD.TXT', 'SECTION_A.TXT',
                'SECTION_B.txt',        'SECTION_C.txt',
                'SECTION_D.txt',        'SECTION_E.txt',
                'SECTION_F.TXT',        'SECTION_F1.TXT',
                'SECTION_G_NEW.TXT',    'SECTION_G1_NEW.TXT',
                'SECTION_H.TXT',        'SECTION_H1.TXT',
                'SECTION_I.TXT',        'SECTION_J.TXT',
                'SECTION_K.TXT',        'SECTION_L.TXT',
                'SECTION_L1.TXT',       'SECTION_M.TXT',
                'SECTION_N.TXT',        'SECTION_O.TXT',
                'SECTION_O1.TXT',       'SECTION_P.TXT',
                'SECTION_P1.TXT',       'SECTION_Q.TXT',
                'SECTION_R.TXT',        'SECTION_S.TXT',
                'SUMMARY_OF_VISIT.TXT'
            ];
        
            if(validTextFiles.length === 29 && JSON.stringify(validTextFiles) == JSON.stringify(expectedTextFiles)) {
        
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

