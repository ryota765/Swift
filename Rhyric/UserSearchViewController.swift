//
//  UserSearchViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/24.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class UserSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchTableViewCellDelegate, UISearchBarDelegate {
    
    var blockedUsers = [NCMBUser]()
    var blockedUserId = [String]()
    
    var users = [NCMBUser]()
    var followingUserIds = [String]()
    
    var selectedUser: NCMBUser?
    
    var searchBar: UISearchBar!
    
    @IBOutlet var searchUserTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        view.backgroundColor = UIColor.backGroundBlack
        
        searchUserTableView.dataSource = self
        searchUserTableView.delegate = self
        
        //self.searchUserTableView.allowsSelection = false
        self.searchUserTableView.rowHeight = 50.0
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        searchUserTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBlockingUsers()
        loadFollowingUserIds()
    }
    
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            let textField = searchBar.value(forKey: "_searchField") as! UITextField
            textField.backgroundColor = UIColor.lightGray
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
        cell.contentView.backgroundColor = UIColor.backGroundBlack
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.selectedGray
        cell.selectedBackgroundView =  selectedView
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        cell.followButton.setTitle("フォロー", for: .normal)
        
        /*let file = NCMBFile.file(withName: users[indexPath.row].objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil{
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                if data != nil{
                    let image = UIImage(data: data!)
                    cell.userImageView.image = image
                }
            }
        }*/
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/WiFbUTj4N9hK4DHg/publicFiles/" + users[indexPath.row].objectId
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
            cell.userImageView.kf.setImage(with: URL(string: userImageUrl),placeholder: UIImage(named: "placeholder.jpg"), completionHandler: { (image, error, _, _) in
                if error != nil {
                    //print(error?.localizedDescription)
                } else {
                    //cell.userImageView.image = image
                }
            })
        }
        
        if users[indexPath.row].object(forKey: "displayName") as? String != nil{
            cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        }else{
            cell.userNameLabel.text = users[indexPath.row].object(forKey: "userName") as? String
        }
        cell.tag = indexPath.row
        cell.delegate = self
        if followingUserIds.contains(users[indexPath.row].objectId!) == true{
            cell.followButton.isHidden = true
        }else{
            cell.followButton.isHidden = false
        }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserPage"{
            UserDefaults.standard.removeObject(forKey: "user")
            UserDefaults.standard.set(selectedUser?.objectId, forKey: "user")
            UserDefaults.standard.synchronize()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("yes")
        selectedUser = users[indexPath.row]
        self.performSegue(withIdentifier: "toUserPage", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        var message: String = ""
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        let userName = users[tableViewCell.tag].object(forKey: "userName") as? String
        if displayName == nil{
            message = userName! + "をフォローしますか？"
        }else{
            message = displayName! + "をフォローしますか？"
        }
        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.follow(selectedUser:self.users[tableViewCell.tag])
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func follow(selectedUser:NCMBUser){
        let object = NCMBObject(className: "follow")
        if let currentUser = NCMBUser.current(){
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    self.loadFollowingUserIds()
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
    }
    
    func loadUsers(searchText: String?){
        if let currentUser = NCMBUser.current(){
            let query = NCMBUser.query()
            query?.whereKey("objectId", notEqualTo: currentUser.objectId)
            query?.whereKey("active", notEqualTo: false)
            //print(self.blockedUserId)
            if blockedUserId.count >= 1{
                query?.whereKey("objectId", notContainedIn: self.blockedUserId)
            }
            if let text = searchText{
                query?.whereKey("displayName", equalTo: ["$regex" : "^(?=.*\(text)).*$"])
            }
            query?.limit = 50
            query?.order(byDescending: "createDate")
            
            query?.findObjectsInBackground({ (result, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }else{
                    self.users = result as! [NCMBUser]
                    //self.loadFollowingUserIds()
                }
            })
        }else{
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        self.searchUserTableView.reloadData()
        }
        
    func loadFollowingUserIds(){
        let query = NCMBQuery(className: "follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            } else {
                self.followingUserIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    self.followingUserIds.append(user.objectId)
                }
                self.searchUserTableView.reloadData()
            }
        })
    }
    func loadBlockingUsers(){
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
        let query = NCMBQuery(className: "Block")
        query?.includeKey("user")
        query?.includeKey("blocked")
        query?.whereKey("user", equalTo: currentUser)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                self.blockedUsers = [NCMBUser]()
                for blocked in result as! [NCMBObject]{
                    self.blockedUsers.append(blocked.object(forKey: "blocked") as! NCMBUser)
                }
                for blocked in self.blockedUsers{
                    self.blockedUserId.append(blocked.object(forKey: "objectId") as! String)
                }
            }
        })
        loadUsers(searchText: nil)
    }
    
    
}
