//
//  AddWordViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/07.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class AddWordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var wordField:UITextField!
    @IBOutlet var rhymeField:UITextField!
    
    @IBOutlet weak var addButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.tabmanOrange.cgColor

        view.backgroundColor = UIColor.backGroundBlack
        // キーボード下げるため
        wordField.delegate = self
        rhymeField.delegate = self
        
        wordField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        wordField.attributedPlaceholder = NSAttributedString(string: "追加ワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        rhymeField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        rhymeField.attributedPlaceholder = NSAttributedString(string: "読み（ひらがなorカタカナ）", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wordField.resignFirstResponder()
        rhymeField.resignFirstResponder()
    }
    
    @IBAction func addWord(){
        let addWord = wordField.text!
        let addRead = rhymeField.text!
        let addRhyme = Rhyme.toVowel(word: addRead)
        if addWord.characters.count != 0 && addRead.characters.count != 0{
            let query = NCMBQuery(className: "Word")
            //var wordList: [String] = []
            query?.whereKey("word", equalTo: addWord)
            query?.findObjectsInBackground({ (result, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }else{
                    if result?.count != 0{
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Uniqueエラー", message: "すでに登録済みです", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alertMessage = "\(addWord)(\(addRead))を追加しますか？"
                        let alert = UIAlertController(title: "ワード追加", message: alertMessage, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            let wordObject = NCMBObject(className: "Word")
                            wordObject?.setObject(addWord, forKey: "word")
                            wordObject?.setObject(addRhyme, forKey: "rhyme")
                            wordObject?.setObject(addRead, forKey: "read")
                            wordObject?.saveInBackground({ (error) in
                                if error != nil {
                                    //アップロード失敗
                                    SVProgressHUD.dismiss()
                                    let alert = UIAlertController(title: "追加エラー", message: error!.localizedDescription, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }else {
                                    //アップロード成功
                                    SVProgressHUD.dismiss()
                                    let alertController = UIAlertController(title: "追加完了", message: "ワードの追加が完了しました", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    alertController.addAction(action)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            })
                        })
                        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(okAction)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }else{
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "入力エラー", message: "単語を入力してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /*@IBAction func addWord(){
        let query = NCMBQuery(className: "Word")
        var wordList: [String] = []
        let addWord = wordField.text!
        let addRead = rhymeField.text!
        let addRhyme = Rhyme.toVowel(word: addRead )
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }else{
                for wordObject in result as! [NCMBObject]{
                    let word = wordObject.object(forKey: "word") as! String
                    wordList.append(word)
                }
                print(wordList)
                if addWord.characters.count != 0 && addRead.characters.count != 0{
                    if wordList.contains(addWord) == false {
                        let wordObject = NCMBObject(className: "Word")
                        wordObject?.setObject(addWord, forKey: "word")
                        wordObject?.setObject(addRhyme, forKey: "rhyme")
                        wordObject?.setObject(addRead, forKey: "read")
                        wordObject?.saveInBackground({ (error) in
                            if error != nil {
                                //アップロード失敗
                                SVProgressHUD.dismiss()
                                let alert = UIAlertController(title: "追加エラー", message: error!.localizedDescription, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                                
                            }else {
                                //アップロード成功
                                SVProgressHUD.dismiss()
                                let alertController = UIAlertController(title: "追加完了", message: "ワードの追加が完了しました", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }else{
                        SVProgressHUD.dismiss()
                        let alert = UIAlertController(title: "Uniqueエラー", message: "すでに登録済みです", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "入力エラー", message: "単語を入力してください", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        
        })
    }*/

}
