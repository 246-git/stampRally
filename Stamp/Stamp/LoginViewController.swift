//
//  LoginViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/06/14.
//

import UIKit
import NCMB

var playuserName: String = ""

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //passwordをセキリュティ入力
        self.passwordTextField.isSecureTextEntry = true
    }
    
    //Lgoinボタン押した時
    @IBAction func loginBtn(_ sender: UIButton) {
        //キーボード閉じる
        closeKeyboad()
        
        //入力が足りない場合
        if self.userNameTextField.text!.isEmpty || self.passwordTextField.text!.isEmpty{
            self.errorLabel.text = "未入力の項目があります"
            self.cleanTextField()
            return
        }
        
        //ログイン
        NCMBUser.logInInBackground(userName: userNameTextField.text!, password: passwordTextField.text!,
        callback: { result in
            //textfield空に
            DispatchQueue.main.sync{
                self.cleanTextField()
            }
            
            switch result {
                case .success:
                    // ログイン成功時の処理
                    DispatchQueue.main.sync {
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
                    let user:NCMBUser = NCMBUser.currentUser!
                    print("ログインに成功しました:\(String(describing: user.objectId))")
                    playuserName = user.userName!
                case let .failure(error):
                    // 保存に失敗した場合の処理
                    DispatchQueue.main.sync {
                        self.errorLabel.text = "ログインに失敗しました:\(error)"
                    }
                    print("ログインに失敗しました:\(error)")
            }
            
        })
        
    }
    
    @IBAction func toSignUp(_ sender: Any) {
        // TextFieldを空にする
        cleanTextField()
        // errorLabelを空に
        cleanErrorLabel()
        // キーボードを閉じる
        closeKeyboad()
        
        self.performSegue(withIdentifier: "loginToSignUp", sender: self)
    }
    

    @IBAction func tapScreen(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
     // TextFieldを空にする
    func cleanTextField(){
        userNameTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    // errorLabelを空にする
    func cleanErrorLabel(){
        errorLabel.text = ""
        
    }
    
    // キーボードを閉じる
    func closeKeyboad(){
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }

}
