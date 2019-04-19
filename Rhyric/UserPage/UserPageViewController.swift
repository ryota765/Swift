//
//  UserPageViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/03.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class UserPageViewController: UIViewController{
    
    //var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userDisplayNameLabel: UILabel!
    @IBOutlet var userIntroductionTextView: UITextView!
    
    //@IBOutlet var postTableView: UITableView!
    @IBOutlet var postCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var commentCountLabel: UILabel!

    override func viewDidLoad() {
        
        //postTableView.dataSource = self
        //postTableView.tableFooterView = UIView()
        view.backgroundColor = UIColor.backGroundBlack
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        //postTableView.estimatedRowHeight = 80
        //postTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadPosts()
        loadFollowingInfo()
        loadCommentsInfo()
        
        if let user = NCMBUser.current(){
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            
            /*let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil{
                    print(error)
                }else{
                    if data != nil{
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }*/
            let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + user.objectId
            self.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"))
        }else {
            //NCMBUser.current()がNil
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    

    
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください", preferredStyle: .actionSheet)
        
        let cancelBlockAction = UIAlertAction(title: "ブロックの解除", style: .default) { (action) in
            self.performSegue(withIdentifier: "toBlockedUser", sender: nil)
        }
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    print(error)
                }else {
                    //ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合サイドこのアカウントをご利用いただくことができません", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                if let user = NCMBUser.current(){
                    user.setObject(false, forKey: "active")
                    user.saveInBackground({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                            UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            
                            let ud = UserDefaults.standard
                            ud.set(false, forKey: "isLogin")
                            ud.synchronize()
                        }
                    })
                }else{
                    //userがnilだった場合にログイン画面に移動
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
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
        
        alertController.addAction(cancelBlockAction)
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadPosts(){
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
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
        followingQuery?.whereKey("user", equalTo: NCMBUser.current())
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
        followerQuery?.whereKey("following", equalTo: NCMBUser.current())
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
        followingQuery?.whereKey("user", equalTo: NCMBUser.current())
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

}


