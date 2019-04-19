//
//  Post.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var objectId: String
    var user: User
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var isSaved: Bool?
    var comments: [Comment]?
    var likeCount: Int = 0
    var saveCount: Int = 0
    var commentCount: Int = 0
    
    init(objectId: String, user: User, text: String, createDate: Date) {
        self.objectId = objectId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
