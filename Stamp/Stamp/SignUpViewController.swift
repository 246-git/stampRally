//
//  SignUpViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/06/14.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController {
    //user name
    @IBOutlet weak var userNameTextField: UITextField!
    //password
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextField_second: UITextField!
    //エラー表示用ラベル
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField_second.isSecureTextEntry = true
    }
    
    
    @IBAction func signUpBtn(_ sender: Any) {
        closeKeyboad()
        
        //入力確認
        if self.userNameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty
            || self.passwordTextField_second.text!.isEmpty{
            self.errorLabel.text = "未入力の項目があります"
            //空にする
            self.cleanTextField()
            
            return
        } else if self.passwordTextField.text! !=  self.passwordTextField_second.text!{
            self.errorLabel.text = "パスワードが一致しません"
            self.cleanTextField()
            
            return
        }
        
        //Userインスタンスの作成
        let user = NCMBUser()
        //ユーザー名を設定
        user.userName = self.userNameTextField.text
        //パスワードを設定
        user.password = self.passwordTextField.text
        
        //会員登録を行う resultの使い方
        user.signUpInBackground(callback: {retult in
            //tectfield空に
            DispatchQueue.main.sync {
                self.cleanTextField()
            }
            
            switch retult {
            case .success:
                DispatchQueue.main.sync {
                    self.performSegue(withIdentifier: "signupToHome", sender: self)
                }
                let user:NCMBUser = NCMBUser.currentUser!
                print("ログインに成功しました:\(String(describing: user.objectId))")
                playuserName = user.userName!
                
            case let .failure(error):
                // 新規登録失敗時の処理
                self.errorLabel.text = "ログインに失敗しました:\(error)"
                print("ログインに失敗しました:\(error)")
            }
        })
    }
    
    @IBAction func tapScreen(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // TextFieldを空にする
    func cleanTextField(){
        userNameTextField.text = ""
        passwordTextField.text = ""
        passwordTextField_second.text = ""
        
    }
    
    // errorLabelを空にする
    func cleanErrorLabel(){
        errorLabel.text = ""
        
    }
    
    // キーボードを閉じる
    func closeKeyboad(){
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordTextField_second.resignFirstResponder()
        
    }
}
