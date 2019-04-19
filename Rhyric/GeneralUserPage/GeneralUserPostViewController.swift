//
//  GeneralUserPostViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/10.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SwiftDate
import SVProgressHUD
import Kingfisher

class GeneralUserPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {

    //前のViewから渡される変数
    var userId: String!
    
    var userInfo: NCMBObject?
    
    var selectedPost: Post?
    var posts = [Post]()
    
    
    @IBOutlet var userPostTableView: UITableView!
    
    override func viewDidLoad() {
        userPostTableView.dataSource = self
        userPostTableView.delegate = self
        
        //view.backgroundColor = UIColor.backGroundBlack
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        userPostTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        userPostTableView.tableFooterView = UIView()
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            //auto layoutで高さ調整
            userPostTableView.estimatedRowHeight = 161
            return UITableView.automaticDimension
        }
        
        self.userId = UserDefaults.standard.string(forKey: "user")
        //print(self.userId)
        let query = NCMBQuery(className: "user")
        query?.getObjectInBackground(withId: self.userId!, block: { (user, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async{
                    self.userInfo = user
                }
                //print(self.userInfo)
                self.setRefreshControl()
                
                self.loadTimeline()
            }
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        self.userId = UserDefaults.standard.string(forKey: "user")
        //print(self.userId)
        let query = NCMBQuery(className: "user")
        query?.getObjectInBackground(withId: self.userId!, block: { (user, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.async{
                    self.userInfo = user
                }
                //print(self.userInfo)
                self.setRefreshControl()
                
                self.loadTimeline()
            }
        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
            commentViewController.postName = selectedPost?.user.displayName
            commentViewController.userName = selectedPost?.user.userName
            commentViewController.postText = selectedPost?.text
            commentViewController.postUserId = selectedPost?.user.objectId
            commentViewController.likeCount = selectedPost?.likeCount
            commentViewController.commentCount = selectedPost?.commentCount
            commentViewController.saveCount = selectedPost?.saveCount
            commentViewController.isLiked = selectedPost?.isLiked
            commentViewController.isSaved = selectedPost?.isSaved
            commentViewController.createDate = selectedPost?.createDate
        }
        if segue.identifier == "toUserPage"{
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.set(selectedPost?.user.objectId, forKey: "user")
            UserDefaults.standard.synchronize()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        
        cell.contentView.backgroundColor = UIColor.backGroundBlack
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.selectedGray
        cell.selectedBackgroundView =  selectedView
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        if user.displayName != nil{
            cell.userNameLabel.text = user.displayName
        }else{
            cell.userNameLabel.text = user.userName
        }
        
        /*let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil{
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                cell.userImageButton.setImage(UIImage(named: "placeholder.jpg"), for: .normal)
            }else{
                if data != nil{
                    let image = UIImage(data: data!)
                    cell.userImageButton.setImage(image, for: .normal)
                    //cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
                    //cell.userImageView.layer.masksToBounds = true
                }
            }
        }*/
        
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + posts[indexPath.row].user.objectId
        if CacheType.none != ImageCache.default.imageCachedType(forKey: userImageUrl) {
            //print("ある\(userImageUrl)")
            let cache = ImageCache.default
            cache.retrieveImage(forKey: userImageUrl) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        cell.userImageButton.setImage(value.image, for: .normal)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }else{
            //print("ない\(userImageUrl)")
            cell.userImageButton.imageView?.kf.setImage(with: URL(string: userImageUrl), completionHandler: { (image, error, _, _) in
                if error != nil {
                    //print(error?.localizedDescription)
                } else {
                    cell.userImageButton.setImage(image, for: .normal)
                }
            })
        }
        
        
        cell.postTextView.text = posts[indexPath.row].text
        
        if posts[indexPath.row].isLiked == true{
            cell.likeButton.setImage(UIImage(named: "liked"), for: .normal)
        }else{
            cell.likeButton.setImage(UIImage(named: "like2"), for: .normal)
        }
        
        if posts[indexPath.row].isSaved == true{
            cell.saveButton.setImage(UIImage(named: "saved"), for: .normal)
        }else{
            cell.saveButton.setImage(UIImage(named: "save2"), for: .normal)
        }
        
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        cell.saveCountLabel.text = "\(posts[indexPath.row].saveCount)件"
        cell.commentCountLabel.text = "\(posts[indexPath.row].commentCount)件"
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        let now = posts[indexPath.row].createDate
        cell.timestampLabel.text = f.string(from: now)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        self.performSegue(withIdentifier: "toComments", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        guard let currentUser = NCMBUser.current() else{
            //ログイン画面に戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current()?.objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadTimeline()
                    }
                })
            })
        }else{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.removeObjects(in: [currentUser.objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadTimeline()
                        }
                    })
                }
            })
            
        }
    }
    
    func didTapSaveButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        guard let currentUser = NCMBUser.current() else{
            //ログイン画面に戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        if posts[tableViewCell.tag].isSaved == false || posts[tableViewCell.tag].isSaved == nil{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current()?.objectId, forKey: "saveUser")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadTimeline()
                    }
                })
            })
        }else{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.removeObjects(in: [currentUser.objectId], forKey: "saveUser")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadTimeline()
                        }
                    })
                }
            })
            
        }
    }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            SVProgressHUD.show()
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.deleteInBackground({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadTimeline()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId{
            alertController.addAction(deleteAction)
        }else{
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        //let screenSize = UIScreen.main.bounds
        //alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        selectedPost = posts[tableViewCell.tag]
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    func didTapImageButton(tableViewCell: UITableViewCell, button: UIButton) {
        selectedPost = posts[tableViewCell.tag]
        if selectedPost?.user.objectId == NCMBUser.current()?.objectId{
            self.performSegue(withIdentifier: "toMyPage", sender: nil)
        }else{
            self.performSegue(withIdentifier: "toUserPage", sender: nil)
        }
    }
    
    func loadTimeline(){
        
        guard let currentUser = NCMBUser.current() else{
            //ログイン画面に戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        let query = NCMBQuery(className: "Post")
        
        query?.includeKey("user")
        query?.order(byDescending: "createDate")
        //print(self.userInfo)
        query?.whereKey("user", equalTo: self.userInfo)
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                for postObject in result as! [NCMBObject]{
                    
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    if user.object(forKey: "active") as? Bool != false{
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        let text = postObject.object(forKey: "text") as! String
                        
                        let post = Post(objectId: postObject.objectId, user: userModel, text: text, createDate: postObject.createDate)
                        
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(currentUser.objectId) == true{
                            post.isLiked = true
                        }else{
                            post.isLiked = false
                        }
                        
                        if let likes = likeUsers{
                            post.likeCount = likes.count
                        }
                        
                        let saveUsers = postObject.object(forKey: "saveUser") as? [String]
                        if saveUsers?.contains(currentUser.objectId) == true{
                            post.isSaved = true
                        }else{
                            post.isSaved = false
                        }
                        
                        if let saves = saveUsers{
                            post.saveCount = saves.count
                        }
                        
                        let commentUsers = postObject.object(forKey: "commentUser") as? [String]
                        if let comments = commentUsers{
                            post.commentCount = comments.count
                        }
                        
                        self.posts.append(post)
                    }
                }
                self.userPostTableView.reloadData()
                
            }
        })
    }
    
    func setRefreshControl() {
        DispatchQueue.main.async{
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(self.reloadTimeline(refreshControl:)), for: .valueChanged)
            self.userPostTableView.addSubview(refreshControl)
        }
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl){
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    
}
