//
//  Database.swift
//  DemoServer
//
//  Created by Kevin McKee on 1/13/17.
//
//

import Foundation

struct User {
    var email: String
    var password: String

    init(_ email: String, _ password: String) {
        self.email = email
        self.password = password
    }
}

struct Database {

    static var users: [String: User] = [
        "test1": User("test1", "start123"),
        "test2": User("test2", "start123")
    ]

}
