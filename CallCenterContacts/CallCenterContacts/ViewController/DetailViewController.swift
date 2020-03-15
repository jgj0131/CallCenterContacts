//
//  DetailViewController.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/15.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore

class DetailViewController: UIViewController {

    // MARK: UI Property
    lazy var tableView = UITableView()
    
    // MARK: Property
    let firestoreCollectionList = ["finance", "tax"]
    var listIndex = 0
    private var  contactsData: [[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // MARK: Firstore - read Data
        let db = Firestore.firestore()
        db.collection(firestoreCollectionList[listIndex]).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.contactsData.append(document.data())
                }
                print(self.contactsData[0])
            }
            self.tableView.reloadData()
        }
        
        setConstraints()
    }
            
    // MARK: Custom Method
    func setConstraints() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(self.view.safeAreaLayoutGuide)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: Extension
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contactsData[indexPath.row]["name"] as? String ?? ""
        cell.selectionStyle = .default
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let number = URL(string: "tel://" + (contactsData[indexPath.row]["number"] as? String ?? "")) else { return }
        UIApplication.shared.open(number)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
