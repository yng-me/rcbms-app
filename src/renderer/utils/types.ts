
export interface DataDictionary {
    record: string
    variable: string
    item: string
    label: string
}

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

export interface RConfig {
    run_after_edit: boolean
    use_rdata: boolean
    include_justifiction: boolean
    clear: boolean
    convert_to_rdata: boolean
    use_pilot_data: boolean
    use_raw_data_from_tablet: boolean
    save_by_area?: boolean
    append_new_record?: boolean
}

export interface UpdateConfig {
    key: keyof RConfig
    val: boolean
}

export interface SavedTables {
    title: string
    tableOptions: TableOptions
    script?: string
    dataTable: any
}