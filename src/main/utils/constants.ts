import fs from 'fs-extra'
import { join } from 'path'
import os from 'os'

const isMac = process.platform === 'darwin'
export const base = isMac ? join(os.homedir(), 'Desktop', 'R Codes', '2022-cbms') : 'C:\\rcbms'
export const pilotDirectory = isMac ? join(os.homedir(), 'Desktop', 'R Codes', '2021-pilot-cbms') : join('C:', 'rcbms', 'scripts', '2021-pilot-cbms')

export interface Paths {
    r_path: string
    rstudio_path: string
    quarto_path: string
    rdata_path: string
    before_edit_path: string
    after_edit_path: string
    justification_path: string
    output_path: string
    cspro_path: string
    csconcat_path: string
    pilot_output_path: string
    csexport_path: string
    reference_path: string
    pilot_data_path: string
    pilot_data_dict_path: string
}

export interface RConfig {
    run_after_edit: boolean
    use_rdata: boolean
    include_justifiction: boolean
    clear: boolean
    save_by_area?: boolean
    convert_to_rdata: boolean
    append_new_record: boolean
    use_pilot_data: boolean
    use_raw_data_from_tablet: boolean
    paths: Paths
}

export const dependenciesPath = () => {

    const r64Path = join('C:', 'Program Files', 'R')
    const r86Path = join('C:', 'Program Files (x86)', 'R')
    
    let r_path = ''
    
    if(fs.existsSync(r64Path)) {
        const r = fs.readdirSync(r64Path)
        r_path = join(r64Path, r[0], '\\bin\\x64\\Rscript.exe')
    
    } else if (fs.existsSync(r86Path)) {
        const r = fs.readdirSync(r86Path)
        r_path = join(r86Path, r[0], '\\bin\\Rscript.exe')
    } 
    
    
    let cspro_path = ''
    let csconcat_path = ''
    let csexport_path = ''
    
    if(fs.existsSync('C:\\Program Files (x86)')) {
        const csproDir = fs.readdirSync('C:\\Program Files (x86)')
        const csproMatch = csproDir.find((el : string) => /^CSPro 7\.7/.test(el))
        if(csproMatch !== undefined) {
        
            cspro_path = join('C:\\Program Files (x86)', csproMatch, 'CSPro.exe')
            if(fs.existsSync(cspro_path)) {
                csconcat_path = join('C:', 'Program Files (x86)', csproMatch, 'CSConcat.exe')
                csexport_path = join('C:', 'Program Files (x86)', csproMatch, 'CSExport.exe')
            }
        }
    }

    return {
        r_path,
        cspro_path,
        csconcat_path,
        csexport_path,
    }
}


export const config : RConfig = {
    run_after_edit: false,
    use_rdata: false,
    include_justifiction: false,
    clear: false,
    save_by_area: false,
    convert_to_rdata: false,
    append_new_record : false,
    use_pilot_data: false,
    use_raw_data_from_tablet: false,
    paths: {
        r_path: dependenciesPath().r_path,
        rstudio_path: 'C:\\Program Files\\RStudio\\bin\\rstudio.exe',
        quarto_path: 'C:\\Program Files\\RStudio\\bin\\quarto\\bin\\quarto.exe',
        rdata_path: join(base, 'data', 'hpq.Rdata'),
        before_edit_path: 'C:\\PSA SYSTEMS FOLDER\\CBMS-ROLLOUT\\HPQ\\DOWNLOADED',
        after_edit_path: 'C:\\PSA SYSTEMS FOLDER\\CBMS-ROLLOUT\\HPQ\\EDITED',
        justification_path: join(base, 'references', 'justifications.xlsx'),
        output_path: join(base, 'output'),
        pilot_output_path: join(pilotDirectory, 'output', 'Inconsistencies'),
        reference_path: join(base, 'references', 'dictionary.xlsx'),
        cspro_path: dependenciesPath().cspro_path,
        csconcat_path: dependenciesPath().csconcat_path,
        csexport_path: dependenciesPath().csexport_path,
        pilot_data_path: join(base, 'data', 'pilot'),
        pilot_data_dict_path: join(base, 'scripts', '2021-pilot-cbms', 'references', 'HPQF2_PILOT_DICT.dcf')
  }
}


