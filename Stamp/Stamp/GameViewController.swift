//
//  GameViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/30.
//

import UIKit
import NCMB
import CoreNFC


class GameViewController: UIViewController, NFCTagReaderSessionDelegate {
    
    var session: NFCReaderSession?
    
    
    @IBOutlet weak var UIDLabel1: UILabel!
    
    var game_data:[NCMBObject] = [] //スタンプ情報
    var sNum:Int = 0    //選択したマップの番号
    var className:String? = "" //検索するクラス名
    var tagID:[String] = [] //tagID保存
    var NFCNum:Int = 0 //NFCタグの個数

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
                    self.NFCNum = array.count
                    self.game_data = array
                    
                    for i in 0..<self.NFCNum{
                        let tID:String? = array[i]["tagID"]
                        self.tagID.append(tID!)
                    }
                    
                case let .failure(error):
                    print("取得に失敗しました: \(error)")
            }
        })

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func CaptureBtn(_ sender: Any) {
        self.session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        self.session?.alertMessage = "Hold Your Phone Near The NFC Tag"
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
            session.alertMessage = "More Than One Tag "
            session.invalidate()
        }
        let tag = tags.first!
        session.connect(to: tag){ (error) in
            if nil != error{
                session.invalidate(errorMessage: "Connection Failed")
            }
            if case let .miFare(sTag) = tag{
                let UID = sTag.identifier.map{ String(format: "%.2hhx", $0)}.joined()
                print("UID:",UID)
                print(sTag.identifier)
                session.alertMessage = "UID Captured"
                session.invalidate()
                DispatchQueue.main.async {
                    self.UIDLabel1.text = "\(UID)"
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
