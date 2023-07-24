import express from "express"
import {existsSync, readFileSync} from "fs"
import bodyParser from "body-parser"
const app = express()
const port = 3000
app.use(bodyParser.json())
app.post("/image", (req, res) => {
    
    let imageRequest = new ImageRequest((req.body.name as string).toLowerCase())
    console.log("incoming request for " + imageRequest.appName)
    if (existsSync(`./icons/${imageRequest.appName}.png`)) {
        //icon exists! return image
        let returnData = {
            found: true,
            name: imageRequest.appName,
            image: readFileSync(`./icons/${imageRequest.appName}.png`, {encoding: 'base64'}).toString() //image is encoded in base64.
        }
        res.send(returnData)
    } else {
        //if icon not found, tell the app that the icon doesn't exist on this server & the app will use the default icon
        let returnData = {
            found: false,
            name: imageRequest.appName
        }
        res.send(returnData)
    }
    res.end()
})

app.listen(port, () => {
  console.log(`infinitex3i icons server listening on ${port}`)
})

class ImageRequest {
    appName: string
    constructor(appName: string) {
        this.appName = appName
    }
}