//
//  Router.swift
//  DemoServer
//
//  Created by Kevin McKee on 1/13/17.
//
//

import PerfectHTTP
import CryptoSwift

struct Router {

    static let salt = "T3$tS@l+" // Salt to use for the MD5 Hash
    static let jsonContentType = "application/json"
    static let cookieName: String = "auth_cookie"
    static let securityPolicyHeader = "Content-Security-Policy: default-src: 'self'; script-src: 'self' www.test.com"

    static func routes() -> Routes {

        var routes = Routes()
        routes.add(method: .get, uri: "", handler: Router.indexHandler)
        routes.add(method: .get, uri: "/status", handler: Router.statusHandler)
        routes.add(method: .post, uri: "/login", handler: Router.loginHandler)
        routes.add(method: .get, uri: "/secure", handler: Router.secureHandler)
        routes.add(method: .get, uri: "/ajax", handler: Router.ajaxHandler)
        routes.add(method: .post, uri: "/data", handler: Router.dataHandler)
        return routes
    }

    // Home Route
    static func indexHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.appendBody(string: "<p>Demo Server</p>")
        response.completed()
    }

    // Status Route
    static func statusHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.addHeader(.contentType, value: jsonContentType)
        response.appendBody(string: "{ \"echo\": \"\(request.remoteAddress.host)\" }")
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
        writeCookie(username, request, response)
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

    // Sample AJAX Route
    static func ajaxHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.addHeader(.contentType, value: jsonContentType)
        response.addHeader(.contentSecurityPolicy, value: securityPolicyHeader)
        response.appendBody(string: "{ \"echo\": \"\(request.remoteAddress.host)\" }")
        response.completed()
    }

    // Sample Data Route
    static func dataHandler(request: HTTPRequest, _ response: HTTPResponse) {

        guard let id = request.param(name: "id"), let data = Database.data[id],
            let username = username(request) else {
                print("🔥 NOT FOUND")
            response.status = HTTPResponseStatus.notFound
            response.completed()
            return
        }

        response.status = (data.owner == username) ? HTTPResponseStatus.ok : HTTPResponseStatus.unauthorized

        print("\(response.status)")
        response.completed()
    }

    // MARK: Authentication and Cookie helper methods

    // Helper method to determine if cookie is valid
    static func isAuthenticated(_ request: HTTPRequest) -> Bool {

        for (key, value) in request.cookies {
            if key == cookieName, isValidAuthCookie(value, request) {
                print("Found Valid Cookie for user: \(value)")
                return true
            }
        }
        return false
    }

    static func writeCookie(_ username: String, _ request: HTTPRequest, _ response: HTTPResponse) {
        print("Adding cookie")

        guard let agent = request.header(HTTPRequestHeader.Name.userAgent) else {
            return
        }

        let ip = request.remoteAddress.host

        let hash = "\(username)\(salt)\(agent)\(ip)".md5()
        let value = "\(username)|\(hash)"

        print("Writing cookie : \(value)")

        let cookie = HTTPCookie(name: cookieName, value: value)
        response.addCookie(cookie)

    }


    static func isValidAuthCookie(_ value: String, _ request: HTTPRequest) -> Bool {

        guard let agent = request.header(HTTPRequestHeader.Name.userAgent) else {
            return false
        }

        let ip = request.remoteAddress.host

        if let username = cookieComponents(value).username, let _ = Database.users[username], let hash = cookieComponents(value).hash {

            let checksum = "\(username)\(salt)\(agent)\(ip)".md5()

            return hash == checksum

        }

        return false
    }

    static func username(_ request: HTTPRequest) -> String? {

        for (key, value) in request.cookies {
            if key == cookieName, isValidAuthCookie(value, request) {
                return cookieComponents(value).username
            }
        }

        return nil
    }

    static func cookieComponents(_ cookie: String) -> (username: String?, hash: String?) {

        print("Checking: \(cookie)")

        let parts = cookie.components(separatedBy: "|")

        return (parts[0], parts[1])
    }
}

