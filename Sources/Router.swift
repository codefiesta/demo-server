//
//  Router.swift
//  DemoServer
//
//  Created by Kevin McKee on 1/13/17.
//
//

import PerfectHTTP

struct Router {

    static let cookieName: String = "auth_cookie"

    static func routes() -> Routes {

        var routes = Routes()
        routes.add(method: .get, uri: "", handler: Router.indexHandler)
        routes.add(method: .post, uri: "/login", handler: Router.loginHandler)
        routes.add(method: .get, uri: "/secure", handler: Router.secureHandler)
        return routes
    }

    // Home Route
    static func indexHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.appendBody(string: "<p>Demo Server</p>")
        response.completed()
    }

    // Login Route
    static func loginHandler(request: HTTPRequest, _ response: HTTPResponse) {

        print("Login called")
        defer {
            response.completed()
        }

        guard let username = request.param(name: "username"),
            let password = request.param(name: "password"),
            let user = Database.users[username],
            password == user.password else {
            response.status = HTTPResponseStatus.unauthorized
            return
        }

        response.appendBody(string: "<p>User logged in with \(username) : \(password)")
        print("Adding cookie")
        let cookie = HTTPCookie(name: cookieName, value: username)
        response.addCookie(cookie)

        print("\(username) : \(password)")
    }

    // Sample Secure Route
    static func secureHandler(request: HTTPRequest, _ response: HTTPResponse) {
        print("Secure method called")

        let authenticated = isAuthenticated(request)

        response.status = authenticated ? HTTPResponseStatus.ok : HTTPResponseStatus.unauthorized
        print("Authenticated? \(authenticated)")
        response.completed()
    }

    // Helper method to determine if cookie is valid
    static func isAuthenticated(_ request: HTTPRequest) -> Bool {

        for (key, value) in request.cookies {
            if key == cookieName, let _ = Database.users[value] {
                print("Found Valid Cookie for user: \(value)")
                return true
            }
        }
        return false
    }
}

