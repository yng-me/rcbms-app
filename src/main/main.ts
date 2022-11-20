import { app, BrowserWindow, dialog, ipcMain } from 'electron';
import { join } from 'path';
import { exec, spawn } from 'child_process'
import fs from 'fs-extra'
import yaml from 'js-yaml'

import { autoUpdater } from 'electron-updater'
// import log from 'electron-log'
// log.transports.console.format = '{h}:{i}:{s} {text}'
// log.transports.file.resolvePath = () => join('C:\\Users\\Bhas\\Desktop\\app\\rcbms\\src', 'logs/main.log')
// log.info('Hello')
// log.warn('Problem')

// before-mount
import { rcbmsCheck } from './modules/checker/with-rcmbs'

// mounted
import { exportLogCheck } from './modules/checker/with-export-log'
import { csdbeCheck } from './modules/checker/with-csdbe'
import { textDataCheck } from './modules/checker/with-text-data'
import { rConfig, withYamlConfig } from './modules/checker/with-rconfig';
import { referenceDictionaryCheck } from './modules/checker/with-reference';

import { 
  withCSProInstalled,
  withRData, 
  withJustification, 
  withOutputFolder,
  withRInstalled,
  withRStudioInstalled,
  withQuartoInstalled,
  withEditedData,
  withDownloadedData,
  withParquetData,
  toParquet,
  withRCBMSFolder,
  getFileLabel,
  withPilotData
} from './utils/helpers'

// execution
import { executer } from './modules/executer'
import { dataLoader } from './modules/loader'
import { updateRCBMS } from './modules/updater';
import { base } from './utils/constants';
import { pilotDataLoader } from './modules/loader-pilot';
import { piloExecuter } from './modules/executer-pilot';

const os = process.platform === 'darwin'
const dev = process.env.NODE_ENV === 'development'

let mainWindow : BrowserWindow

function createWindow () {

  mainWindow = new BrowserWindow({
    width: dev ? 1200: 985,
    height: 775,
    autoHideMenuBar: true,  
    minWidth: 550,
    minHeight: 535,
    icon: join(app.getAppPath(), 'static', 'assets/hero.ico'),
    // resizable: false,
    maximizable: false,
    webPreferences: {
      preload: join(__dirname, 'preload.js'),
      nodeIntegration: true,
      contextIsolation: true,
      devTools: dev ? true : false,
    }
  });
  
  ipcMain.on('view-output', (event, section) => {
    let childWindow = new BrowserWindow({ 
      height: 920,
      width: 1080,
      autoHideMenuBar: true,
      parent: mainWindow 
    })

    const htmlFile = section === 'Cross-section' 
      ? 'index.html'
      : `qmd\\section-${section.slice(-1).toLowerCase()}.html`

    const htmlPath = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/_book/' + htmlFile : join(base, '_book', htmlFile)

    childWindow.loadFile(htmlPath)
    childWindow.show()

  })  
  
  if (dev) {

    const rendererPort = process.argv[2];
    mainWindow.webContents.openDevTools();

    mainWindow.loadURL(`http://localhost:${rendererPort}`);
    
  } else {

    mainWindow.loadFile(join(app.getAppPath(), 'renderer', 'index.html'));
  } 
  

}

app.whenReady().then(() => {

  createWindow();
  autoUpdater.checkForUpdatesAndNotify()

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });

});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
});

ipcMain.on('before-mount', (event, data) => {
  const r = rcbmsCheck()
  updateRCBMS()

  event.reply('done-copying-resources', r.loading)
})

