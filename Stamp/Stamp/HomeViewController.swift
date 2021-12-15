//
//  HomeViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/09.
//

import UIKit
import NCMB

//グローバル
var global_data:[NCMBObject] = []
//スタンプラリー選択画面の処理
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //会場名
    var venueName:[String] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    //会場数
    var venueNum: Int = 0{
        didSet{
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venueNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを作る
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "venueCell")
        //テキストにクーポン特典を設定
        cell.textLabel?.text = self.venueName[indexPath.row]
        return cell
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // クエリの作成。rallyから探す
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className: "Rally")
        // runの値が 1 と一致(実施中のスタンプラリー)
        query.where(field: "run", equalTo: 1)

        // 検索を行う
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    print("イベント情報取得完了　件数: \(array.count)")
                    global_data = array
                    
                    var vName:[String] = []
                    for i in 0..<array.count{
                        let res:String? = array[i]["name"]
                        vName.append(res!)
                        
                        print("vName[\(i)] = \(vName[i])")
                    }
                    
                    //メインスレッドでテーブル更新
                    DispatchQueue.main.async() { () ->Void in
                        self.venueNum = array.count
                        self.venueName = vName
                    }
                                        
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
        })
        
    }
    
    //画面遷移時の情報受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showDetailSegue"{
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? DetailViewController else {
                    fatalError("Failed to prepare DetailViewController")
                }
                
                destination.sNum = indexPath.row
            }
        }
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
