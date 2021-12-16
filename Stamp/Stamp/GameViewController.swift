//
//  GameViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/30.
//

import UIKit
import NCMB
import CoreNFC


var NFC_data:[NCMBObject] = [] //NFCクラスのデータ
var my_samp_log:[NCMBObject] = [] //自分のデータ
var activeTagID:[String]? = [] //実施されているtagID
var activeTagName:[String]? = [] //実施されているスタンプ名
var user_stmp_num:[String]? = [] //ユーザーが持っているスタンプの情報



class GameViewController: UIViewController, NFCTagReaderSessionDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var session: NFCReaderSession?
    var res:[String] = []
    
    @IBOutlet weak var stampBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var NFCNumRes:Int = 0{
        didSet{
            tableView.reloadData()
        }
    } //NFCタグの個数
    
    var photos:[String] = []{
        didSet{
            tableView.reloadData()
        }
    }//done,undoneが入っている
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NFCNumRes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを作る
        let cell = tableView.dequeueReusableCell(withIdentifier: "stampCell", for: indexPath as IndexPath)
        cell.imageView!.image = UIImage(named: self.photos[indexPath.row])
        cell.textLabel!.text = activeTagName![indexPath.row]
        
        return cell
    }
    
    //cellの高さ調整
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
    }

    
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = "" //スタンプ取得状況クラス名
    var NfcClassName:String? = ""//NFC情報クラス名
    let semaphore = DispatchSemaphore(value: 0)
    var NFCNum:Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "スタンプ画面"
        //ボタンに丸みをもたせる
        self.stampBtn.layer.cornerRadius = 10.0
        
        className = global_data[sNum]["className"] //検索対象のクラス名
        NfcClassName = className! + "NFC"
        
        // NFCクラスの検索
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className:NfcClassName!)
        // runの値が 1 と一致(実施中のスタンプラリー)
        query.where(field: "run", equalTo: 1)
        
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    print("NFCクラス取得完了")
                    NFC_data = array
                    self.NFCNum = array.count
                    DispatchQueue.main.async {
                        self.NFCNumRes = self.NFCNum
                    }
                    
                    
                    for i in 0..<self.NFCNum{
                        let tID:String? = array[i]["tagID"]
                        let name:String? = array[i]["name"]
                        
                        //実施中のタグIDと名前をグローバル変数に保存
                        activeTagID!.append(tID!)
                        activeTagName!.append(name!)
                        print("tag[\(i)]:\(activeTagID![i])")
                    }
                    
                    self.semaphore.signal()
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
            self.semaphore.signal()
            print("セマフォ")
        })
        
        //ユーザーデータクラスの検索
        var query2 : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className:NfcClassName!)
        query2 = NCMBQuery.getQuery(className:className!)
        // 自分ユーザーデータを取得
        query2.where(field: "userName", equalTo: playuserName)

        query2.findInBackground(callback: { result in
            switch result {
                case let .success(array2):
                    my_samp_log = array2
                    user_stmp_num = array2[0]["getStamp"]
                    print("ユーザー情報取得完了")
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
            self.semaphore.signal()
            print("セマフォ")
        })
        
        
        for _ in 0..<3{
            semaphore.wait() //ここでfindInBackGroundを待つ
        }
        
        //スタンプ画像の表示
        for i in 0..<self.NFCNum{
            var b: Bool = false
            for j in 0..<user_stmp_num!.count{ //表示順序を何とかする
                if user_stmp_num![j] == activeTagName![i]{
                    self.res.append("done")
                    b = true
                    print("matched")
                }
            }
            if b == false   {
                self.res.append("undone")
                print("unmatched")
            }
        }
        
        DispatchQueue.main.async {
            print("phoeos set\(self.res)") //resが空になっている
            self.photos = self.res
        }

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func CaptureBtn(_ sender: Any) {
        self.session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        self.session?.alertMessage = "携帯をタグに近づけてください"
        self.session?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("session begun!")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("error with launching session")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("connecting to Tag")
        if tags.count > 1 {
            session.alertMessage = "複数のタグが検出されました"
            session.invalidate()
        }
        let tag = tags.first!
        session.connect(to: tag){ (error) in
            if nil != error{
                session.invalidate(errorMessage: "接続失敗")
            }
            if case let .miFare(sTag) = tag{
                let scanTagID = sTag.identifier.map{ String(format: "%.2hhx", $0)}.joined()
                print("UID:",scanTagID)
                print(sTag.identifier)
                session.alertMessage = "スタンプ完了！"
                session.invalidate()
                
                var judge:Bool = true
                for i in 0..<self.NFCNum{
                    if activeTagID![i] == scanTagID {
                        print("このタグは[\(activeTagName![i])]")
                        for j in 0..<user_stmp_num!.count{
                            if activeTagName![i] == user_stmp_num![j]{
                                judge = false
                            }
                        }
                    }
                }
                
                if judge == true{
                    print("新規スタンプ獲得")
                }
                
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
