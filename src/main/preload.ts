const { contextBridge, ipcRenderer } = require("electron");
const { createReadStream } = require('fs')
const { join } = require('path')



contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: {
    ...ipcRenderer,
    on: ipcRenderer.on.bind(ipcRenderer),
    removeListener: ipcRenderer.removeListener.bind(ipcRenderer)
  }
});

