import fs from 'fs-extra'
import { join } from 'path'
import yaml from 'js-yaml'

import { base, config, RConfig } from '../../utils/constants';

const os = process.platform == 'darwin'

// YAML config
export const withYamlConfig = () => {
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/config.yml' : join(base, 'config.yml')
    return { isAvailable: fs.pathExistsSync(path), path } 
}

export const rConfig = () : RConfig => {

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

    if(withYamlConfig().isAvailable) {
        
        const c = yaml.load(fs.readFileSync(withYamlConfig().path)) 
        return {
            ...c,
            paths: {
                ...c.paths,
                cspro_path,
                csconcat_path,
                csexport_path,
                r_path
            }
        }
    } else {
        const rConfigYaml = yaml.dump(config)
        fs.writeFileSync(withYamlConfig().path, rConfigYaml)
        return config
    }
}