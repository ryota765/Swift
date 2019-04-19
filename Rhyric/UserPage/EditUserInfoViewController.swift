//
//  EditUserInfoViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/03.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import SVProgressHUD

class EditUserInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var introductionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundBlack
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        userNameTextField.delegate = self
        userIDTextField.delegate = self
        introductionTextView.delegate = self
        
        if let user = NCMBUser.current(){
            userNameTextField.text = user.object(forKey: "displayName") as? String
            introductionTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
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
            let userId = user.userName
            userIDTextField.text = userId
        }else{
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let resizedImage = selectedImage.scale(byFactor: 0.4)
        
        picker.dismiss(animated: true, completion: nil)
        
        let data = resizedImage!.pngData()
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: data) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else {
                self.userImageView.image = resizedImage
            }
        }) { (progress) in
            print(progress)
        }
        
    }
    
    
    @IBAction func selectImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else {
                print("この機種では彼らが使用できません")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else {
                print("この機種ではフォトライブラリを使用できません")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        actionController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        actionController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2-50, y: screenSize.size.height-30, width: 100, height: 40)
        self.present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func closeEditViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveUserInfo() {
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(userIDTextField.text, forKey: "userName")
        user?.setObject(introductionTextView.text, forKey: "introduction")
        user?.saveInBackground({ (error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    
}
