import fs from 'fs-extra'
import { join } from 'path'
import os from 'os'

const isMac = process.platform === 'darwin'
export const base = isMac ? join(os.homedir(), 'Desktop', 'R Codes', '2022-cbms') : 'C:\\rcbms'

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
    csexport_path: string
    reference_path: string
}

export interface RConfig {
    run_after_edit: boolean
    use_rdata: boolean
    include_justifiction: boolean
    clear: boolean
    save_by_area?: boolean
    convert_to_rdata: boolean
    append_new_record: boolean
    use_raw_data_from_tablet: boolean
    paths: Paths
}

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
    const csproMatch = csproDir.find((el : string) => /^CSPro \d\.\d/.test(el))
    if(csproMatch !== undefined) {
    
        cspro_path = join('C:\\Program Files (x86)', csproMatch, 'CSPro.exe')
        if(fs.existsSync(cspro_path)) {
            csconcat_path = join('C:', 'Program Files (x86)', csproMatch, 'CSConcat.exe')
            csexport_path = join('C:', 'Program Files (x86)', csproMatch, 'CSExport.exe')
        }
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
  use_raw_data_from_tablet: false,
  paths: {
      r_path,
      rstudio_path: 'C:\\Program Files\\RStudio\\bin\\rstudio.exe',
      quarto_path: 'C:\\Program Files\\RStudio\\bin\\quarto\\bin\\quarto.exe',
      rdata_path: isMac ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/hpq.Rdata' : join(base, 'data', 'hpq.Rdata'),
      before_edit_path: 'C:\\PSA SYSTEMS FOLDER\\CBMS-ROLLOUT\\HPQ\\DOWNLOADED',
      after_edit_path: 'C:\\PSA SYSTEMS FOLDER\\CBMS-ROLLOUT\\HPQ\\EDITED',
      justification_path: isMac ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/references/justifications.xlsx' : join(base, 'references\\justifications.xlsx'),
      output_path: isMac ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/output' : join(base, 'output'),
      reference_path: isMac ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/references/dictionary.xlsx' : join(base, 'references\\dictionary.xlsx'),
      cspro_path,
      csconcat_path,
      csexport_path
  }
}