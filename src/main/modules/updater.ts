import { app } from 'electron'
import { join } from 'path'
import fs from 'fs-extra'
import { getVersion, withRCBMSFolder } from '../utils/helpers'
import { rConfig } from './checker/with-rconfig'
// import { NsisUpdater } from "electron-updater"


export const updateRCBMS = () => {

    const { version, path } = getVersion()

    const v = process.env.NODE_ENV === 'development' 
        ? require('../../../package.json').version
        : app.getVersion()

    if(v !== version) {

        const p  = 'C:\\rcbms\\config.yml'

        if(fs.pathExistsSync(p)) {
            fs.rmSync(p, { recursive: true, force: true })
        }

        rConfig()
        
        const qmdFilesToUpdate = [
            join('qmd', 'section-g.qmd'),
            join('qmd', 'section-l.qmd'),
            join('qmd', 'cross-section.qmd')
        ]

        qmdFilesToUpdate.forEach(el => {
            const from = join(app.getAppPath(), 'static', 'rcbms', el)
            const to = join(withRCBMSFolder().path, el)

            fs.copySync(from, to, { recursive: true });
        })

        fs.writeJSONSync(path, { version })
    }
}