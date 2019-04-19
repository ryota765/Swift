//
//  PostViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import UITextView_Placeholder
import SVProgressHUD

class PostViewController: UIViewController, UINavigationControllerDelegate,UITextViewDelegate {
    
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postButton: UIBarButtonItem!
    @IBOutlet var userImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundBlack

        let user = NCMBUser.current()
        let file = NCMBFile.file(withName: user!.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil{
                print(error)
            }else{
                if data != nil{
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        postTextView.delegate = self as! UITextViewDelegate
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func postRhyric(){
        SVProgressHUD.show()
        
        if self.postTextView.text.characters.count == 0 {
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "入力エラー", message: "投稿を入力してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            let postObject = NCMBObject(className: "Post")
            postObject?.setObject(self.postTextView.text!, forKey: "text")
            postObject?.setObject(NCMBUser.current(), forKey: "user")
            postObject?.saveInBackground({ (error) in
                if error != nil {
                    //アップロード失敗
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "投稿エラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in})
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }else {
                    //アップロード成功
                    SVProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "投稿完了", message: "投稿が完了しました", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    
    

    

}
