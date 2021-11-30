//
//  GameViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/30.
//

import UIKit
import NCMB
import CoreNFC


class GameViewController: UIViewController {
    
    var game_data:[NCMBObject] = [] //スタンプ情報
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        className = global_data[sNum]["className"]
        // クエリの作成。rallyから探す
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className:className!)
        // runの値が 1 と一致(実施中のスタンプラリー)
        query.where(field: "run", equalTo: 1)
        
        // 検索を行う
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    print("取得に成功しました")
                                        
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
        })

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
