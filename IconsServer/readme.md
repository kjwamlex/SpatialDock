# VisionDock icon server
This is the VisionDock icon server. It's main purpose (for now) is to send app icons to the VisionDock client without us needing to push a new update to the app every time we want to add new app icons. It's functionality may be expanded in the future.<br/>
## build instructions
- open up a terminal & cd to IconsServer
- make sure nodejs is installed, if not run `brew install node` (brew found @ https://brew.sh)
- run `npm i` and `npm i typescript --save-dev`
- run `npm run dev`
thats it!
- in-app function (getIcon) contains an `endpoint` parameter which contains a URL for the server. currently, this is set to http://localhost:3000, but when we get a server setup, change `localhost` to the server IP
## how it works
when the VisionDock client launches, it sends a single request to the server (`endpoint` parameter) for each app that the user has listed. Once the server gets this request, it looks in the `./Icons` directory for an icon with the app name.<br/>
If an icon is found, it sends back 2 things:
- `found`, a boolean which tells the client if the image was found
- `image`, a base64 encoded string of the image. this is only included if the icon was found.<br/>
If no icon was found, it will only send the `found` bool with a value of `false`.
The client then decodes this response, and if there is an image the client will create a SwiftUI `Image` using the base64. if there was no image found, the client will use a default placeholder image. The user can then change the image to a custom one if they'd like.
## cache
In an effort to preserve efficiency (and money!), the VisionDock client will cache the image once it comes back from the server. This cache is kept for 30 days, at which point the client will refresh the image from the server, and cache that response.
## adding new icons
To add a new icon to the server, place the icon in the `Icons` directory of the server. Icons are 200x200px .png files. If necessary, **rename the image to the app name!**<br/>
Just like that, you have registered the icon with the server. *You **do not** have to restart the server for these changes to go into effect.*
