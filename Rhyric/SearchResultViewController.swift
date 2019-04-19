//
//  SearchResultViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/01/27.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WordListCellDelegate {
    
    @IBOutlet var resultTableView: UITableView!
    var text:String = ""
    //検索エンジンから受け取る情報
    var passedList:Array<Any> = []
    //csvを整理したDictionary
    var csvDict:[String:String] = [:]
    //passedList内のWordを韻に変換したもの
    var yomiOuin:String = ""
    //var matchList:Array<String> = []
    
    var allWords = [Word]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultTableView.allowsSelection = false
        self.resultTableView.rowHeight = 50.0
        resultTableView.dataSource = self
        resultTableView.delegate = self
        
        let nib = UINib(nibName: "WordListCell", bundle: Bundle.main)
        resultTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        resultTableView.tableFooterView = UIView()

        do {
            //passedList内のWordを韻に変換
            self.toVowelChunk()
            //NCMBから単語をload
            loadWords()

            //csvを整理してDictionaryに格納
            //csvToDict()

            //resultTableView.dataSource = self
        }
    }
    /*func csvToDict() {
        if let csvPath = Bundle.main.path(forResource: "test", ofType: "csv") {
            do {
                let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                let csvArr = csvStr.characters.split(separator: "\n").map(String.init)
                for str in csvArr {
                    let arr:[String] = str.components(separatedBy: ",")
                    csvDict.updateValue(arr[1], forKey: arr[0])
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }*/
    
    func toVowelChunk(){
        
        var yomiOuinSub = Rhyme.toVowel(word: passedList[0] as! String)
        //全一致
        if passedList[2] as! Int + 1 >= yomiOuinSub.characters.count {
            print("そのまま使う")
        } else if passedList[2] as! Int == 0{
            print("そのまま使う")
        } else {
            let letterNum = passedList[2] as! Int + 1
            if passedList[1] as! Int == 0{
                yomiOuinSub = String(yomiOuinSub.prefix(letterNum))
            } else {
                yomiOuinSub = String(yomiOuinSub.suffix(letterNum))
            }
        }
        yomiOuin = yomiOuinSub
    }
    
    func loadWords(){
        guard let userId = NCMBUser.current()?.objectId else{
            //ログイン画面に戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            return
        }
        
        let query = NCMBQuery(className: "Word")
        if passedList[1] as! Int == 0 {
            //query?.whereKey("rhyme", equalTo: "^\(yomiOuin).*$")
            query?.whereKey("rhyme", equalTo: ["$regex": "^\(yomiOuin).*$"])
        } else {
            //query?.whereKey("rhyme", equalTo: ".*\(yomiOuin)$")
            query?.whereKey("rhyme", equalTo: ["$regex": ".*\(yomiOuin)$"])
        }
        query?.order(byDescending: "likeCount")
        query?.limit = 1000
        query?.findObjectsInBackground({ (result, error) in
            print("呼ばれた")

            if error != nil{
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }else{
                for wordObject in result as! [NCMBObject]{
                    let word = wordObject.object(forKey: "word") as! String
                    let rhyme = wordObject.object(forKey: "rhyme") as! String
                    let likeUser = wordObject.object(forKey: "likeUser") as? [String]
                    let likeCount = wordObject.object(forKey: "likeCount") as? Int ?? 0
                    let words = Word(objectId: wordObject.objectId, word: word, likeUsers: likeUser ?? [])
                    words.likeCount = likeCount
                    self.csvDict.updateValue(rhyme, forKey: word)
                    if likeUser?.contains(userId) == true{
                        words.isLiked = true
                    }else{
                        words.isLiked = false
                    }
                    self.allWords.append(words)
                }
            }
            //韻とマッチする
            //self.rhymeMatch()
            
            // Shuffle
            let filteredWords = self.allWords.filter({ $0.likeCount == 0 }).shuffled()
            let likedWords = self.allWords.filter({ $0.likeCount! > 0 })
            self.allWords = likedWords + filteredWords
            self.resultTableView.reloadData()
        })
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWords.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WordListCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        if allWords[indexPath.row].isLiked == true{
            cell.goodButton.setImage(UIImage(named: "gooded"), for: .normal)
        }else{
            cell.goodButton.setImage(UIImage(named: "good"), for: .normal)
        }
        
        cell.contentView.backgroundColor = UIColor.backGroundBlack
        
        cell.wordLabel?.text = allWords[indexPath.row].word
        let likeCount = allWords[indexPath.row].likeUsers?.count
        cell.goodLabel?.text = "\(String(likeCount!))件"
        return cell
    }
    
    /*cellからwikiとかwebサイトに飛ばす場合に使う
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }*/
    
    func didTapCopyButton(tableViewCell: UITableViewCell, button: UIButton) {
        self.text = allWords[tableViewCell.tag].word
        print(self.text)
        let board = UIPasteboard.general
        //board.setValue(self.text, forPasteboardType: "public.text")
        board.string = self.text
    }
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton) {
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
        
        if allWords[tableViewCell.tag].isLiked == false || allWords[tableViewCell.tag].isLiked == nil{
            allWords[tableViewCell.tag].isLiked = true
            allWords[tableViewCell.tag].likeUsers?.append((currentUser.objectId)!)
            let likeUserCount = Int((self.allWords[tableViewCell.tag].likeUsers?.count)!)
            let query = NCMBQuery(className: "Word")
            //print("呼ばれるID\(allWords[tableViewCell.tag].objectId)")
            query?.getObjectInBackground(withId: allWords[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                post?.setObject(likeUserCount, forKey: "likeCount")
                post?.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    }else{
                        //self.loadWords() loadするとタイムラインが変わってしまう
                        self.resultTableView.reloadData()
                    }
                })
            })
        }else{
            allWords[tableViewCell.tag].isLiked = false
            //数合わせのために最初の要素を削除
            allWords[tableViewCell.tag].likeUsers?.removeFirst()
            let likeUserCount = Int((self.allWords[tableViewCell.tag].likeUsers?.count)!)
            let query = NCMBQuery(className: "Word")
            //print("単語は\(allWords[tableViewCell.tag].word)")
            query?.getObjectInBackground(withId: allWords[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    //print("持ってきた言葉は\(post)")
                    post?.removeObjects(in: [currentUser.objectId], forKey: "likeUser")
                    post?.setObject(likeUserCount, forKey: "likeCount")
                    post?.saveEventually({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            //self.loadWords() loadするとタイムラインが変わってしまう
                            self.resultTableView.reloadData()
                        }
                    })
                }
            })
            
        }
    }

}