export const expectedTextFiles = {
    '2022-cbms': [
        // 'CERTIFICATION.TXT',    
        'GEO_ID.TXT',
        'INTERVIEW_RECORD.TXT', 
        'SECTION_A.TXT',
        'SECTION_B.txt',        
        'SECTION_C.txt',
        'SECTION_D.txt',        
        'SECTION_E.txt',
        'SECTION_F.TXT',        
        'SECTION_F1.TXT',
        'SECTION_G_NEW.TXT',    
        'SECTION_G1_NEW.TXT',
        'SECTION_H.TXT',        
        'SECTION_H1.TXT',
        'SECTION_I.TXT',        
        'SECTION_J.TXT',
        'SECTION_K.TXT',        
        'SECTION_L.TXT',
        'SECTION_L1.TXT',       
        'SECTION_M.TXT',
        'SECTION_N.TXT',        
        'SECTION_O.TXT',
        'SECTION_O1.TXT',       
        'SECTION_P.TXT',
        'SECTION_P1.TXT',       
        'SECTION_Q.TXT',
        'SECTION_R.TXT',        
        'SECTION_S.TXT',
        'SUMMARY_OF_VISIT.TXT'
    ],
    '2021-pilot-cbms': [
        'A01_08_RECORD.TXT',
        'Exported.txt',
        'INTERVIEW_RECORD.TXT',
        'REFUSAL_QUESTIONS.TXT',
        'SECTION_F.TXT',
        'SECTION_G.TXT',
        'SECTION_H1_H2.TXT',
        'SECTION_H3.TXT',
        'SECTION_H4_H11.TXT',
        'SECTION_I.TXT',
        'SECTION_I11_NONE.TXT',
        'SECTION_I4.TXT',
        'SECTION_I5_I10.TXT',
        'SECTION_J.TXT',
        'SECTION_J10.TXT',
        'SECTION_J15.TXT',
        'SECTION_J19.TXT',
        'SECTION_J2.TXT',
        'SECTION_J21.TXT',
        'SECTION_J23.TXT',
        'SECTION_J29.TXT',
        'SECTION_J33.TXT',
        'SECTION_J6.TXT',
        'SECTION_J8.TXT',
        'SECTION_K.TXT',
        'SECTION_L1.TXT',
        'SECTION_L11.TXT',
        'SECTION_L12.TXT',
        'SECTION_L18.TXT',
        'SECTION_L19.TXT',
        'SECTION_L2.TXT',
        'SECTION_L25.TXT',
        'SECTION_L38.TXT',
        'SECTION_L4.TXT',
        'SECTION_L44.TXT',
        'SECTION_L51.TXT',
        'SECTION_L55.TXT',
        'SECTION_M.TXT',
        'SECTION_M13.TXT',
        'SECTION_M18.TXT',
        'SECTION_M19.TXT',
        'SECTION_N.TXT',
        'SECTION_O.TXT',
        'SECTION_O3.TXT',
        'SECTION_OA.TXT',
        'SECTION_OB.TXT',
        'SECTION_OC.TXT',
        'SECTION_OD.TXT',
        'SECTION_OE.TXT',
        'SECTION_OF.TXT',
        'SECTION_OG.TXT',
        'SECTION_OH.TXT',
        'SECTION_OI.TXT',
        'SECTION_OJ.TXT',
        'SECTION_OK.TXT',
        'SECTION_OZ.TXT',
        'SECTION_P1_P4.TXT',
        'SECTION_P11_P13.TXT',
        'SECTION_P12A.TXT',
        'SECTION_P12B.TXT',
        'SECTION_P12C.TXT',
        'SECTION_P12D.TXT',
        'SECTION_P12E.TXT',
        'SECTION_P12F.TXT',
        'SECTION_P14_P16.TXT',
        'SECTION_P15A.TXT',
        'SECTION_P15B.TXT',
        'SECTION_P15C.TXT',
        'SECTION_P15D.TXT',
        'SECTION_P15E.TXT',
        'SECTION_P15F.TXT',
        'SECTION_P15G.TXT',
        'SECTION_P15H.TXT',
        'SECTION_P15I.TXT',
        'SECTION_P15J.TXT',
        'SECTION_P17_P19.TXT',
        'SECTION_P18A.TXT',
        'SECTION_P18B.TXT',
        'SECTION_P18C.TXT',
        'SECTION_P18D.TXT',
        'SECTION_P18E.TXT',
        'SECTION_P18F.TXT',
        'SECTION_P18G.TXT',
        'SECTION_P18H.TXT',
        'SECTION_P18I.TXT',
        'SECTION_P18J.TXT',
        'SECTION_P18K.TXT',
        'SECTION_P18L.TXT',
        'SECTION_P18M.TXT',
        'SECTION_P22.TXT',
        'SECTION_P2A.TXT',
        'SECTION_P2B.TXT',
        'SECTION_P2C.TXT',
        'SECTION_P2D.TXT',
        'SECTION_P2E.TXT',
        'SECTION_P2F.TXT',
        'SECTION_P2G.TXT',
        'SECTION_P4A.TXT',
        'SECTION_P4B.TXT',
        'SECTION_P4C.TXT',
        'SECTION_P4D.TXT',
        'SECTION_P4E.TXT',
        'SECTION_P4F.TXT',
        'SECTION_P4G.TXT',
        'SECTION_P5_P7.TXT',
        'SECTION_P6A.TXT',
        'SECTION_P6B.TXT',
        'SECTION_P6C.TXT',
        'SECTION_P6D.TXT',
        'SECTION_P6E.TXT',
        'SECTION_P6F.TXT',
        'SECTION_P6G.TXT',
        'SECTION_P6H.TXT',
        'SECTION_P6I.TXT',
        'SECTION_P6J.TXT',
        'SECTION_P8_P10.TXT',
        'SECTION_P9.TXT',
        'SECTION_Q.TXT',
        'SECTION_R.TXT',
        'SUMMVISIT.TXT'
    ]
}

