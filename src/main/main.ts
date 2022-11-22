import { app, BrowserWindow, dialog, ipcMain } from 'electron';
import { join } from 'path';
import { exec, spawn, execSync } from 'child_process'
import fs from 'fs-extra'
import yaml from 'js-yaml'

export interface Geo {
  region?: string
  province: string
  city_mun: string
  brgy: string
  reg_psgc?: number
  prov_psgc?: number
  city_mun_psgc?: number
  brgy_psgc?: number
}

export interface TableOptions {
  rowRecord: string
  colRecord: string
  colRecordLabel?: string
  joinType?: string
  joinVariables: string[]
  joinAll?: boolean,
  row: string
  col: string
  geoFilter: Geo,
  groupBy: TableOptionsGrouping
}

export interface TableOptionsGrouping {
  province: boolean
  city_mun: boolean
  brgy: boolean
  ean: boolean
}

import { autoUpdater } from 'electron-updater'

// before-mount
import { rcbmsCheck } from './modules/checker/with-rcmbs'

// mounted
import { exportLogCheck } from './modules/checker/with-export-log'
import { csdbeCheck } from './modules/checker/with-csdbe'
import { textDataCheck } from './modules/checker/with-text-data'
import { rConfig, withYamlConfig } from './modules/checker/with-rconfig';

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
  withRCBMSFolder,
  getFileLabel,
  withPilotData,
  getVersion
} from './utils/helpers'

// execution
import { executer } from './modules/executer'
import { dataLoader } from './modules/loader'
import { updateRCBMS } from './modules/updater';
import { base } from './utils/constants';
import { pilotDataLoader } from './modules/loader-pilot';
import { piloExecuter } from './modules/executer-pilot';

const isMac = process.platform === 'darwin'
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

    const htmlPath = isMac ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/_book/' + htmlFile : join(base, '_book', htmlFile)

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
    // On macisMac it's common to re-create a window in the app when the
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

  const { seen } = getVersion()
  if(seen == undefined || seen == false) {
    event.reply('show-changelog')
  }

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
    withPilotData: { ...withPilotData(), isAvailable: csdbeCheck(withPilotData().path, '.csdb').isAvailable },
    textDataCheck: textDataCheck(source), 
    withEditedData: { ...withEditedData(), isAvailable: csdbeCheck(withEditedData().path).isAvailable }, 
    withDownloadedData: { ...withDownloadedData(), isAvailable: csdbeCheck(withDownloadedData().path).isAvailable }, 
    withJustification: withJustification(), 
    withOutputFolder: withOutputFolder(rConfig().use_pilot_data),
    withRInstalled: isMac ? { isAvailable : true, path: 'Not applicable' } : withRInstalled(), 
    withRStudioInstalled: isMac ? { isAvailable : true, path: 'Not applicable' } : withRStudioInstalled(), 
    withQuartoInstalled: isMac ? { isAvailable : true, path: 'Not applicable' } : withQuartoInstalled(), 
    withCSProInstalled: isMac ? { isAvailable : true, path: 'Not applicable' } : withCSProInstalled(),
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
  const output = isMac ? `open "/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/output"` : `start "" "${path}"`
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
  const rPath = isMac || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path
  const { geoPath, dictionaryPath, isDictionaryAvailable } = withParquetData()

  if(!isDictionaryAvailable) {
    const dPath = join('utils', 'save-parquet.R')
    execSync(`"${rPath}" "${dPath}"`, { cwd: rcmbsPath })
  }

  const mode = rConfig().use_pilot_data ? '2021-pilot-cbms' : '2022-cbms'
  const pathMode = join(rcmbsPath, 'scripts', mode, 'store')
  const pathTable = join(pathMode, 'tables.json')
  let savedTables = []
  
  if(fs.existsSync(pathTable)) {
    savedTables = fs.readJSONSync(pathTable)
  }
  
  const script = `
    df <- list()
    df[['geo']] <- arrow::open_dataset('${geoPath}') |> dplyr::collect()
    df[['dictionary']] <- arrow::open_dataset('${dictionaryPath}') |> dplyr::collect()
    jsonlite::toJSON(df, pretty = T)
  `
  const g = spawn(rPath, ['-e', script], { cwd: rcmbsPath })
  
    let df = ''
  
    g.stdout.on('data', (data) => df += data.toString())
    g.stderr.on('data', (err) => console.log(err.toString()))
  
    g.on('close', (code) => {
      if(code == 0) {
        const payload  = { ...JSON.parse(df) }
        event.reply('dictionary', { ...payload, savedTables })
      }
    })
})

