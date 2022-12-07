import { app } from 'electron'
import { join } from 'path'
import fs from 'fs-extra'
import { getVersion, withRCBMSFolder } from '../utils/helpers'
import { rConfig } from './checker/with-rconfig'
import { base } from '../utils/constants'
// import { NsisUpdater } from "electron-updater"

const applyUpdate = (files: string[]) => {

    const p  = join(base, 'config.yml')

    if(fs.pathExistsSync(p)) {
        fs.rmSync(p, { recursive: true, force: true })
    }
    
    rConfig()

    files.forEach(el => {
        const from = join(app.getAppPath(), 'static', 'rcbms', el)
        const to = join(withRCBMSFolder().path, el)

        fs.copySync(from, to, { recursive: true });
    })

}

export const updateRCBMS = () => {

    const { version, path } = getVersion()

    const v = process.env.NODE_ENV === 'development' 
        ? require('../../../package.json').version
        : app.getVersion()

    let seen = true

    if(version == '1.0.0') {

        const filesToUpdate = [

            join('qmd', 'section-g.qmd'),
            join('qmd', 'section-m.qmd'),
            join('qmd', 'section-l.qmd'),
            join('qmd', 'section-r.qmd'),
            join('qmd', 'cross-section.qmd'),
            join('references', 'export_settings.xlsx'),
            join('references', 'HPQF2_DICT.dcf'),
            join('scripts', '2021-pilot-cbms'),
            'utils',
        ]

        applyUpdate(filesToUpdate)
    }

    if(version == '1.0.1') {

        const filesToUpdate = [
            join('qmd', 'section-m.qmd'),
            join('qmd', 'section-g.qmd'),
            join('references', 'export_settings.xlsx'),
            join('references', 'HPQF2_DICT.dcf')
        ]
        applyUpdate(filesToUpdate)

    }

    if(version == '1.0.2') {

        const filesToUpdate = [
            join('references', 'export_settings.xlsx'),
            join('qmd', 'section-g.qmd'),
            join('qmd', 'section-m.qmd'),
            join('utils', 'exports', 'export-config.R'),
        ]

        applyUpdate(filesToUpdate)

    }

    if(version == '1.0.3') {
        applyUpdate([join('utils', 'exports', 'export.R')])
    }

    if(version == '1.0.4') {

        applyUpdate([
            'scripts',
            join('utils', 'helpers', 'select_cv.R')
        ])

    }

    if(version == '1.0.5') {
        applyUpdate([
            'utils',
            join('qmd', 'section-g.qmd'),
        ])
    }

    if(version == '1.0.6') {
        applyUpdate([
            join('utils', 'exports', 'export-config.R'),
        ])
    }

    if(version == '1.0.7') {
        seen = false
        applyUpdate([
            'utils',
            join('scripts', '2021-pilot-cbms'),
            join('qmd', 'section-r.qmd'),
        ])
    }

    // if(version == '1.0.8') {
    //     seen = false
    //     applyUpdate([
    //         join('utils', 'save-record.R')
    //     ])
    // }

    fs.writeJSONSync(path, { version: v, seen })
}
