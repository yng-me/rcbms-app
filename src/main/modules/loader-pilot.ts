import { ipcMain, dialog, app } from 'electron'
import fs from 'fs-extra'
import { join, basename } from 'path'
import { exec, execSync } from 'child_process'

const temp = require('temp')
temp.track()

import { withPilotDataDict, withPilotData, withCSProInstalled } from '../utils/helpers'
import { pilotDirectory } from '../utils/constants'

const pilotAreas : string[] = [
    '013315 San Gabriel, La Union',
    '015542 Sual, Pangasinan',
    '023134 Santa Maria, Isabela',
    '030812 Samal, Bataan',
    '064527 City of Sipalay, Negros Occidental',
    '074609 Dauin, Negros Oriental',
    '083708 City of Baybay, Leyte',
    '141102 City of Baguio',
    '160301 City of Bayugan, Agusan del Sur'
]

const pilotGeo: string [] = pilotAreas.map(el => el.substring(1, 6))

const noDataError = {
  error: true,
  message: 'Please make sure you have downloaded the data files using DPS server. File directory: C:/PSA SYSTEMS FOLDER/CBMS-ROLLOUT/HPQ.',
}

export const pilotDataLoader = () : void => {

  ipcMain.on('load-pilot-data', (event, data) => {

    const { csconcat_path } = withCSProInstalled()
    const { path } = withPilotData()
    const dataDir = join('rcbms', 'scripts', '2021-pilot-cbms', 'data')
    const refDir = join('rcbms', 'scripts', '2021-pilot-cbms', 'references')
    const inputDict = withPilotDataDict().path

    if(!withPilotDataDict().isAvailable) {
      
        const pathFrom = join(app.getAppPath(), 'static', refDir, 'HPQF2_PILOT_DICT.dcf')
  
        try {
            fs.copySync(pathFrom, inputDict);
  
        } catch(err) {
  
            dialog.showErrorBox('Loading Data', 'There was a problem loading the reference files. Please restart the RCBMS App.')
  
            event.reply('data-loaded', {
                error: true,
                message: 'There was a problem loading the reference files. Please restart the RCBMS App.'
            });
      }

    }

    try {

        const logList = join('C:', refDir, 'log.lst')
        fs.writeFileSync(logList, '')

        fs.promises.readdir(path, { withFileTypes: true }).then(res => {
      
          // Filter only valid csdbe files
          let csdbe: string[] = []
          res.forEach(item => {
            if(item.isFile()) csdbe.push(item.name);
          })
          
          const csdbeConcat = csdbe.filter(el => /\.csdb$/g.test(el) && pilotGeo.includes(el.substring(1, 6)))
            .map(item => join(path, item));
          
            let csdbeAll = '';
            csdbeConcat.forEach(text => csdbeAll += `InputData=${text}\n`)
            
            // Read concat text and insert the encrypted files with password
            const pffStartConcat = '[Run Information]\nVersion=CSPro 7.7\nAppType=Concatenate\nShowInApplicationListing=Never\n\n[Files]'
            const pffEnd = '[Parameters]\nLanguage=EN\nViewListing=Never\nViewResults=No\nInputOrder=Sequential'
            const outputCSDBE = join(pilotDirectory, 'data', 'csdbe', 'concatenated-pilot.csdbe|password=293fnj<>aser@&e')

            
            const concatPffTxt = `${pffStartConcat}\n${csdbeAll}OutputData=${outputCSDBE}\nInputDict=${inputDict}\nListing=${logList}\n\n${pffEnd}`;
            const concatPffTemp = temp.openSync({ suffix: '.pff' });
            
            fs.writeSync(concatPffTemp.fd, concatPffTxt);
            fs.closeSync(concatPffTemp.fd);
            console.log(concatPffTxt);
      
            exec(`"${csconcat_path}" "${concatPffTemp.path}"`, (con) => {
                temp.cleanupSync()

                const { csexport_path } = withCSProInstalled();
                const pffPath = join(app.getAppPath(), 'static', 'pff', 'pilot');

                if(!fs.existsSync(join(dataDir, 'text'))) fs.mkdirSync(join(dataDir, 'text'))

                execSync(`"${csexport_path}" "${join(pffPath, 'Exported.exf.pff')}"`)
                execSync(`"${csexport_path}" "${join(pffPath, 'All.exf.pff')}"`)

                event.reply('data-loaded', {
                    error: false,
                    message: 'Data loaded successfully'
                })
            })

        })

    } catch {

      event.reply('data-loaded', noDataError)        
      dialog.showErrorBox('Loading Data', 'There was a problem loading the data files. Please restart the RCBMS App and download the data from the DPS server.')
      
    }
    })
} 

