//
//  User.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var objectId: String
    var userName: String
    var displayName: String?
    var introduction: String?
    
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }

}
