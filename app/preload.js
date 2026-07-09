const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  listAlbums:   ()            => ipcRenderer.invoke('list-albums'),
  loadAlbum:    (filename)    => ipcRenderer.invoke('load-album', filename),
  createAlbum:  (name)        => ipcRenderer.invoke('create-album', name),
  deleteAlbum:  (filename)    => ipcRenderer.invoke('delete-album', filename),
  renameAlbum:  (old, name)   => ipcRenderer.invoke('rename-album', old, name),
  saveData:     (data)        => ipcRenderer.invoke('save-data', data),
  scanPaths:    (paths)       => ipcRenderer.invoke('scan-paths', paths),
  fileExists:   (filePath)    => ipcRenderer.invoke('file-exists', filePath),
  openFolderDialog: ()        => ipcRenderer.invoke('open-folder-dialog'),
  openMusicDialog:  ()        => ipcRenderer.invoke('open-music-dialog'),
  openPhotosDialog: ()        => ipcRenderer.invoke('open-photos-dialog'),
  getThumb:         (src)     => ipcRenderer.invoke('get-thumb', src),
  toggleFullscreen: ()        => ipcRenderer.invoke('toggle-fullscreen'),
  setFullscreen:    (val)     => ipcRenderer.invoke('set-fullscreen', val),
});
