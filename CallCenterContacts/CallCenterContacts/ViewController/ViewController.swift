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
    let searchController = UISearchController(searchResultsController: nil)
    private var savedContacts: [[String:String]] = []
    private var contactsData: [[String:Any]] = []
    private var filteredContacts = [[String:Any]]()
    private var userData: [[String:String]] = []
    let prefixs: [String:[UInt32]] = ["ㄱ": [4352, 12593], "ㄲ": [4353, 12594], "ㄴ": [4354, 12596], "ㄷ": [4355, 12599], "ㄸ": [4356, 12600], "ㄹ": [4357, 12601], "ㅁ":[4358, 12609], "ㅂ": [4359, 12610], "ㅃ": [4360, 12611], "ㅅ": [4361, 12613], "ㅆ": [4362, 12614], "ㅇ": [4363, 12615], "ㅈ": [4364, 12616], "ㅉ": [4365, 12617], "ㅊ": [4366, 12618], "ㅋ": [4367, 12619], "ㅌ": [4368, 12620], "ㅍ": [4368, 12621], "ㅎ": [4370, 12622]]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.searchBar.placeholder = Texts.name.rawValue
        
        INPreferences.requestSiriAuthorization { (status) in
            if status == .authorized {
                print("Siri access allowed")
            } else {
                print("Siri access denied")
            }
        }
        setFireStoreData()
        setConstraints()
        setNavigationBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        let userDefault = UserDefaults(suiteName: SiriDataManager.sharedSuiteName)
        savedContacts = userDefault?.object(forKey: SiriDataManager.sharedSuiteName) as? [[String: String]] ?? []
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
    
    private func setNavigationBarItems() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
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
    
    /// 이름을 받아 한글인 경우 맨 앞글자의 초성을 따오는 메소드
    func prefixKorean(name: String) -> String {
        guard let firstText = name.first else { return "" }
        let unicodeText = Unicode.Scalar(String(firstText))?.value
        guard let value = unicodeText else { return "" }
        if (value < 0xAC00 || value > 0xD7A3) { return String(name.prefix(1)) }
        else {
            let first = ((value - 0xAC00)/28)/21
            if let scalarValue = Unicode.Scalar(0x1100 + first) {
                return String(scalarValue)
            } else {
                return ""
            }
        }
    }
    
    // 초성 분리 메소드
    func extractPrefixKoreann(name:String) -> [String] {
        let word = name
        var convertedWord: [String] = []
        for text in word {
            convertedWord.append(prefixKorean(name: String(text)))
        }
        return convertedWord
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredContacts = savedContacts.filter({( contact : [String:Any]) -> Bool in
            let name = contact["name"] as? String ?? ""
            let convertedName = extractPrefixKoreann(name: name)
            var judgePrefix = true
            var value: [String] = []
            for letter in searchText {
                let extractedLetter = prefixs[prefixKorean(name: String(letter))]?[0] ?? 0
                value.append(String(Unicode.Scalar(extractedLetter)!))
                print(value)
            }
            for index in 0..<value.count {
                if index<convertedName.count {
                    if convertedName[index] == value[index] && judgePrefix == true {
                        judgePrefix = true
                    } else {
                        judgePrefix = false
                    }
                } else {
                    judgePrefix = false
                }
            }
            return name.lowercased().contains(searchText.lowercased()) || judgePrefix
      })
      tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: Extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredContacts.count
        } else {
            return contactsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if isFiltering(){
            let contactToDisplay:[String:Any]
            contactToDisplay = filteredContacts[indexPath.row]
            cell.textLabel?.text = contactToDisplay["name"] as? String ?? ""
        } else {
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentContact: [String:String] = [:]
        if isFiltering() {
            currentContact["name"] = filteredContacts[indexPath.row]["name"] as? String ?? ""
            currentContact["number"] = filteredContacts[indexPath.row]["number"] as? String ?? ""
            guard let number = URL(string: "tel://" + (currentContact["number"] ?? "")) else { return }
            UIApplication.shared.open(number)
            self.tableView.deselectRow(at: indexPath, animated: true)
        } else {
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
}

// MARK: Extension
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
