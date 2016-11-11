//
//  Work.swift
//  FirebaseDemo
//
//  Created by Quang Minh Trinh on 8/11/16.
//  Copyright © 2016 Quang Minh Trinh. All rights reserved.
//

import Foundation
import Firebase
class Work {
    var workName: String?
    var userId: String?
    var id: String?
    init() {
        workName = ""
        userId = ""
        id = ""
    }
    
    init (workName: String, userId: String, id: String) {
        self.workName = workName
        self.userId = userId
        self.id = id
    }
    init (snapshot: FIRDataSnapshot ) {
        let data = snapshot.value as! [String : AnyObject]
        self.workName = data["name"] as? String
        self.userId = data["creator"] as? String
        self.id = data["id"] as? String
    }
    init(data: [String: AnyObject]) {
        self.workName = data["name"] as? String
        self.userId = data["creator"] as? String
        self.id = data["id"] as? String
    }
}