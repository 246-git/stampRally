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


class GameViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    var session: NFCReaderSession?
    
    
    @IBOutlet weak var UIDLabel1: UILabel!
    @IBOutlet weak var getID: UILabel!
    @IBOutlet weak var stampBtn: UIButton!
    
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = "" //スタンプ取得状況クラス
    var NfcClassName:String? = ""//NFC情報クラス


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
        
        // 検索を行う
        query.findInBackground(callback: { result in
            switch result {
                case let .success(array):
                    print("取得に成功しました")
                    NFC_data = array
                    NFCNum = array.count
                    
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
        })
        

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
