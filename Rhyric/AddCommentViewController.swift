//
//  AddCommentViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/27.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import UITextView_Placeholder
import SVProgressHUD

class AddCommentViewController: UIViewController, UITextViewDelegate {
    
    var postId: String!
    
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
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                if data != nil{
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        postTextView.delegate = self as UITextViewDelegate
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTextView.resignFirstResponder()
    }
    
    @IBAction func addComment(){
        SVProgressHUD.show()
        
        if self.postTextView.text.characters.count == 0 {
            print("入力されていません")
        }else{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: postId, block: { (post, error) in
                post?.add(NCMBUser.current()?.objectId, forKey: "commentUser")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        let commentObject = NCMBObject(className: "Comment")
                        commentObject?.setObject(self.postId, forKey: "postId")
                        commentObject?.setObject(NCMBUser.current(), forKey: "user")
                        commentObject?.setObject(self.postTextView.text!, forKey: "text")
                        commentObject?.saveInBackground({ (error) in
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
                                let alertController = UIAlertController(title: "コメント完了", message: "コメントが完了しました", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        })
                    }
                })
            })
            
        }
    }
    

    

}
