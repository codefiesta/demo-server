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

struct Data {

    var id: String
    var owner: String

    init(_ id: String, _ owner: String) {
        self.id = id
        self.owner = owner
    }
}

struct Database {

    static var users: [String: User] = [
        "test1": User("test1", "start123"),
        "test2": User("test2", "start123"),
        "test3": User("test3", "start123"),
        "test4": User("test4", "start123")
    ]

    static var data: [String: Data] = [
        "1": Data("1", "test1"),
        "2": Data("2", "test2"),
        "3": Data("3", "test3"),
        "4": Data("4", "test4")
    ]



}
