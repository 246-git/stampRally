//
//  GameViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/30.
//

import UIKit
import NCMB
import CoreNFC

var tagID:[String] = [] //tagID保存
var NFCNum:Int = 0 //NFCタグの個数
var NFC_data:[NCMBObject] = [] //NFCクラスのデータ
var user_stmp_num:[String?] = [] //ユーザーが持っているスタンプの情報
var my_samp_log:[NCMBObject] = [] //自分のデータ


class GameViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    var session: NFCReaderSession?
    
    @IBOutlet weak var UIDLabel1: UILabel!
    @IBOutlet weak var getID: UILabel!
    @IBOutlet weak var stampBtn: UIButton!
    
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = "" //スタンプ取得状況クラス
    var NfcClassName:String? = ""//NFC情報クラス
    var stamp_done: [UIImageView] = [] //取得済みスタンプ
    var stamp_undone: [UIImageView] = [] //未取得のスタンプ
    let semaphore = DispatchSemaphore(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ボタンに丸みをもたせる
        self.stampBtn.layer.cornerRadius = 10.0
        
        className = global_data[sNum]["className"] //検索対象のクラス名
        NfcClassName = className! + "NFC"
        
        // クエリの作成。rallyから探す
        var query : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className:NfcClassName!)
        // runの値が 1 と一致(実施中のスタンプラリー)
        query.where(field: "run", equalTo: 1)
        
        //let semaphore = DispatchSemaphore(value: 0)
        
        // NFCクラスの検索
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    print("スタンプ状況取得完了")
                    NFC_data = array
                    NFCNum = array.count
                    self.semaphore.signal() //////////////////////////////
                    
                    for i in 0..<NFCNum{
                        let tID:String? = array[i]["tagID"]
                        tagID.append(tID!)
                        print("tag[\(i)]:\(tagID[i])")
                    }
                    
                    //UI部品の更新はメインスレッドで行う
                    DispatchQueue.main.sync {
                        self.getID.text = tagID[0]
                    }
                    
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
            self.semaphore.signal() //////////////////////////////
        })
        
        //クエリ作成
        var query2 : NCMBQuery<NCMBObject> = NCMBQuery.getQuery(className:NfcClassName!)
        query2 = NCMBQuery.getQuery(className:className!)
        // 自分のユーザーデータを取得
        query2.where(field: "userName", equalTo: playuserName)
        
        
        // ユーザーデータクラスの検索
        query2.findInBackground(callback: { result in
            switch result {
                case let .success(array2):
                    print("ユーザー情報取得完了\(array2.count)") //arrayの取得には成功しているが中身が空になっている
                    my_samp_log = array2
                    
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
            self.semaphore.signal() //////////////////////////////
        })
        
        semaphore.wait() //セマフォ
        semaphore.wait() //セマフォ
        
        
        var numCount:Int = 0
        var varName:String = ""
        var dic: Dictionary<String,Any> = [:]
        let imageDone:UIImage = UIImage(named: "done")!
        //let imageUndone:UIImage = UIImage(named: "undone")!
        var logoImages: [UIImageView] = []
        //スタンプ画像の表示
        for i in 0...NFCNum{
            print("UIImage[\(NFCNum)]")
            numCount += 70
            dic[varName] = numCount
            //varName = String(numCount)
            dic[varName]! = UIImageView(image:imageDone)
            let rect:CGRect = CGRect(x:0, y:numCount+20, width:80, height:80)
            (dic[varName]! as! UIView).frame = rect
            
            logoImages.append(dic[varName]! as! UIImageView)
            print(logoImages)
            
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
                let UID = sTag.identifier.map{ String(format: "%.2hhx", $0)}.joined()
                print("UID:",UID)
                print(sTag.identifier)
                session.alertMessage = "スタンプ完了！"
                session.invalidate()
                DispatchQueue.main.async {
                    self.UIDLabel1.text = "\(UID)"  //ここでラベル表示する
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
