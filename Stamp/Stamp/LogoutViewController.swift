//
//  LogoutViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/06/14.
//

import UIKit
import NCMB

class LogoutViewController: UIViewController {

    @IBAction func logoutBtn(_ sender: Any) {
        NCMBUser.logOut()
        self.dismiss(animated: true, completion: nil)
        print("ログアウトしました")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
