import { app } from 'electron'
import { join } from 'path'
import fs from 'fs-extra'
import { getVersion, withRCBMSFolder } from '../utils/helpers'
import { rConfig } from './checker/with-rconfig'
import { base } from '../utils/constants'
// import { NsisUpdater } from "electron-updater"


export const updateRCBMS = () => {

    const { version, path } = getVersion()

    const v = process.env.NODE_ENV === 'development' 
        ? require('../../../package.json').version
        : app.getVersion()

    const p  = join(base, 'config.yml')


    if(version == '1.0.0') {

        if(fs.pathExistsSync(p)) {
            fs.rmSync(p, { recursive: true, force: true })
        }
    
        rConfig()

        const qmdFilesToUpdate = [
            join('qmd', 'section-g.qmd'),
            join('qmd', 'section-l.qmd'),
            join('qmd', 'cross-section.qmd'),
            join('utils', 'exports', 'export-summary.R'),
            join('utils', 'exports', 'export-config.R'),
            join('references', 'HPQF2_DICT.dcf')
        ]

        qmdFilesToUpdate.forEach(el => {
            const from = join(app.getAppPath(), 'static', 'rcbms', el)
            const to = join(withRCBMSFolder().path, el)

            fs.copySync(from, to, { recursive: true });
        })

    }

    if(version == '1.0.1') {

        if(fs.pathExistsSync(p)) {
            fs.rmSync(p, { recursive: true, force: true })
        }
    
        rConfig()

        const qmdFilesToUpdate = [
            join('references', 'HPQF2_DICT.dcf')
        ]

        qmdFilesToUpdate.forEach(el => {
            const from = join(app.getAppPath(), 'static', 'rcbms', el)
            const to = join(withRCBMSFolder().path, el)

            fs.copySync(from, to, { recursive: true });
        })

        
    }

    if(version == '1.0.2') {

        if(fs.pathExistsSync(p)) {
            fs.rmSync(p, { recursive: true, force: true })
        }
    
        rConfig()

        const qmdFilesToUpdate = [
            join('utils', 'exports', 'export-config.R'),
        ]

        qmdFilesToUpdate.forEach(el => {
            const from = join(app.getAppPath(), 'static', 'rcbms', el)
            const to = join(withRCBMSFolder().path, el)

            fs.copySync(from, to, { recursive: true });
        })

        
    }

    fs.writeJSONSync(path, { version: v })
}
