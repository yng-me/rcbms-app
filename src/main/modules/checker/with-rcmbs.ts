import { dialog, app } from 'electron'
import fs from 'fs-extra'
import { join } from 'path'

const yaml = require('js-yaml');

import { withRCBMSFolder } from '../../utils/helpers'


interface CHECKER {
    error: boolean
    status: string
    loading?: boolean
}

export const rcbmsCheck = () : CHECKER => {
    if(!withRCBMSFolder().isAvailable && process.platform != 'darwin') {

        try {
            fs.copySync(join(app.getAppPath(), 'static', 'rcbms'), withRCBMSFolder().path, { recursive: true });
            return {
                error: false,
                status: 'Copying successful',
                loading: false
            }
           
        } catch {
            dialog.showErrorBox('Loading Refererence File', 'There was a problem loading the reference files. Please restart the RCBMS App.')
            return {
                error: true,
                status: 'There was a problem loading the reference files. Please restart the RCBMS App.',
                loading: false
            }
        }
    
    } else {
        return {
            error: false,
            status: '',
            loading: false
        }
    }
}
