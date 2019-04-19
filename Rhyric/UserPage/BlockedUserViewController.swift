//
//  BlockedUserViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/03/14.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class BlockedUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchTableViewCellDelegate{
    
    var selectedUser: NCMBObject?
    var users = [NCMBUser]()
    @IBOutlet var blockedUserTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundBlack
        
        blockedUserTableView.dataSource = self
        blockedUserTableView.delegate = self
        blockedUserTableView.rowHeight = 50.0
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        blockedUserTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        blockedUserTableView.tableFooterView = UIView()
        
        self.loadBlockingUsers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
        cell.contentView.backgroundColor = UIColor.backGroundBlack
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.selectedGray
        cell.tag = indexPath.row
        cell.selectedBackgroundView =  selectedView
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        cell.followButton.setTitle("ブロック解除", for: .normal)
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
            cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), completionHandler: { (image, error, _, _) in
                if error != nil {
                    //print(error?.localizedDescription)
                } else {
                    cell.userImageView.image = image
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
        selectedUser = users[indexPath.row]
        self.performSegue(withIdentifier: "toUserPage", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        self.selectedUser = users[tableViewCell.tag]
        var message: String = ""
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        let userName = users[tableViewCell.tag].object(forKey: "userName") as? String
        if displayName == nil{
            message = userName! + "のブロックを解除しますか？"
        }else{
            message = displayName! + "のブロックを解除しますか？"
        }
        let alert = UIAlertController(title: "ブロック解除", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
           self.cancelBlock()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    func cancelBlock(){
        if let currentUser = NCMBUser.current(){
            let query = NCMBQuery(className: "Block")
            //print(selectedUser)
            query?.includeKey("user")
            query?.includeKey("blocked")
            query?.whereKey("user", equalTo: currentUser)
            query?.whereKey("blocked", equalTo: selectedUser)
            query?.findObjectsInBackground({ (result, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    for object in result as! [NCMBObject]{
                        //print(object)
                        object.deleteEventually({ (error) in
                            if error != nil{
                                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            }else{
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
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
                self.users = [NCMBUser]()
                for blocked in result as! [NCMBObject]{
                    self.users.append(blocked.object(forKey: "blocked") as! NCMBUser)
                }
                self.blockedUserTableView.reloadData()
            }
        })
    }
    
}
