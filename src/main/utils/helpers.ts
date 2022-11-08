import { join } from 'path'
import fs from 'fs-extra'
import { rConfig } from '../modules/checker/with-rconfig'
import { app } from 'electron'

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
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms' : 'C:\\rcbms' 
    return { isAvailable: fs.existsSync(path), path }  
}

// text data
export const withTextData = () => {
    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/text' : 'C:\\rcbms\\data\\text'
    return { isAvailable: fs.pathExistsSync(path), path } 
}

// RData
export const withRData = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.rdata_path), path: paths.rdata_path, key: 'rdata_path' } 
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
export const withOutputFolder = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.output_path), path: paths.output_path, key: 'output_path' } 
}

// Data dictionary
export const withDataDict = () => {
    const path = 'C:\\rcbms\\references\\HPQF2_DICT.dcf'
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

    return { isAvailable: fs.pathExistsSync(paths.justification_path), path: paths.justification_path, key: 'justification_path' } 
}

// Reference
export const withReferenceDictionary = () => {
    const { paths } = rConfig()

    return { isAvailable: fs.pathExistsSync(paths.reference_path), path: paths.reference_path, key: 'reference_path' } 
}

// Reference
export const withParquetData = () => {

    const path = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/geo.parquet' : 'C:\\rcbms\\data\\parquet\\geo.parquet'
    const directory = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet' : 'C:\\rcbms\\data\\parquet'
    const filePath = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet/geo.parquet' : './data/parquet/geo.parquet'
    const fileDirectory = os ? '/Users/bhasabdulsamad/Desktop/R Codes/2022-cbms/data/parquet' : './data/parquet'

    return { isAvailable: fs.pathExistsSync(path), path, directory, filePath, fileDirectory } 
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
            dplyr::select(
                -dplyr::starts_with('a06'),
                -dplyr::matches('^a13_pcn2$'),
                -dplyr::ends_with('psgc'), 
                -dplyr::contains('line_number_id'), 
                -dplyr::starts_with('a01'), 
                -dplyr::matches('^geo$'),
                -dplyr::matches('^start$'),
                -dplyr::matches('^end$'),
                -dplyr::matches('^duration_hr$'),
                -dplyr::matches('^duration_min$'),
                -dplyr::matches('^a07_age'),
                -dplyr::matches('^ts$'),
                -dplyr::matches('^te$'),
                -dplyr::matches('_lnoctr$'),
                -dplyr::matches('^g51_fishops$'),
                -dplyr::matches('^g53a[ab]_oth$'),
                -dplyr::matches('^g53a[ab]_oth$'),
                -dplyr::matches('^g22a_agrimach_'),
                -dplyr::matches('^g29a_lvstckpltrymach_'),
                -dplyr::matches('^g42[abz]_aqufarmmach_'),
                -dplyr::matches('^g54a_oth_'),
                -dplyr::matches('^h[45][a-c]_total$'),
                -dplyr::matches('^h2$'),
                -dplyr::matches('^l27_raredisn1$'),
                -dplyr::matches('^o05[h-k]_lno$'),
                -dplyr::matches('^p0[56]k_comm$'),
                -dplyr::matches('^mode_data$'),
                -dplyr::matches('^(time|date)uploaded$'),
                -dplyr::matches('^finalresultvisit$')
            ) |>
            convert_fct_cv()
    `
}


export const getVersion = () => {
    
    const path = join(withRCBMSFolder().path, 'utils', 'version.json')

    let v = { path, version: '' }
    
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
        const { version } = fs.readJSONSync(path)
        v = { ...v, version }
    }

    return v

}