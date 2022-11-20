import { ipcMain } from "electron";
import { spawn } from 'child_process' 
import { clearData } from "../utils/helpers";
import { rConfig } from "./checker/with-rconfig";
import { join } from 'path'

import { withRInstalled } from "../utils/helpers";
import { pilotDirectory } from "../utils/constants";

const os = process.platform == 'darwin'

const replacer = (str : string) => {
  return str != undefined ? str.replace(/(\r\n|\n|\r|\r\n)*/gm, '') : ''
}

export const piloExecuter = () => {
  
  ipcMain.on('run-script-pilot', (event, data) => {
      let rComm = os || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path;
      
      const rSpawn = spawn(rComm, [join(pilotDirectory, 'index.R')], { cwd: pilotDirectory });
      
      rSpawn.stdout.on('data', (data) => {

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

          if(code === 0 || code === 3221225477) {
            rSpawn.kill('SIGKILL')
            rSpawn.stderr.destroy()
            rSpawn.stdout.destroy()
            event.reply('stop-processing')
          }
      })

      ipcMain.on('kill-rspawn', () => {
        rSpawn.kill('SIGKILL')
        rSpawn.stderr.destroy()
        rSpawn.stdout.destroy()
        event.reply('stop-processing')
      })      
  })
}
