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
  