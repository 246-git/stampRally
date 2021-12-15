//
//  GameViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/30.
//

import UIKit
import NCMB
import CoreNFC

var NFCNum:Int = 0 //NFCタグの個数
var NFC_data:[NCMBObject] = [] //NFCクラスのデータ
var my_samp_log:[NCMBObject] = [] //自分のデータ
var activeTagID:[String]? = [] //実施されているtagID
var activeTagName:[String]? = [] //実施されているスタンプ名
var user_stmp_num:[String]? = [] //ユーザーが持っているスタンプの情報


class GameViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    var session: NFCReaderSession?
    
    @IBOutlet weak var UIDLabel1: UILabel!
    @IBOutlet weak var getID: UILabel!
    @IBOutlet weak var stampBtn: UIButton!
    
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = "" //スタンプ取得状況クラス名
    var NfcClassName:String? = ""//NFC情報クラス名
    let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    NFCNum = array.count
                    
                    for i in 0..<NFCNum{
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
                    print("ユーザー情報取得完了\(user_stmp_num)")
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
            self.semaphore.signal()
        })
        
        semaphore.wait() //ここでfindInBackGroundを待つ
        semaphore.wait()
        
        //syncをasyncに変えると動く
        DispatchQueue.main.async {
            self.getID.text = activeTagID![0]
        }
        
        //画像表示処理
        var numCount:Int = 0
        var varName:String = ""
        var dic: Dictionary<String,Any> = [:]
        let imageDone:UIImage = UIImage(named: "done")!
        let imageUndone:UIImage = UIImage(named: "undone")!
        var logoImages: [UIImageView] = []
        //スタンプ画像の表示
        for i in 0..<NFCNum{
            numCount += 70
            dic[varName] = numCount //keyにnumcountを代入
            var b: Bool = false
            for j in 0..<user_stmp_num!.count{ //NFCnumからユーザーのスタンプ数に変更する必要がある
                if user_stmp_num![j] == activeTagName![i]{
                    dic[varName]! = UIImageView(image:imageDone)//ここに条件判定を追加する
                    b = true
                    print("matched")
                }
            }
            if b == false   {dic[varName]! = UIImageView(image:imageUndone)}
            
            let rect:CGRect = CGRect(x:0, y:numCount+20, width:80, height:80)
            (dic[varName]! as! UIView).frame = rect
            
            logoImages.append(dic[varName]! as! UIImageView)
            
            self.view.addSubview(logoImages[i])
        }
        
        
        //ユーザーデータクラスの検索
        
        

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
                DispatchQueue.main.async {
                    self.UIDLabel1.text = "\(scanTagID)"  //ここでラベル表示する
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
