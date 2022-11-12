import fs from 'fs-extra'
import { join } from 'path'
import yaml from 'js-yaml'

import { base, config, RConfig, dependenciesPath } from '../../utils/constants';

const os = process.platform == 'darwin'

// YAML config
export const withYamlConfig = () => {
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/config.yml' : join(base, 'config.yml')
    return { isAvailable: fs.pathExistsSync(path), path } 
}

export const rConfig = () : RConfig => {

    const { cspro_path, csconcat_path, csexport_path, r_path } = dependenciesPath()

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