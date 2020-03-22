//
//  UserDefaultViewController.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/18.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore

class UserDefaultViewController: UIViewController {

    // MARK: UI Property
    lazy var tableView = UITableView()
    lazy var insertButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertRow(_:)))
        return button
    }()
    
    // MARK: Property
    private var  contactsData: [[String:String]] = []
    let searchController = UISearchController(searchResultsController: nil)
    private var filteredContacts = [[String:String]]()
    private var contactSectionTitles = [String]()
    private var totalContactsKey = [String:[[String:String]]]()
    let prefixs: [String:[UInt32]] = ["ㄱ": [4352, 12593], "ㄲ": [4353, 12594], "ㄴ": [4354, 12596], "ㄷ": [4355, 12599], "ㄸ": [4356, 12600], "ㄹ": [4357, 12601], "ㅁ":[4358, 12609], "ㅂ": [4359, 12610], "ㅃ": [4360, 12611], "ㅅ": [4361, 12613], "ㅆ": [4362, 12614], "ㅇ": [4363, 12615], "ㅈ": [4364, 12616], "ㅉ": [4365, 12617], "ㅊ": [4366, 12618], "ㅋ": [4367, 12619], "ㅌ": [4368, 12620], "ㅍ": [4368, 12621], "ㅎ": [4370, 12622]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "name"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.rightBarButtonItem = self.insertButton
        definesPresentationContext = true
        
        contactsData = UserDefaults.standard.object(forKey: "userData") as? [[String : String]] ?? []
        
        setTotalContactsKey()
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
    
    /// 전화번호부 데이터를 초성 키에 맞게 나누는 메소드
    func setTotalContactsKey() {
        self.totalContactsKey = [:]
        for contact in self.contactsData {
            let contactName = contact["name"] ?? ""
            let contactKey = self.prefixKorean(name: contactName)
            if var contactValues = self.totalContactsKey[contactKey] {
                contactValues.append(contact)
                self.totalContactsKey[contactKey] = contactValues
            } else {
                self.totalContactsKey[contactKey] = [contact]
            }
        }
        self.contactSectionTitles = [String](self.totalContactsKey.keys)
        self.contactSectionTitles = self.contactSectionTitles.sorted(by: { $0 < $1 })
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
    
    /// 초성 분리 메소드
    func extractPrefixKoreann(name:String) -> [String] {
        let word = name
        var convertedWord: [String] = []
        for text in word {
            convertedWord.append(prefixKorean(name: String(text)))
        }
        return convertedWord
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        self.setTotalContactsKey()
        return contactSectionTitles
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredContacts = contactsData.filter({( contact : [String:Any]) -> Bool in
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
    
    @objc
    func insertRow(_ sender: Any) {
        let alert = UIAlertController(title: "추가하기", message: "이름과 번호를 입력하세요", preferredStyle: .alert)
        alert.addTextField { (name) in
            name.placeholder = "name"
        }
        alert.addTextField { (number) in
            number.placeholder = "number"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (ok) in
            var value = ["name": "", "number": ""]
            value["name"] = alert.textFields?[0].text
            value["number"] = alert.textFields?[1].text
            self.contactsData.append(value)
        
            if self.totalContactsKey[self.prefixKorean(name: value["name"] ?? "")] == nil {
                self.setTotalContactsKey()
                self.tableView.beginUpdates()
                let sectionNumber = self.contactSectionTitles.firstIndex(of: self.prefixKorean(name: value["name"] ?? "")) ?? 0
                self.tableView.insertSections(IndexSet(integer: sectionNumber), with: .automatic)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: sectionNumber)], with: .automatic)
                self.tableView.endUpdates()
                UserDefaults.standard.set(self.contactsData, forKey: "userData")
            } else {
                self.setTotalContactsKey()
                let keysValue = self.totalContactsKey[self.prefixKorean(name: value["name"] ?? "")]
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: keysValue!.count - 1, section: self.contactSectionTitles.firstIndex(of: self.prefixKorean(name: value["name"] ?? "")) ?? 0)], with: .automatic)
                self.tableView.endUpdates()
                UserDefaults.standard.set(self.contactsData, forKey: "userData")
            }
            
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
             //code
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Extension
extension UserDefaultViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.setTotalContactsKey()
        if isFiltering(){
            return 1
        } else {
            return contactSectionTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.setTotalContactsKey()
        if isFiltering() {
            return ""
        } else {
            return contactSectionTitles[section]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.setTotalContactsKey()
        if isFiltering() {
            return filteredContacts.count
        } else {
            let contactKey = contactSectionTitles[section]
            if let contactValues = totalContactsKey[contactKey] {
                return contactValues.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as UITableViewCell
        cell.selectionStyle = .default
        let contactToDisplay:[String:Any]
        if isFiltering(){
            contactToDisplay = filteredContacts[indexPath.row]
            cell.textLabel?.text = contactToDisplay["name"] as? String ?? ""
        } else {
            let contactKey = contactSectionTitles[indexPath.section]
            if let contactValues = totalContactsKey[contactKey] {
                cell.textLabel?.text = contactValues[indexPath.row]["name"]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentContact: [String:String] = [:]
        if isFiltering() {
            currentContact["name"] = filteredContacts[indexPath.row]["name"]
            currentContact["number"] = filteredContacts[indexPath.row]["number"]
        } else {
            currentContact["name"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["name"])
            currentContact["number"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["number"])
        }
        
        guard let number = URL(string: "tel://" + (currentContact["number"] ?? "")) else { return }
        UIApplication.shared.open(number)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Edit Style을 정의하는 메소드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var currentContact: [String:String] = [:]
            currentContact["name"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["name"])
            currentContact["number"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["number"])
            let index = self.contactsData.firstIndex(of: currentContact)
            self.contactsData.remove(at: index ?? 0)
            
            
            tableView.beginUpdates()
            if (totalContactsKey[contactSectionTitles[indexPath.section]] ?? []).count == 1 {
                self.setTotalContactsKey()
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                self.setTotalContactsKey()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()
            UserDefaults.standard.set(self.contactsData, forKey: "userData")
        }
    }
}

extension UserDefaultViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
