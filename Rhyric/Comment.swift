//
//  Comment.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/10.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var objectId: String
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var likeCount: Int = 0
    
    init(objectId: String, postId: String, user: User, text: String, createDate: Date){
        self.objectId = objectId
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