const mountedPayload = () => {

  const p = rConfig().run_after_edit ? withEditedData().path : withDownloadedData().path
  const csdbeList = getFileLabel(csdbeCheck(p).files)

  const source = rConfig().use_pilot_data ? '2021-pilot-cbms' : '2022-cbms'

  return {
    rConfig: rConfig(), 
    exportLog: exportLogCheck().data,
    withRData: withRData(), 
    withPilotData: withPilotData(),
    textDataCheck: textDataCheck(source), 
    withEditedData: { ...withEditedData(), isAvailable: csdbeCheck(withEditedData().path).isAvailable }, 
    withDownloadedData: { ...withDownloadedData(), isAvailable: csdbeCheck(withDownloadedData().path).isAvailable }, 
    withJustification: withJustification(), 
    withOutputFolder: withOutputFolder(rConfig().use_pilot_data),
    withRInstalled: os ? { isAvailable : true, path: 'Not applicable' } : withRInstalled(), 
    withRStudioInstalled: os ? { isAvailable : true, path: 'Not applicable' } : withRStudioInstalled(), 
    withQuartoInstalled: os ? { isAvailable : true, path: 'Not applicable' } : withQuartoInstalled(), 
    withCSProInstalled: os ? { isAvailable : true, path: 'Not applicable' } : withCSProInstalled(),
    withParquetData: withParquetData().isAvailable,
    csdbeList
  }
}

ipcMain.on('mounted', (event, data) => {
  event.reply('mounted', mountedPayload())
})

executer()
pilotDataLoader()
piloExecuter()
dataLoader()

ipcMain.on('open-output-folder', (event, data) => {
  const { path } = withOutputFolder(data)
  const output = os ? `open "/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/output"` : `start "" "${path}"`
  exec(output);
})

ipcMain.on('update-r-config', (event, data) => {

  const payload = { ...rConfig(), ...data }

  fs.writeFile(withYamlConfig().path, yaml.dump(payload), () => {
    setTimeout(() => {
      event.reply('yaml-config-saved')
      event.reply('mounted', { ...mountedPayload(), rConfig: payload })
    }, 750);
  })
})

ipcMain.on('check-text-data', (event, data) => {
  event.reply('check-text-data', textDataCheck(data))
})

ipcMain.on('configure-path', (event, payload) => {
  dialog.showOpenDialog({properties: [payload.property] }).then((response : any) => {
    if (!response.canceled) {
      // console.log(payload);
      console.log(response.filePaths[0]);

      const newPath = response.filePaths[0];
      const updatedConfig = { 
        ...rConfig(), 
        paths: { 
          ...rConfig().paths, 
          [payload.config]: newPath 
        }
      }

      fs.writeFile(withYamlConfig().path, yaml.dump(updatedConfig), () => {
        setTimeout(() => {      
          const newPayload = { ...mountedPayload(), rConfig: updatedConfig }
  
          event.reply('mounted', newPayload)
        }, 1000);
      })
      
    } else {
      console.log("no file selected");
    }
    event.reply('saved-path-config')
  })
})

ipcMain.on('load-dictionary', (event, req) => {
  

  const rcmbsPath = withRCBMSFolder().path

  const { filePath, fileDirectory } = withParquetData()

  const parquet = os ? join(fileDirectory, `${req.record}.parquet`) : `${fileDirectory}/${req.record}.parquet`

  const rPath = os || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path;
  
  const pq = `${toParquet(parquet)} \nprint(jsonlite::toJSON(names(df)))`

  let pqText = ''
  const v = spawn(rPath, ['-e', pq], { cwd: rcmbsPath })
  v.stdout.on('data', (data) => pqText += data.toString())
  v.stderr.on('data', (err) => console.log(err.toString()))

  v.on('close', (code) => {
    if(code == 0) {
      event.reply('variables', JSON.parse(pqText))
    }
  })

  if(req.include) {
    
    const dictionary = referenceDictionaryCheck().data
  
    const geoRun = `df <- arrow::open_dataset('${filePath}') |> \ndplyr::collect() \nprint(jsonlite::toJSON(df))`
  
    const g = spawn(rPath, ['-e', geoRun], { cwd: rcmbsPath })
  
    let geoText = ''
  
    g.stdout.on('data', (data) => geoText += data.toString())
    g.stderr.on('data', (err) => console.log(err.toString()))
  
    g.on('close', (code) => {
      if(code == 0) {
        const payload  = { 
          dictionary,
          geo: JSON.parse(geoText)
        }
        event.reply('dictionary', payload)
      }
    })
  }

})

