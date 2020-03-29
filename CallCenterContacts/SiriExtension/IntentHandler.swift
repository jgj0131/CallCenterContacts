//
//  IntentHandler.swift
//  SiriExtension
//
//  Created by jang gukjin on 2020/03/23.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INStartCallIntentHandling {
    
    func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INStartCallIntent.self))
        let response = INStartCallIntentResponse(code: .continueInApp, userActivity: userActivity)
        completion(response)
    }
    
    func resolveContacts(for intent: INStartCallIntent, with completion: @escaping ([INStartCallContactResolutionResult]) -> Void) {
        var contactName: String?
        if let contacts = intent.contacts {
            contactName = contacts.first?.displayName
        }
        
        SiriDataManager.sharedManager.findContact(contactName: contactName, with: { (contacts) in
            switch contacts.count {
            case 1:
                completion([INStartCallContactResolutionResult.success(with: contacts.first!)])
            case 2 ... Int.max:
                completion([INStartCallContactResolutionResult.disambiguation(with: contacts)])
            default:
                completion([INStartCallContactResolutionResult.unsupported()])
            }
        })
    }
    
    func confirm(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INStartCallIntent.self))
        let response = INStartCallIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
}
