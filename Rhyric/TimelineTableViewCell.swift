//
//  TimelineTableViewCell.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

protocol TimelineTableViewCellDelegate{

    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapSaveButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapImageButton(tableViewCell: UITableViewCell, button: UIButton)
}


class TimelineTableViewCell: UITableViewCell {

    var delegate: TimelineTableViewCellDelegate?
    
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var userImageButton: UIButton!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    @IBOutlet var postTextView: UILabel!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var saveCountLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var toCommentsButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        //userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        //userImageView.clipsToBounds = true
        userImageButton.imageView?.layer.cornerRadius = userImageButton.bounds.width / 2.0
        userImageButton.imageView?.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func like(button: UIButton){
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func save(button: UIButton){
        self.delegate?.didTapSaveButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    @IBAction func showUserInfo(button: UIButton){
        self.delegate?.didTapImageButton(tableViewCell: self, button: button)
    }
}
