//
//  SearchTableViewCell.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/11.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton)
}


class SearchTableViewCell: UITableViewCell {
    
    var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.tabmanOrange.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func follow(button: UIButton){
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }
    
}