ipcMain.on('arrow', (event, request) => {

  const req : TableOptions = request

  const rcmbsPath = withRCBMSFolder().path
  const { fileDirectory } = withParquetData()
  const parquetPath = isMac ? join(fileDirectory, `${req.rowRecord}.parquet`) : `${fileDirectory}/${req.rowRecord}.parquet`
  const rPath = isMac || !withRInstalled().isAvailable ? 'Rscript' : withRInstalled().path;

  const adorn = req.col !== '' ? "c('row', 'col')" : ''
  const filter = Object.entries({...req.geoFilter})
    .filter(item => item[1] != '') 
    .map(el => `${el[0]} == '${el[1]}'`)

  const filterScript = filter.length ?  `dplyr::filter(${filter.join(', ')}) |>` : ''

  const group_by = Object.entries({...req.groupBy})
    .filter(item => item[1] === true) 
    .map(el => el[0])

  const select = [...group_by, req.row, req.col].filter(el => el !== '')

  let joinBy = ''
  let dfJoin = ''
  if(req.rowRecord !== req.colRecord) {
    const joinType = req.joinType?.split(' ').join('_').toLowerCase()
    const joinParquet = isMac ? join(fileDirectory, `${req.colRecord}.parquet`) : `${fileDirectory}/${req.colRecord}.parquet`
    const cVariables = req.joinVariables.map(el => `'${el}'`).join(', ')
    const joinVariables = [...req.joinVariables, req.col].join(', ')
    dfJoin = `df_join <- arrow::open_dataset('${joinParquet}') |> dplyr::select(${joinVariables}) \n`
    joinBy = `dplyr::${joinType}(df_join, by = c(${cVariables})) |>`
  }
  
  let tabulate = ''

  if(req.col !== '') {
    tabulate = `dplyr::group_by(${select.join(', ')}) |>
      dplyr::count() |>
      dplyr::collect() |>
      tidyr::pivot_wider(names_from = ${req.col}, values_from = n, values_fill = 0) |>
      dplyr::rename_at(dplyr::vars(dplyr::matches('^NA$')), ~ stringr::str_replace(., '^NA$', 'Missing / NA'))`
  } else {
    tabulate = `dplyr::group_by(${select.join(', ')}) |> dplyr::count() |> \ndplyr::rename(Frequency = n) |> \ndplyr::collect()`
  }  

  const script = `
    convert_fct_cv <- function(data) {
          
      names <- tibble::as_tibble(names(data)) 
      
      fct_replace <- names |>
        dplyr::filter(grepl('_fct$', value)) |>
        dplyr::mutate(value = stringr::str_remove(value, '_fct$')) |>
        dplyr::filter(value %in% names$value) |>
        dplyr::mutate(value = paste0('^', value, '$')) |>
        dplyr::pull(value) 
      
      df <- data |>
        dplyr::select(-dplyr::matches(fct_replace)) |>
        dplyr::rename_at(dplyr::vars(dplyr::matches('_fct$')), ~ stringr::str_remove(., '_fct$'))
      
      return(df)
    }

    ${dfJoin} \n

    df <- arrow::open_dataset('${parquetPath}') |> ${joinBy} ${filterScript}
      convert_fct_cv() |>
      dplyr::select(${select.join(', ')}) |>
      ${tabulate} |>
      janitor::adorn_totals(${adorn})

      print(jsonlite::toJSON(df))
  `

  try {
    const sp = spawn(rPath, ['-e', script], { cwd: rcmbsPath }) 
  
    let df = ''
    sp.stdout.on('data', (data) => df += data.toString())
    sp.stderr.on('data', (err) => console.log(err.toString()))
  
    sp.on('close', (code) => {
     if(code == 0) {
       const payload = JSON.parse(df)
       event.reply('return-arrow', {
         data: payload,
         script
       })
     }
    })
  } catch {
    dialog.showErrorBox('Data Tabulation', 'Sorry, there was an error encoutered for tabulating the selected variables.')
  }
   
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

ipcMain.on('seen-changelog', () => {
  const v = getVersion()
  fs.writeJSONSync(v.path, { version: v.version, seen: true })
})

ipcMain.on('save-table', (event, data) => {
  // const { path } = withRCBMSFolder()
  
  const mode = rConfig().use_pilot_data ? '2021-pilot-cbms' : '2022-cbms'
  const pathMode = join(base, 'scripts', mode, 'store')
  const pathTable = join(pathMode, 'tables.json')

  let payload = [{...data}]
  
  if(fs.existsSync(pathTable)) {
    const tables = fs.readJSONSync(pathTable)
    payload = [...tables, ...payload]
  } else {
    if(!fs.existsSync(join(base, 'scripts', mode))) fs.mkdirSync(join(base, 'scripts', mode))
    if(!fs.existsSync(pathMode)) fs.mkdirSync(join(pathMode))
  }
  
  fs.writeJSONSync(join(pathMode, 'tables.json'), payload)

  event.reply('saved-table', payload)

})

ipcMain.on('select-export-path', (event, data) => {

 dialog.showOpenDialog({properties: ['openDirectory'] }).then((response : any) => {
    if (!response.canceled) {
      // console.log(response.filePaths[0]);
      event.reply('selected-export-path', response.filePaths[0])
      
    } else {
      console.log("no file selected");
    }
  })
})