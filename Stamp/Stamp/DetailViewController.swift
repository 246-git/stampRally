//
//  DetailViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/11/18.
//

import UIKit
import NCMB
import MapKit
import CoreLocation


class DetailViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var event_name: UILabel!
    @IBOutlet weak var game_type: UILabel!
    @IBOutlet weak var venue_Map: MKMapView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var sNum:Int = 0    //選択したマップの番号
    var locationManager: CLLocationManager! //現在地表示用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        //ラベル編集
        event_name.text = global_data[sNum]["name"]
        game_type.text = global_data[sNum]["gameType"]
        
        //マップ表示設定
        let geo: NCMBGeoPoint? = global_data[sNum]["location"] // 位置情報
        let center = CLLocationCoordinate2DMake(geo!.latitude, geo!.longitude)
         
        //表示範囲
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
               //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegion(center: center, span: span)
        venue_Map.setRegion(region, animated:true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = global_data[sNum]["name"]
        annotation.subtitle = global_data[sNum]["gameType"]
        self.venue_Map.addAnnotation(annotation)

        // Do any additional setup after loading the view.
    }
    
    //現在地表示用関数
    func locationManager(_ manager: CLLocationManager,didChangeAuthorization status: CLAuthorizationStatus) {
                switch status {
                // 許可されてない場合
                case .notDetermined:
                // 許可を求める
                    manager.requestWhenInUseAuthorization()
                // 拒否されてる場合
                case .restricted, .denied:
                    // 何もしない
                    break
                // 許可されている場合
                case .authorizedAlways, .authorizedWhenInUse:
                    // 現在地の取得を開始
                    manager.startUpdatingLocation()
                    break
                default:
                    break
                }
    }
    
    //gameViewにsNum受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showGameSegue"{
            guard let destination = segue.destination as? GameViewController else {
                fatalError("Failed to prepare GameViewController")
            }
            
            destination.sNum = self.sNum
        }
        
    }
    
    
    @IBAction func signUp(_ sender: Any) {
            let className:String? = global_data[sNum]["className"] //検索対象のクラス名
            let object : NCMBObject = NCMBObject(className:className!)
            object["getStamp"] = []
            object["userName"] = playuserName
            
            // データストアへの登録を実施
            object.saveInBackground(callback: { result in
                switch result {
                    case .success:
                        // 保存に成功した場合の処理
                        print("参加完了")
                        DispatchQueue.main.sync{
                            self.infoLabel.text = "参加登録完了"
                        }
                    case let .failure(error):
                        // 保存に失敗した場合の処理
                        print("保存に失敗しました: \(error)")
                }
                
            })
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
