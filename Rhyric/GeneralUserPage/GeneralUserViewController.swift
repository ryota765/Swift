//
//  GeneralUserViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/10.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class GeneralUserViewController: UIViewController {
    
    //遷移前のViewControllerから渡される変数
    var userId: String!
    var userInfo: NCMBObject?
    
    
    var isFollowed: Bool = false
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userDisplayNameLabel: UILabel!
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var postCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    override func viewDidLoad() {
        self.userId = UserDefaults.standard.string(forKey: "user")
        //getUserInfo()
        //Viewが下にずれるのを防ぐ
        //self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.backGroundBlack
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let query = NCMBUser.query()
        query?.getObjectInBackground(withId: self.userId!, block: { (user, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async{
                    if let displayName = user?.object(forKey: "displayName") as? String{
                        self.userDisplayNameLabel.text = displayName
                    }else{
                        self.userDisplayNameLabel.text = user?.object(forKey: "userName") as? String
                    }
                    self.userIntroductionTextView.text = user?.object(forKey: "introduction") as? String
                    self.navigationItem.title = user?.object(forKey: "userName") as? String
                    self.userInfo = user
                    /*let file = NCMBFile.file(withName: self.userId, data: nil) as! NCMBFile
                    file.getDataInBackground { (data, error) in
                        if error != nil{
                            //画像を選択していないユーザーだとエラーが出てしまう
                            //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            if data != nil{
                                let image = UIImage(data: data!)
                                self.userImageView.image = image
                            }
                        }
                    }*/
                    let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + self.userId
                    self.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"))
                    self.loadPosts()
                    self.loadFollowingInfo()
                    self.loadCommentsInfo()
                    self.loadFollow()
                }
            }
        })
    }
    
    
    
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
        
        let blockAction = UIAlertAction(title: "ブロック", style: .default) { (action) in
            let alert = UIAlertController(title: "ユーザーのブロック", message: "ブロックしますか？ブロックしたアカウントの投稿やプロフィールにアクセスできなくなります", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if let currentUser = NCMBUser.current(){
                    let query = NCMBQuery(className: "Block")
                    query?.whereKey("user", equalTo: currentUser)
                    query?.whereKey("blocked", equalTo: self.userInfo)
                    query?.findObjectsInBackground({ (result, error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            if result?.count == 0{
                                let object = NCMBObject(className: "Block")
                                object?.setObject(currentUser, forKey: "user")
                                object?.setObject(self.userInfo, forKey: "blocked")
                                object?.saveInBackground({ (error) in
                                    if error != nil{
                                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                                    }else{
                                        let alertController = UIAlertController(title: "ブロック完了", message: "このユーザーをブロックしました", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            self.navigationController?.popViewController(animated: true)
                                        })
                                        alertController.addAction(action)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                })
                            }else{
                                let alertController = UIAlertController(title: "ブロック済み", message: "すでにブロックされています", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                alertController.addAction(action)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    })
                }else {
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func loadPosts(){
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: self.userInfo)
        query?.countObjectsInBackground({ (count, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    self.postCountLabel.text = String(count)
                }
            }
        })
    }
    
    func loadFollowingInfo(){
        //フォロー中
        let followingQuery = NCMBQuery(className: "follow")
        followingQuery?.includeKey("user")
        followingQuery?.whereKey("user", equalTo: self.userInfo)
        followingQuery?.countObjectsInBackground({ (count, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    self.followingCountLabel.text = String(count)
                }
            }
        })
        
        //フォロワー
        let followerQuery = NCMBQuery(className: "follow")
        followerQuery?.includeKey("following")
        followerQuery?.whereKey("following", equalTo: self.userInfo)
        followerQuery?.countObjectsInBackground({ (count, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    self.followerCountLabel.text = String(count)
                }
            }
        })
    }
    func loadCommentsInfo(){
        //コメントの数
        let followingQuery = NCMBQuery(className: "Comment")
        followingQuery?.includeKey("user")
        followingQuery?.whereKey("user", equalTo: self.userInfo)
        followingQuery?.countObjectsInBackground({ (count, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    self.commentCountLabel.text = String(count)
                }
            }
        })
    }
    
    
    @IBAction func follow(){
        if isFollowed == false{
            let object = NCMBObject(className: "follow")
            if let currentUser = NCMBUser.current(){
                object?.setObject(currentUser, forKey: "user")
                object?.setObject(userInfo, forKey: "following")
                object?.saveInBackground({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadFollow()
                    }
                })
            }else {
                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                let ud = UserDefaults.standard
                ud.set(false, forKey: "isLogin")
                ud.synchronize()
            }
        }else{
            let query = NCMBQuery(className: "follow")
            query?.includeKey("user")
            query?.includeKey("following")
            query?.whereKey("user", equalTo: NCMBUser.current())
            query?.whereKey("following", equalTo: self.userInfo)
            query?.findObjectsInBackground({ (result, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    for object in result as! [NCMBObject]{
                        object.deleteEventually({ (error) in
                            if error != nil{
                                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            }else{
                                self.loadFollow()
                            }
                        })
                    }
                }
            })
        }
    }
    
    func loadFollow(){
        //クエリで現在ユーザーのfollowingに画面のユーザーが入っているか確認
        let query = NCMBQuery(className: "follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.whereKey("following", equalTo: self.userInfo)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                if result?.count == 0{
                    self.isFollowed = false
                    //buttonの色を変える処理
                    self.followButton.setTitleColor(UIColor.white, for: .normal)
                    self.followButton.backgroundColor = UIColor.tabmanOrange
                    self.followButton.setTitle("フォロー", for: .normal)
                }else{
                    self.isFollowed = true
                    //buttonの色を変える処理
                    self.followButton.setTitleColor(UIColor.backGroundBlack, for: .normal)
                    self.followButton.backgroundColor = UIColor.lightGray
                    self.followButton.setTitle("フォロー中", for: .normal)
                }
                
            }
        })
    }

}
