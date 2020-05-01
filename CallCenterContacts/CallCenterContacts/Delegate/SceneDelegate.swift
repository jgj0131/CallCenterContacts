//
//  SceneDelegate.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/15.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import Intents

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let navigationController = UINavigationController(rootViewController: ViewController())
        navigationController.navigationBar.backgroundColor = .systemBackground
        navigationController.navigationBar.topItem?.title = Texts.title.rawValue
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let audioCallIntent = userActivity.interaction?.intent as? INStartCallIntent else {
            return 
        }
        if let contact = audioCallIntent.contacts?.first {
            
            if let type = contact.personHandle?.type, type == .phoneNumber {
                guard let callNumber = contact.personHandle?.value else {
                    return
                }

                let callUrl = URL(string: "tel://\(callNumber)")
                if UIApplication.shared.canOpenURL(callUrl!) {
                    UIApplication.shared.open(callUrl!, options: [:], completionHandler: nil)
                } else {
                    let alertController = UIAlertController(title: nil , message: Texts.callingNotSupport.rawValue, preferredStyle: .alert)
                    let okAlertAction = UIAlertAction(title: Texts.confirm.rawValue , style: UIAlertAction.Style.default, handler:nil)
                    alertController.addAction(okAlertAction)
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
