//
//  HomeViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/09.
//

import UIKit
import NCMB

//選択したイベントデータ
var global_data:[NCMBObject] = []
//選択したイベントの配列番号
var global_sNum:Int = 0
//スタンプラリー選択画面の処理
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func logOut_btn(_ sender: Any) {
        NCMBUser.logOut()
        UserDefaults.standard.removeObject(forKey: "userName")//userdefaultsのデータを消しておく
        UserDefaults.standard.removeObject(forKey: "password")
    } //log outボタン
    @IBOutlet weak var username_label: UILabel!
    
    
    var userpage_btn: UIBarButtonItem!  //userページに飛ぶ用のボタン
    
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
        
        let text = NSMutableAttributedString(string: "")
        text.append(NSAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "person.circle")!)))
        text.append(NSAttributedString(string: playuserName))
        self.username_label!.attributedText = text
        self.username_label.font = UIFont.systemFont(ofSize: 21)
        self.username_label.textColor = .red
        self.username_label.sizeToFit()
        

        userpage_btn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload_btn(_:)))
        self.navigationItem.rightBarButtonItem = userpage_btn
        
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
    
    
    @objc func reload_btn(_ sender: UIBarButtonItem) {
        loadView()
        viewDidLoad()
    }
    
    //画面遷移時の情報受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showDetailSegue"{
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? DetailViewController else {
                    fatalError("Failed to prepare DetailViewController")
                }
                global_sNum = indexPath.row
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
