//
//  ViewController.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/15.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore
import Intents

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: UI Property
    lazy var tableView = UITableView()
    
    // MARK: Property
    let contactsList = ["긴급", "금융", "문화", "민원", "부동산", "쇼핑", "안보", "여행", "의료", "추가등록"]
    let firestoreCollectionList = ["emergency", "finance", "culture", "civil complaint", "real property", "shopping", "security", "travel", "medical"]
    private var contactsData: [[String:Any]] = []
    private var userData: [[String:String]] = []
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        INPreferences.requestSiriAuthorization { (status) in
            if status == .authorized {
                print("Siri access allowed")
            } else {
                print("Siri access denied")
            }
        }
        setFireStoreData()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: Custom Method
    func setConstraints() {
        self.view.addSubview(tableView)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(self.view.safeAreaLayoutGuide)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func setFireStoreData() {
        let db = Firestore.firestore()
        for index in 0..<firestoreCollectionList.count {
            db.collection(firestoreCollectionList[index]).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.contactsData.append(document.data())
                    }
                    self.contactsData.sort{( $0["name"] as! String) < ($1["name"] as! String) }
                }
                self.userData = UserDefaults.standard.object(forKey: "userData") as? [[String : String]] ?? []
                let contactsStringData = self.contactsData as? [[String:String]] ?? []
                let datas = contactsStringData + self.userData
                let setDatas = Set(datas)
                SiriDataManager.sharedManager.saveContacts(contacts: Array(setDatas))
            }
        }
    }
}

// MARK: Extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contactsList[indexPath.row]
        if cell.textLabel?.text == "긴급" {
            cell.textLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .label
        }
        cell.textLabel?.snp.makeConstraints{ (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(UIScreen.main.bounds.width / 22)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == contactsList.count - 1{
            let userDefaultViewontroller = UserDefaultViewController()
            navigationController?.pushViewController(userDefaultViewontroller, animated: true)
        } else {
            let detailViewontroller = DetailViewController()
            detailViewontroller.listIndex = indexPath.row
            navigationController?.pushViewController(detailViewontroller, animated: true)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
