//
//  AppDelegate.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/15.
//  Copyright © 2020 jang gukjin. All rights reserved.
//
import Intents
import UIKit
import Firebase
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let db = Firestore.firestore()
        
        sleep(2)
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

//extension AppDelegate {
//
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//
//        guard let audioCallIntent = userActivity.interaction?.intent as? INStartCallIntent else {
//            return false
//        }
//
//        if let contact = audioCallIntent.contacts?.first {
//
//            if let type = contact.personHandle?.type, type == .phoneNumber {
//
//                guard let callNumber = contact.personHandle?.value else {
//                    return false
//                }
//
//                let callUrl = URL(string: "tel://\(callNumber)")
//
//                if UIApplication.shared.canOpenURL(callUrl!) {
//                    UIApplication.shared.open(callUrl!, options: [:], completionHandler: nil)
//                } else {
//
//                    let alertController = UIAlertController(title: nil , message: "Calling not supported", preferredStyle: .alert)
//                    let okAlertAction = UIAlertAction(title: "Ok" , style: UIAlertAction.Style.default, handler:nil)
//                    alertController.addAction(okAlertAction)
//                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//
//        return true
//    }
//}
//
