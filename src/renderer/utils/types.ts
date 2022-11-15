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