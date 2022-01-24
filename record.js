const { windowManager } = require("node-window-manager");


function getWindow(title){
    let windows = windowManager.getWindows()
    for (var i = 0; i < windows.length; i++){
        if (windows[i].getTitle().toLowerCase() == title.toLowerCase()){
            return windows[i]
        }
    }
    return null
}

console.log(windowManager.getMonitors().getBounds())


var bounds = getWindow('Calculator').getBounds()
console.log(bounds)
getWindow('Calculator').setBounds({ x: 1360, y: 400, width: 338, height: 541 })
var bounds = getWindow('Calculator').getBounds()
console.log(bounds)
getWindow('Calculator').bringToTop()


window