ipcMain.on('arrow', (event, req) => {
    
  const a = Object.values(req.group)
  const b = Object.keys(req.group)
  let g : string[] = []

  a.forEach((el, key) => {
    if(el) {
      g.push(b[key])
    }
  })


  const rcmbsPath = withRCBMSFolder().path
  const { fileDirectory } = withParquetData()
  const parquet = os ? join(fileDirectory, `${req.record}.parquet`) : `${fileDirectory}/${req.record}.parquet`
  const rPath = os || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path;

  const adorn = req.col !== '' ? "c('row', 'col')" : ''
  let filter = ''
    
  if (req.prov != '' && req.cityMun != '' && req.brgy != '') {
    filter = `\ndplyr::filter(province == '${req.prov}', city_mun == '${req.cityMun}', brgy == '${req.brgy}') |>`
  } else if (req.prov != '' && req.cityMun != '') {
    filter = `\ndplyr::filter(province == '${req.prov}', city_mun == '${req.cityMun}') |>`
  } else if (req.prov != '') {
    filter = `\ndplyr::filter(province == '${req.prov}') |>`
  }

  let select = ''

  if(g.length) {
    const gFlat = g.join(', ')
    select = `${gFlat}, `
  }

  let tabulate = ''

  if(req.col !== '') {
    select += `${req.row}, ${req.col}`
    tabulate = `dplyr::group_by(${select}) |>
    dplyr::count() |>
    tidyr::pivot_wider(names_from = ${req.col}, values_from = n, values_fill = 0) |>
    dplyr::rename_at(dplyr::vars(dplyr::matches('^NA$')), ~ stringr::str_replace(., '^NA$', 'Missing / NA'))`
  } else {
    tabulate = `dplyr::count(${req.row}) |> \ndplyr::rename(Frequency = n)`
    select += req.row
  }

  const runR = `
    ts <- list()
    ${toParquet(parquet)}
    ts$data <- df |> ${filter}
      dplyr::select(${select}) |>
      dplyr::collect() |>
      ${tabulate} |>
      janitor::adorn_totals(${adorn}) 
    ts$name <- names(df)
    print(jsonlite::toJSON(ts))
  `
  
   const sp = spawn(rPath, ['-e', runR], { cwd: rcmbsPath }) 

   let s = ''
   sp.stdout.on('data', (data) => s += data.toString())
   sp.stderr.on('data', (err) => console.log(err.toString()))

   sp.on('close', (code) => {
    if(code == 0) {
      const df = JSON.parse(s)
      const payload  = { variables: df.name, data: df.data }
       
      event.reply('return-arrow', payload)
    }
   })
})

const sendStatusToWindow = (text: string | {}, event: string = 'on-update') => { 
  // log.info(text)
  mainWindow.webContents.send(event, text);
}

autoUpdater.on('update-available', () => {
  sendStatusToWindow('New version of RCBMS is available.')
})
  
autoUpdater.on('checking-for-update', () => {
  sendStatusToWindow('Checking for updates...');
})

autoUpdater.on('update-downloaded', (a) => {
  sendStatusToWindow('Update downloaded successfully! Please restart RCBMS to apply the changes.')
})

autoUpdater.on('error', (err) => {
  sendStatusToWindow('Sorry! There was an error updating RCBMS.');
})

autoUpdater.on('download-progress', (p) => {
  sendStatusToWindow('Downloading in progress...'); 

  let msg = "Download speed: " + p.bytesPerSecond;
  msg = msg + ' - Downloaded ' + p.percent + '%';
  msg = msg + ' (' + p.transferred + "/" + p.total + ')';
  sendStatusToWindow(p, 'percent');
})