//
//  Word.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class Word: NSObject {
    
    var objectId: String
    var word: String
    var isLiked: Bool?
    var likeUsers: [String]?
    var likeCount: Int? = 0
    
    init(objectId: String, word: String, likeUsers: [String]) {
        self.objectId = objectId
        self.word = word
        self.likeUsers = likeUsers
    }
}
