//
//  CommentTableViewCell.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate{
    
    func didTapCommentLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var postTextView: UILabel!
    
    var delegate: CommentTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        //userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        //userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func like(button: UIButton){
        self.delegate?.didTapCommentLikeButton(tableViewCell: self, button: button)
    }
    
}
