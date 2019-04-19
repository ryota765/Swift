//
//  SignUpViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/03.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

/*extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}*/

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundBlack
        
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        userIdTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        emailTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        confirmTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        userIdTextField.attributedPlaceholder = NSAttributedString(string: "ユーザーID（4文字以上）", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        confirmTextField.attributedPlaceholder = NSAttributedString(string: "パスワード（確認）", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUp() {
        let user = NCMBUser()
        
        if (userIdTextField.text?.characters.count)! < 4{
            print("文字数が足りません")
            let alert = UIAlertController(title: "登録エラー", message: "ユーザーIDは4文字以上で登録してください", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmTextField.text {
            user.password = passwordTextField.text!
        }else {
            print("パスワードの不一致")
        }
        user.signUpInBackground { (error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else {
                let acl = NCMBACL()
                acl.setPublicReadAccess(true)
                acl.setWriteAccess(true, for: user)
                user.acl = acl
                user.saveEventually({ (error) in
                    if error != nil{
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        let alert = UIAlertController(title: "認証メール送信", message: "認証メールを送信しました。送られたURLから認証を行なってください。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            alert.dismiss(animated: true, completion: nil)
                            self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }
        }
    }
    
    
}

