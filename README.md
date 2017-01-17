# DemoServer using PerfectTemplate

# Running Locally

To run this project with Swift Package Manager, type ```swift build``` and then run ``` .build/debug/DemoServer```.

To use the example with Xcode, run the **DemoServer** target. This will launch the Perfect HTTP Server. 

Navigate in your web browser to [http://localhost:8181/](http://localhost:8181/). Currently the only routes defined are the ***/login*** and ***/secure*** routes.

## URL Routing

The routes are built from the Router.swift file

```swift

var routes = Routes()

routes.add(method: .post, uri: "/login", handler: Router.loginHandler)
routes.add(method: .get, uri: "/secure", handler: Router.secureHandler)

// Test this the server status via command line with curl:
// curl http://0.0.0.0:8181/status --header "Content-Type:application/json"
routes.add(method: .get, uri: "/status", handler: Router.statusHandler)

// Create server object.
let server = HTTPServer()

// Listen on port 8181.
server.serverPort = 8181

// Add our routes.
server.addRoutes(routes)

do {
// Launch the HTTP server
try server.start()
} catch PerfectError.networkError(let err, let msg) {
print("Network error thrown: \(err) \(msg)")
}
```
