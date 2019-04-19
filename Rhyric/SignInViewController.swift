//
//  SignInViewController.swift
//  Rhyric
//
//  Created by Ryota Nomura on 2019/02/03.
//  Copyright © 2019 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backGroundBlack
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
        userIdTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        passwordTextField.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        userIdTextField.attributedPlaceholder = NSAttributedString(string: "ユーザーID", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signIn() {
        
        if (userIdTextField.text?.characters.count)! > 0 && (passwordTextField.text?.characters.count)! > 0{
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else {
                    //let currentUser = NCMBUser.current()
                    if user?.isMailAddressConfirm() == true{
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                    }else{
                        let alert = UIAlertController(title: "メール認証", message: "メール認証を行なってください。", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func forgetPassword() {
        let alert = UIAlertController(title: "パスワード設定メール送信", message: "メールアドレスを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            if alert.textFields?.first?.text?.characters.count ?? 0 > 0{
                var error : NSError? = nil
                NCMBUser.requestPasswordReset(forEmail: alert.textFields?.first?.text, error: &error)
            }else {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにメールアドレスを入力"
        }
        self.present(alert, animated: true, completion: nil)
    }

}
