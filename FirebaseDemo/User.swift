//
//  User.swift
//  FirebaseDemo
//
//  Created by Quang Minh Trinh on 8/11/16.
//  Copyright © 2016 Quang Minh Trinh. All rights reserved.
//

import Foundation

class User {
    var id: String = ""
    var email: String = ""
    init() {
        id = ""
        email = ""
    }
    init(id: String, email: String) {
        self.id = id
        self.email = email
    }
}