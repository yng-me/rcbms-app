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
        pilot_output_path: pilotDirectory,
        reference_path: join(base, 'references', 'dictionary.xlsx'),
        cspro_path: dependenciesPath().cspro_path,
        csconcat_path: dependenciesPath().csconcat_path,
        csexport_path: dependenciesPath().csexport_path,
        pilot_data_path: join(base, 'data', 'pilot'),
        pilot_data_dict_path: join(base, 'scripts', '2021-pilot-cbms', 'references', 'HPQF2_PILOT_DICT.dcf')
  }
}