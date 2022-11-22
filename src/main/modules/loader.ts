import { ipcMain, dialog, app } from 'electron'
import fs from 'fs-extra'
import { join, basename } from 'path'
import { exec, execSync } from 'child_process'
import Cryptr from 'cryptr'

const temp = require('temp')
temp.track()

const dev = process.env.NODE_ENV === 'development'

import { vb } from './checker/somewhere'
import { lv, all_that_can_be_expressed } from './checker/junk'
import { rConfig } from './checker/with-rconfig'
import { csdbeCheck } from './checker/with-csdbe'

import { 
  clearData, 
  withDataDict, 
  foryourconsideration,
  withDownloadedData, 
  withEditedData, 
  withCSProInstalled 
} from '../utils/helpers'



const noDataError = {
  error: true,
  message: 'Please make sure you have downloaded the data files using DPS server. File directory: C:/PSA SYSTEMS FOLDER/CBMS-ROLLOUT/HPQ.',
}

export const dataLoader = () : void => {

  ipcMain.on('load-data', (event, data) => {

    const { csconcat_path } = withCSProInstalled()
    const { csexport_path } = withCSProInstalled()

    const dataPath = rConfig().run_after_edit 
      ? withEditedData().path
      : withDownloadedData().path 

    const vv = foryourconsideration + data.myhalf
        
    if(!csdbeCheck(dataPath).isAvailable) {
      
      event.reply('data-loaded', noDataError)
      dialog.showErrorBox('CSDBE Data', 'No available data. Please download first from the DPS server.')
      
    } else {
      
        const vvv = vb + lv + vv        
        const cryptr = new Cryptr('vvv')        
        const fpvpf = rConfig().use_raw_data_from_tablet ? all_that_can_be_expressed + 'uo' : cryptr.decrypt(vvv)
        const inputDict = withDataDict().path
        const outputCsdbe = `C:\\rcbms\\data\\csdb\\concatenated.csdbe|password=${fpvpf}`

        if(dev) console.log(fpvpf)

        if(!withDataDict().isAvailable) {
          

          const pathFrom = join(app.getAppPath(), 'static', 'rcbms')
          const pathTo = 'C:\\rcbms'
      
          try {
            fs.copySync(pathFrom, pathTo);
      
          } catch(err) {
      
            dialog.showErrorBox('Loading Data', 'There was a problem loading the reference files. Please restart the RCBMS App.')
      
            event.reply('data-loaded', {
              error: true,
              message: 'There was a problem loading the reference files. Please restart the RCBMS App.'
            });
          }

        }
        try {
            const logList = 'C:\\rcbms\\references\\log.lst'
            fs.writeFileSync(logList, '')

            fs.promises.readdir(dataPath, { withFileTypes: true }).then(res => {
          
              // Filter only valid csdbe files
              let csdbe: string[] = []
              res.forEach(item => {
                if(item.isFile()) csdbe.push(item.name);
              })
              const csdbeConcat = csdbe.filter(el => /\.csdbe$/g.test(el))
                .filter(file => data.files.includes(file))
                .map(item => join(dataPath, item));

              const csdbeConcatLength = rConfig().use_raw_data_from_tablet ? csdbeConcat.length - 9 : csdbeConcat.length
          
              if(csdbeConcatLength > 0) {
                // Enumerate all csdbe files to be concatenated
                let csdbeAll = '';
                csdbeConcat.forEach(text => {
                  csdbeAll += `InputData=${text}|password=${fpvpf}\n`;
                })
                
                // Read concat text and insert the encrypted files with password
                const pffStartConcat = '[Run Information]\nVersion=CSPro 7.7\nAppType=Concatenate\nShowInApplicationListing=Never\n\n[Files]'
                const pffEnd = '[Parameters]\nLanguage=EN\nViewListing=Never\nViewResults=No\nInputOrder=Sequential'
          
                const concatPffTxt = `${pffStartConcat}\n${csdbeAll}OutputData=${outputCsdbe}\nInputDict=${inputDict}\nListing=${logList}\n\n${pffEnd}`;
                const concatPffTemp = temp.openSync({ suffix: '.pff' });
          
                fs.writeSync(concatPffTemp.fd, concatPffTxt);
                fs.closeSync(concatPffTemp.fd);
          
                exec(`"${csconcat_path}" "${concatPffTemp.path}"`, (con) => {
                  temp.cleanupSync()
          
                  if(!fs.existsSync('C:\\rcbms\\data\\text')) fs.mkdirSync('C:\\rcbms\\data\\text');
                  const exfStart = '[CSExport]\nVersion=CSPro 7.7\n\n[Dictionaries]';
                  const pffStartExport = '[Run Information]\nVersion=CSPro 7.7\nAppType=Export\nShowInApplicationListing=Never\n\n[Files]';
          
                  ['all', 'b', 'c', 'd', 'e'].forEach(item => {
          
                    // EXF
                    const inputFileForExf = `File=${inputDict}`
                    const exfEnd = fs.readFileSync(join(app.getAppPath(), 'static', 'pff', `${item}_exf.txt`));
          
                    const exfTempData = `${exfStart}\n${inputFileForExf}\n\n${exfEnd.toString()}`;
          
                    // const exportPathTemp = temp.path();
                    const exfPathTemp = temp.openSync({ suffix: '.exf' });
          
                    fs.writeSync(exfPathTemp.fd, exfTempData);
                    fs.closeSync(exfPathTemp.fd);
          
                    const exfBasePath = basename(exfPathTemp.path);
                      
                    // PFF
                    const exfApplication = `Application=.\\${exfBasePath}`
                    const inputData = `InputData=${outputCsdbe}`
                    let exfConfig = ''
          
                    if(item === 'all') {
                      exfConfig = fs.readFileSync(join(app.getAppPath(), 'static', 'pff', `${item}_pff.txt`)).toString();
                    } else {
                      exfConfig = `ExportedData=C:\\rcbms\\data\\text\\SECTION_${item.toUpperCase()}.txt\nListing=${logList}`
                    }
          
                    const pffExfTempData = `${pffStartExport}\n${exfApplication}\n${inputData}\n${exfConfig}\n\n${pffEnd}`
          
                    const exfPffPathTemp = temp.openSync({ suffix: '.exf.pff' });
          
                    fs.writeSync(exfPffPathTemp.fd, pffExfTempData);
                    fs.close(exfPffPathTemp.fd);
          
                    execSync(`"${csexport_path}" "${exfPffPathTemp.path}"`);
          
                    temp.cleanupSync()
                    
                  })
                  
                  if(rConfig().clear) {
                    clearData('C:\\rcbms\\data\\csdb')
                  }

                  event.reply('data-loaded', {
                    error: false,
                    message: 'Data loaded successfully'
                  })

                
                })
              } else {

                event.reply('data-loaded', { ...noDataError, message: 'Not enough data files to process. If you using csdbe files directly from the tablet, you must have a minimum of 10 files/HPQ.' })

              }
            })

        } catch {

          event.reply('data-loaded', noDataError)        
          dialog.showErrorBox('Loading Data', 'There was a problem loading the data files. Please restart the RCBMS App and download the data from the DPS server.')
          
        }
      }
    })
} 

