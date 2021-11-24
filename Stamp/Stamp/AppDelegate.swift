//
//  AppDelegate.swift
//  Stamp
//
//  Created by 246_MBP on 2021/06/14.
//

import UIKit
import NCMB

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //APIキー設定
    let applicationkey = "ac99d475134dae75c1abcad85db84ff7f31f176fb3d3bde6f71658dbca078ce4"
    let clientkey      = "9bc46db23f483ae5abb8711aedb255c70adc49470ae75da95678218221d76496"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //SDK初期化
        NCMB.initialize(applicationKey: applicationkey, clientKey: clientkey)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

