import fs from 'fs-extra'
import { extname } from 'path'
import { exec } from 'child_process'
import { withCSProInstalled } from '../utils/helpers'

const temp = require('temp')
temp.track()

const csproVersion = '7.7'

export const concatCSDB = (
    dataFolder : string, 
    outputFolder: string,
    fpvpf = undefined as string | undefined,
    selectedFiles = [] as string[],
    minFileRequired = 1,
    dictionary: string
) => {

    const logList = `${outputFolder}\\log.lst`
    fs.writeFileSync(logList, '')

    const { csconcat_path } = withCSProInstalled()

    const ext = fpvpf === undefined ? 'csdb' : 'csdbe'

    fs.promises.readdir(dataFolder, { withFileTypes: true }).then(res => {

        const outputDestination = `${outputFolder}\\concatenated.csdbe|password=${fpvpf}`
        
        let validFiles: string[] = []
        
        res.forEach(item => {
          if(item.isFile()) validFiles.push(item.name);
        })

        const concat = selectedFiles.length > 0
            ? validFiles.filter(el => extname(el) === ext).filter(file => selectedFiles.includes(file)).map(item => join(dataFolder, item))
            : validFiles.filter(el => extname(el) === ext).map(item => join(dataFolder, item))

        if(concat.length > minFileRequired - 1) {
            
          let concatFile = '';
          concat.forEach(text => concatFile += `InputData=${text}|password=${fpvpf}\n`)
          
          // Read concat text and insert the encrypted files with password
          const pffStartConcat = `[Run Information]\nVersion=CSPro ${csproVersion}\nAppType=Concatenate\nShowInApplicationListing=Never\n\n[Files]`
          const pffEnd = '[Parameters]\nLanguage=EN\nViewListing=Never\nViewResults=No\nInputOrder=Sequential'
    
          const concatPffTxt = `${pffStartConcat}\n${concatFile}OutputData=${outputDestination}\nInputDict=${dictionary}\nListing=${logList}\n\n${pffEnd}`;
          const concatPffTemp = temp.openSync({ suffix: '.pff' });
    
          fs.writeSync(concatPffTemp.fd, concatPffTxt);
          fs.closeSync(concatPffTemp.fd);
    
          exec(`"${csconcat_path}" "${concatPffTemp.path}"`, () => {
            temp.cleanupSync()

            

          })

        }
    })
    
}


export const exportCSDB = () => {

    const { csexport_path } = withCSProInstalled()

    if(!fs.existsSync('C:\\rcbms\\data\\text')) fs.mkdirSync('C:\\rcbms\\data\\text');
    const exfStart = '[CSExport]\nVersion=CSPro 7.7\n\n[Dictionaries]';
    const pffStartExport = '[Run Information]\nVersion=CSPro 7.7\nAppType=Export\nShowInApplicationListing=Never\n\n[Files]';
}