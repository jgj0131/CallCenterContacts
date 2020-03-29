//
//  SiriDataManager.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/24.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import Foundation
import Intents

class SiriDataManager {
    static let sharedManager = SiriDataManager()
    static let sharedSuiteName = "group.com.jang-gukjin.CallCenterContacts"
    
    let userDefaults  = UserDefaults(suiteName: sharedSuiteName)
    
    func findContact(contactName: String?, with completion: ([INPerson]) -> Void) {
        let savedContacts = userDefaults?.object(forKey: SiriDataManager.sharedSuiteName) as? [[String: String]]
        var matchingContacts = [INPerson]()

        if let contacts = savedContacts {
            for contact in contacts {
                if let name = contact["name"]?.lowercased(), name.contains(contactName!.lowercased()) {
                    let personHandle  = INPersonHandle(value: contact["number"], type: .phoneNumber)
                    matchingContacts.append(INPerson(personHandle: personHandle, nameComponents: nil, displayName: name, image: nil, contactIdentifier: nil, customIdentifier: personHandle.value))
                }
            }
        }
        completion(matchingContacts)
    }
    
    func saveContacts(contacts: [[String: String]]) {
        userDefaults?.set(contacts, forKey: SiriDataManager.sharedSuiteName)
        userDefaults?.synchronize()
    }
}
