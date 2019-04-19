//
//  commentViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/09.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate, CommentTableViewCellDelegate {
    
    var users = [NCMBUser]()
    var selectedUser: NCMBUser?
    var selectedUserId: String!
    var postId: String!
    var postText: String!
    var postName: String!
    var userName: String!
    var postUserId: String!
    var commentCount: Int!
    var likeCount: Int!
    var saveCount: Int!
    var isLiked: Bool!
    var isSaved: Bool!
    var createDate: Date!
    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        commentTableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        commentTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        let nib2 = UINib(nibName: "CommentTableViewCell", bundle: Bundle.main)
        commentTableView.register(nib2, forCellReuseIdentifier: "CommentCell")
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            //auto layoutで高さ調整
            commentTableView.estimatedRowHeight = 80
            //commentTableView.rowHeight = UITableView.automaticDimension
            return UITableView.automaticDimension
        }
        
        setRefreshControl()
        
        loadComments()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddComments" {
            let addCommentViewController = segue.destination as! AddCommentViewController
            addCommentViewController.postId = self.postId
        }
        if segue.identifier == "toUserPage"{
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.set(selectedUserId, forKey: "user")
            UserDefaults.standard.synchronize()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return comments.count
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
            cell.delegate = self
            cell.contentView.backgroundColor = UIColor.backGroundBlack
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.selectedGray
            cell.selectedBackgroundView =  selectedView
            
            if postName != nil{
                cell.userNameLabel.text = postName
            }else{
                cell.userNameLabel.text = userName
            }
            
            /*let file = NCMBFile.file(withName: postUserId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil{
                    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    cell.userImageButton.setImage(UIImage(named: "placeholder.jpg"), for: .normal)
                }else{
                    if data != nil{
                        let image = UIImage(data: data!)
                        cell.userImageButton.setImage(image, for: .normal)
                    }
                }
            }*/
            let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + self.postUserId
            
            cell.userImageButton.imageView?.kf.setImage(with: URL(string: userImageUrl), completionHandler: { (image, error, _, _) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    cell.userImageButton.setImage(image, for: .normal)
                }
            })
            
            cell.postTextView.text = postText
            if isLiked == true{
                cell.likeButton.setImage(UIImage(named: "liked"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "like2"), for: .normal)
            }
            if isSaved == true{
                cell.saveButton.setImage(UIImage(named: "saved"), for: .normal)
            }else{
                cell.saveButton.setImage(UIImage(named: "save2"), for: .normal)
            }
            cell.likeCountLabel.text = "\(likeCount ?? 0)件"
            cell.saveCountLabel.text = "\(saveCount ?? 0)件"
            cell.commentCountLabel.text = "\(commentCount ?? 0)件"
            
            let f = DateFormatter()
            f.dateStyle = .short
            f.timeStyle = .short
            cell.timestampLabel.text = f.string(from: createDate)
            cell.toCommentsButton.isHidden = true
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            cell.delegate = self
            cell.tag = indexPath.row
            cell.contentView.backgroundColor = UIColor.backGroundBlack
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.selectedGray
            cell.selectedBackgroundView =  selectedView
            cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
            cell.userImageView.layer.masksToBounds = true
            
            let user = comments[indexPath.row].user
            /*let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil{
                    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    cell.userImageView.image = UIImage(named: "placeholder.jpg")
                }else{
                    if data != nil{
                        let image = UIImage(data: data!)
                        cell.userImageView.image = image
                    }
                }
            }*/
            let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + user.objectId
            //cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"))
            
            if CacheType.none != ImageCache.default.imageCachedType(forKey: userImageUrl) {
                //print("ある\(userImageUrl)")
                let cache = ImageCache.default
                cache.retrieveImage(forKey: userImageUrl) { result in
                    switch result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            cell.userImageView.image = value.image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }else{
                //print("ない\(userImageUrl)")
                cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), completionHandler: { (image, error, _, _) in
                    if error != nil {
                        //print(error?.localizedDescription)
                    } else {
                        cell.userImageView.image = image
                    }
                })
            }
            
            if comments[indexPath.row].isLiked == true{
                cell.likeButton.setImage(UIImage(named: "liked"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "like2"), for: .normal)
            }

            cell.likeCountLabel.text = "\(comments[indexPath.row].likeCount)"
            if user.displayName != nil{
                cell.userNameLabel.text = user.displayName
            }else{
                cell.userNameLabel.text = user.userName
            }
            
            cell.postTextView.text = comments[indexPath.row].text
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
            cell.delegate = self
            cell.tag = indexPath.row
            cell.contentView.backgroundColor = UIColor.backGroundBlack
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.selectedGray
            cell.selectedBackgroundView =  selectedView
            cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
            cell.userImageView.layer.masksToBounds = true
            
            let user = comments[indexPath.row].user
            /*let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil{
                    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    cell.userImageView.image = UIImage(named: "placeholder.jpg")
                }else{
                    if data != nil{
                        let image = UIImage(data: data!)
                        cell.userImageView.image = image
                    }
                }
            }*/
            
            let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + user.objectId
            //cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"))
            if CacheType.none != ImageCache.default.imageCachedType(forKey: userImageUrl) {
                //print("ある\(userImageUrl)")
                let cache = ImageCache.default
                cache.retrieveImage(forKey: userImageUrl) { result in
                    switch result {
                    case .success(let value):
                        DispatchQueue.main.async {
                            cell.userImageView.image = value.image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }else{
                //print("ない\(userImageUrl)")
                cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), completionHandler: { (image, error, _, _) in
                    if error != nil {
                        //print(error?.localizedDescription)
                    } else {
                        cell.userImageView.image = image
                    }
                })
            }
            if comments[indexPath.row].isLiked == true{
                cell.likeButton.setImage(UIImage(named: "liked"), for: .normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "like2"), for: .normal)
            }
            
            cell.likeCountLabel.text = "\(comments[indexPath.row].likeCount)"
            cell.userNameLabel.text = user.displayName
            cell.postTextView.text = comments[indexPath.row].text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            selectedUserId = postUserId
            self.performSegue(withIdentifier: "toUserPage", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }else if indexPath.section == 1{
            selectedUserId = users[indexPath.row].objectId
            self.performSegue(withIdentifier: "toUserPage", sender: nil)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func loadComments(){
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                for commentObject in result as! [NCMBObject]{
                    //コメントしたユーザーを取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    self.users.append(user)
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    //コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    let objectId = commentObject.object(forKey: "objectId") as! String
                    
                    // Commentクラスに格納
                    let comment = Comment(objectId: objectId, postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    
                    let likeUsers = commentObject.object(forKey: "likeUser") as? [String]
                    
                    if likeUsers?.contains(NCMBUser.current().objectId) == true{
                        comment.isLiked = true
                    }else{
                        comment.isLiked = false
                    }
                    
                    if let likes = likeUsers{
                        comment.likeCount = likes.count
                    }
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                    
                }
            }
        })
    }
    
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadComments(refreshControl:)), for: .valueChanged)
        commentTableView.addSubview(refreshControl)
    }
    
    @objc func reloadComments(refreshControl: UIRefreshControl){
        refreshControl.beginRefreshing()
        self.loadComments()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    func didTapImageButton(tableViewCell: UITableViewCell, button: UIButton) {
        print("何もしない")
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
        
        if isLiked == false || isLiked == nil{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: postId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current()?.objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadComments()
                    }
                })
            })
        }else{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: postId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.removeObjects(in: [currentUser.objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadComments()
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
        
        if isSaved == false || isSaved == nil{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: postId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current()?.objectId, forKey: "saveUser")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadComments()
                    }
                })
            })
        }else{
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: postId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.removeObjects(in: [currentUser.objectId], forKey: "saveUser")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadComments()
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
            query?.getObjectInBackground(withId: self.postId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.deleteInBackground({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadComments()
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
        if postUserId == NCMBUser.current().objectId{
            alertController.addAction(deleteAction)
        }else{
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        //selectedPost = self.postId
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    func didTapCommentLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        if comments[tableViewCell.tag].isLiked == false || comments[tableViewCell.tag].isLiked == nil{
            let query = NCMBQuery(className: "Comment")
            query?.getObjectInBackground(withId: self.comments[tableViewCell.tag].objectId, block: { (comment, error) in
                comment?.addUniqueObject(NCMBUser.current()?.objectId, forKey: "likeUser")
                comment?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        self.loadComments()
                    }
                })
            })
        }else{
            let query = NCMBQuery(className: "Comment")
            query?.getObjectInBackground(withId: self.comments[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            self.loadComments()
                        }
                    })
                }
            })
        }
    }
    
}
