import { join, extname } from 'path'
import fs from 'fs-extra'
import { rConfig } from '../modules/checker/with-rconfig'
import { base } from './constants'
import XLSX from 'xlsx'

export const foryourconsideration = '100ad4ecac23db231981211bb1cc142e3453d96'

const os = process.platform == 'darwin'

export const clearData = (path : string) : void => {
    if(fs.pathExistsSync(path)) {
        fs.rmSync(path, { recursive: true, force: true })
    }
}

// R installation
export const withCSProInstalled = () => {
    const { paths } = rConfig()
    return { 
        isAvailable: fs.pathExistsSync(paths.cspro_path) && fs.pathExistsSync(paths.csconcat_path) && fs.pathExistsSync(paths.csexport_path),  
        path: paths.cspro_path,
        csconcat_path: paths.csconcat_path,
        csexport_path: paths.csexport_path,
        key: 'cs_pro'
    }
}

// R installation
export const withRInstalled = () => {
    const { paths } = rConfig()
    return { isAvailable: fs.pathExistsSync(paths.r_path),  path: paths.r_path, key: 'r_path' }
}

// RStudio installation
export const withRStudioInstalled = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.rstudio_path), path: paths.rstudio_path, key: 'rstudio_path' } 
}

// Quarto
export const withQuartoInstalled = () => {
    const { paths } = rConfig()
    
    return { isAvailable: fs.pathExistsSync(paths.quarto_path), path: paths.quarto_path, key: 'quarto_path' } 
}

// RCBMS folder
export const withRCBMSFolder = () => {
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms' : base 
    return { isAvailable: fs.existsSync(path), path }  
}

// text data
export const withTextData = () => {
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/text' : join(base, 'data', 'text')
    return { isAvailable: fs.pathExistsSync(path), path } 
}

// RData
export const withRData = () => {
    const { paths } = rConfig()
    const ext = extname(paths.rdata_path)
    const validExt = ext === '.Rdata' || ext === '.rdata' || ext === '.RData'

    return { isAvailable: fs.pathExistsSync(paths.rdata_path) && validExt, path: paths.rdata_path, key: 'rdata_path' } 
}

// Downloaded folder
export const withDownloadedData = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.before_edit_path), path: paths.before_edit_path, key: 'before_edit_path' } 
}

// Edited folder
export const withEditedData = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.after_edit_path), path: paths.after_edit_path, key: 'after_edit_path' } 
}

// Output folder
export const withOutputFolder = (use_pilot_data: boolean = false) => {
    const path = use_pilot_data 
        ? rConfig().paths.pilot_output_path
        : rConfig().paths.output_path
    
    const key = use_pilot_data ? 'pilot_output_path' : 'output_path'

    return { isAvailable: fs.pathExistsSync(path), path, key } 
}

// Data dictionary
export const withDataDict = () => {
    const path = join(base, 'references\\HPQF2_DICT.dcf')
    return { isAvailable: fs.pathExistsSync(path), path } 
}

// Export logs
export const withExportLog = () => {
    const { paths } = rConfig()

    const path = join(paths.output_path, 'Export Logs.xlsx')
    return { isAvailable: fs.pathExistsSync(path), path } 
}

// Justification
export const withJustification = () => {
    const { paths } = rConfig()

    const ext = extname(paths.rdata_path)
    const validExt = ext === '.xlsx' || ext === '.XLSX'

    return { isAvailable: fs.pathExistsSync(paths.justification_path) && validExt, path: paths.justification_path, key: 'justification_path' } 
}

// Reference
export const withReferenceDictionary = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.reference_path), path: paths.reference_path, key: 'reference_path' } 
}

export const withPilotData = () => {
    const { paths } = rConfig()
    return { isAvailable: fs.pathExistsSync(paths.pilot_data_path), path: paths.pilot_data_path, key: 'pilot_data_path' } 
}

export const withPilotDataDict = () => {
    const { paths } = rConfig()
    return { isAvailable: fs.pathExistsSync(paths.pilot_data_dict_path), path: paths.pilot_data_dict_path, key: 'pilot_data_dict_path' } 
}


// Reference
export const withParquetData = () => {

    const pathToGeo = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/geo.parquet' : join(base, 'data', 'parquet', 'geo.parquet')
    const pathtoDict = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/parquet_dictionary.parquet' : join(base, 'data', 'parquet', 'parquet_dictionary.parquet')
    const directory = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet' : join(base, 'data', 'parquet')
    const fileDirectory = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet' : './data/parquet'
    const geoPath = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/geo.parquet' : './data/parquet/geo.parquet'
    const dictionaryPath = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/parquet_dictionary.parquet' : './data/parquet/parquet_dictionary.parquet'

    return { 
        isAvailable: fs.pathExistsSync(pathToGeo),
        isDictionaryAvailable: fs.pathExistsSync(pathtoDict),
        path: pathToGeo, 
        directory, 
        fileDirectory,
        geoPath, 
        dictionaryPath
    }
}


export const toParquet = (path: string) => {
    return `
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
        
        df <- arrow::open_dataset('${path}') |>
            convert_fct_cv() 
    `
}

export const getVersion = () => {
    
    const path = join(withRCBMSFolder().path, 'utils', 'version.json')

    let v = { path, version: '', seen: false }
    
    if(!fs.existsSync(path)) {
        try {
            // const version = process.env.NODE_ENV === 'development' 
            //     ? require('../../../package.json').version
            //     : app.getVersion()
            const version = '1.0.0'

            fs.writeJSONSync(path, { version })
            v = { ...v, version }
        } catch {
            console.log('Error in creating version file');
        }

    } else {
        const o = fs.readJSONSync(path)
        let seen = o.seen
        if(o.seen == undefined) {
            seen = true
        }

        v = { ...v, version: o.version,  seen }
    }

    return v

}


export const getFileLabel = (files : string[]) => {
    try {         

        const psgc = join(base, 'references', 'psgc.xlsx')
        const workbook = XLSX.readFile(psgc);
        const sheet_name_list = workbook.SheetNames;
        const xlData = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]])
            .map((item : any) => {
                return {
                    code: item['Correspondence Code'],
                    cityMun: item['City/Municipality'],
                    brgy: item['Name']
                }
            })
            
        return files.map((file : string) => {
            return {
                file,
                ean: file.substring(10, 16),
                ...xlData.find(el => el.code == file.substring(1, 10))
            }
        })

    } catch {
        console.log('Error');
        return [
            { file: '', ean: '', code: '', cityMun: '', brgy: '' }
        ]
    }

}


export const getPilotFileLabel = (files : string[]) => {
    try {         

        const psgc = join(base, 'references', 'psgc.xlsx')
        const workbook = XLSX.readFile(psgc);
        const sheet_name_list = workbook.SheetNames;
        const xlData = XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]])
            .map((item : any) => {
                return {
                    code: item['Correspondence Code'],
                    cityMun: item['City/Municipality'],
                    brgy: item['Name']
                }
            })
            
        return files.map((file : string) => {
            return {
                file,
                ean: file.substring(10, 16),
                ...xlData.find(el => el.code == file.substring(1, 10))
            }
        })

    } catch {
        console.log('Error');
        return [
            { file: '', ean: '', code: '', cityMun: '', brgy: '' }
        ]
    }

}
