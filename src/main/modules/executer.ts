import { dialog, ipcMain } from "electron";
import { spawn } from 'child_process' 
import { clearData } from "../utils/helpers";
import { rConfig } from "./checker/with-rconfig";
import { join } from 'path'

import { withRInstalled, withQuartoInstalled } from "../utils/helpers";
import { base } from "../utils/constants";

const isMac = process.platform == 'darwin'

const replacer = (str : string) => {
  return str != undefined ? str.replace(/(\r\n|\n|\r|\r\n)*/gm, '') : ''
}

export const executer = () => {
  
  ipcMain.on('run-script', (event, data) => {
    
      let rComm = isMac || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path;
      
      // checking for R packages

      const filePath = join('utils', 'library.R')

      try {
        const rSpawn = spawn(rComm, [filePath], { cwd: base });
        
        rSpawn.stdout.on('data', (data) => {
            console.log(data.toString());
  
            if(data.toString().search('Loading packages...') != -1) {
              const rStatus = {
                error: false,
                count: 1,
                message: replacer(data.toString().replace(/(.*\")(.*)(")/g, '$2')),
                log: replacer(data.toString().replace(/(.*\")(.*)(")/g, '$2'))
              }
              event.reply('rstatus', rStatus)
            }
  
            if(data.toString().search("package .* successfully .*") != -1 || data.toString().search("package .* successfully .*") != -1) {
              const rStatus = {
                error: false,
                count: 0,
                message: replacer(data.toString()),
                log: replacer(data.toString())
              }
              event.reply('rstatus', rStatus)
  
            }
  
  
            if(data.toString().search("Error in install.packages") != -1 || data.toString().search('[Permission|Access] denied') != -1) {
              const rStatus = {
                error: true,
                count: 0,
                message: replacer(data.toString()),
                log: replacer(data.toString())
              }
              event.reply('rstatus', rStatus)
  
              rSpawn.kill('SIGKILL')
  
            }
  
        });
  
        rSpawn.stderr.on('data', (data) => {
            console.log('stderr: ' + data);
            console.log(data.toString().search("error"));
            console.log(rSpawn.connected);
  
            if ((data.toString().search("[Ee]rror") != -1 || data.toString().search('[Permission|Access] denied') != -1) ) {
  
              const rStatus = {
                error: true,
                count: 0,
                message: 'Package installation failed. Try again or install it manually from the RStudio IDE.',
                log: data.toString()
              }
              
              event.reply('rstatus', rStatus)
              // console.log('process has been killed - "error" keyword found in stderr!');
              rSpawn.kill('SIGKILL')
            }
  
        });
  
        rSpawn.on('close', function (code) {
            // console.log('child process exited with code ' + code);
  
            if(code === 0 || code === 3221225477) {
  
              const qComm = isMac ? 'quarto' : withQuartoInstalled().path
              const qSpawn = spawn(qComm, ['render'], { cwd: base })
            
              // console.log(qSpawn);
              
              qSpawn.stdout.on('data', (data) => {
                console.log(data.toString());
                
              })
            
              qSpawn.stderr.on('data', (e) => {
  
                let rStatus : any
  
                // console.log(e.toString());
                
  
                const l = e.toString().search('processing file:.*.qmd')
                if(l != -1) {
                  
                  const regex = /processing file:.*(index|summary|cross-section|section-[a-s]).qmd/gm
                  const s = e.toString().match(regex)
  
                  const title = s[0].replace(regex, '$1')
  
                  let section = ''
  
                  if(title == 'cross-section') {
                    section = 'Processing Cross-section...'
  
                  } else if (title == 'index') {
                    section = 'Importing data files...'
  
                  } else if (title == 'summary') {
                    section = 'Exporting Excel file...'
                  } else if (title.match(/section-[a-z]/).length) {
  
                    const b = title.toUpperCase()
  
                    const bc : string = b.split('-')[1]
                    section = `Processing Section ${bc}...`
                  }
  
                  rStatus = {
                    error: false,
                    count: 1,
                    message: section,
                    log: section
                  }
  
                  event.reply('rstatus', rStatus)
  
                }
                
                const execHalted = e.toString().search("[Ee]xecution [Hh]alted") != -1 
                
                if(execHalted || e.toString().search('Unable to locate an installed version of R') != -1) {
                  // console.log(e.toString());
  
                  rStatus = {
                    error: true,
                    count: 0,
                    message: 'Processing failed!',
                    log: e.toString()
                  }
  
                  event.reply('rstatus', rStatus)
                  qSpawn.kill('SIGKILL')
                  qSpawn.stderr.destroy()
                  qSpawn.stdout.destroy()
                  
                }
              })
            
              qSpawn.on('close', (d) => {
            
                if(d === null) {
                  event.reply('stop-spawn')
                } else {
                  event.reply('done-processing')
                }
                if(rConfig().clear) {
                  clearData(join(base, 'data\\csdb'))
                  clearData(join(base, 'data\\text'))
                }
              })
  
              ipcMain.on('kill-rspawn', () => {
                qSpawn.kill('SIGKILL')
                qSpawn.kill()
                qSpawn.stderr.destroy()
                qSpawn.stdout.destroy()
                event.reply('stop-spawn')
              })
            }
        })
  
        ipcMain.on('kill-rspawn', () => {
          rSpawn.kill('SIGKILL')
          rSpawn.kill()
          rSpawn.stderr.destroy()
          rSpawn.stdout.destroy()
          event.reply('stop-spawn')
        })      
      } catch {
        dialog.showErrorBox('Generating Cases with Inconsistencies', 'There was an error in generating cases with inconsistencies. Please try again.')
      }
  })
}
