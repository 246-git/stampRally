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
    
    //画面遷移時の情報受け渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "showGameSegue"{
            guard let destination = segue.destination as? GameViewController else {
                fatalError("Failed to prepare DetailViewController")
            }
            
            destination.sNum = self.sNum
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
