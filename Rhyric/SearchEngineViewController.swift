//
//  ViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/01/27.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit

class SearchEngineViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var searchView:UITextField!
    @IBOutlet var segmentedPattern:UISegmentedControl!
    @IBOutlet var segmentedLength:UISegmentedControl!
    
    @IBOutlet weak var searchButton:UIButton!
    
    var searchInfo: Array<Any> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.tabmanOrange.cgColor
        
        view.backgroundColor = UIColor.backGroundBlack
        self.searchView.delegate = self
        
        searchView.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        searchView.attributedPlaceholder = NSAttributedString(string: "検索ワード（ひらがなorカタカナで入力）", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchView.resignFirstResponder()
    }

    @IBAction func search() {
        let searchWord = searchView.text!
        let patternIndex = segmentedPattern.selectedSegmentIndex
        let lengthIndex = segmentedLength.selectedSegmentIndex
        searchInfo = []
        searchInfo.append(searchWord)
        searchInfo.append(patternIndex)
        searchInfo.append(lengthIndex)
        self.performSegue(withIdentifier: "toResult", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult" {
            let resultViewcontroller = segue.destination as! SearchResultViewController
            resultViewcontroller.passedList = searchInfo
        }
    }
    
}



