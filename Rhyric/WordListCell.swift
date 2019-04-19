//
//  WordListCell.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/06.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

protocol WordListCellDelegate {
    func didTapCopyButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton)
}

class WordListCell: UITableViewCell {
    
    var delegate: WordListCellDelegate?
    
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var goodButton: UIButton!
    @IBOutlet var goodLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = UIColor.tabmanOrange.cgColor
        //goodLabel.layer.borderColor = UIColor.backGroundBlack.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func copy(button: UIButton) {
        self.delegate?.didTapCopyButton(tableViewCell: self, button: button)
    }
    
    @IBAction func good(button: UIButton){
        self.delegate?.didTapGoodButton(tableViewCell: self, button: button)
    }

    
}
