//
//  ShowNfcMapViewController.swift
//  Stamp
//
//  Created by 246_MBP on 2021/12/07.
//

import UIKit
import NCMB
import MapKit
import CoreLocation

class ShowNfcMapViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var NfcMap: MKMapView!
    
    var locationManager: CLLocationManager! //現在地表示用

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ピロパティ設定
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        
        //マップ表示設定
        let geo: NCMBGeoPoint? = NFC_data[0]["location"] // 位置情報
        let center = CLLocationCoordinate2DMake(geo!.latitude, geo!.longitude)
         
        //表示範囲
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegion(center: center, span: span)
        NfcMap.setRegion(region, animated:true)
        
        //すべてのNFCピンを刺す
        for i in 0...(NFC_data.count-1){
            let pointAnnotation = MKPointAnnotation()
            let geo: NCMBGeoPoint? = NFC_data[i]["location"] //locaionデータを取得
            
            pointAnnotation.title = NFC_data[i]["name"]
            pointAnnotation.subtitle = NFC_data[i]["information"]
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: geo!.latitude, longitude: geo!.longitude)
            //ピンを刺す
            self.NfcMap.addAnnotation(pointAnnotation)
        }
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
