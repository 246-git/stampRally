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
        
        var annotation:[MKPointAnnotation] = []  //NFCピン保存用
        for i in 0...(NFC_data.count-1){
            let pointAnnotation = MKPointAnnotation()
            let geo: NCMBGeoPoint? = NFC_data[i]["location"]
            
            pointAnnotation.title = NFC_data[i]["name"]
            pointAnnotation.subtitle = NFC_data[i]["infotmation"]
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: geo!.latitude, longitude: geo!.longitude)
            
            annotation.append(pointAnnotation)
            
            self.NfcMap.addAnnotation(pointAnnotation)
        }
        
        
        // Do any additional setup after loading the view.
        
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
