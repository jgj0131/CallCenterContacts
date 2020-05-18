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
    lazy var collectionView = UICollectionView()
    lazy var tableView = UITableView()
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = Texts.title.rawValue
        title.textColor = .label
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: Property
    let firestoreCollectionList = ["emergency", "finance", "culture", "civil complaint", "real property", "shopping", "security", "travel", "medical"]
    var listIndex = 0
    private var  contactsData: [[String:Any]] = []
    private var  userContactsData: [[String:String]] = []
    let searchController = UISearchController(searchResultsController: nil)
    private var filteredContacts = [[String:Any]]()
    private var contactSectionTitles = [String]()
    private var totalContactsKey = [String:[[String:Any]]]()
    let prefixs: [String:[UInt32]] = ["ㄱ": [4352, 12593], "ㄲ": [4353, 12594], "ㄴ": [4354, 12596], "ㄷ": [4355, 12599], "ㄸ": [4356, 12600], "ㄹ": [4357, 12601], "ㅁ":[4358, 12609], "ㅂ": [4359, 12610], "ㅃ": [4360, 12611], "ㅅ": [4361, 12613], "ㅆ": [4362, 12614], "ㅇ": [4363, 12615], "ㅈ": [4364, 12616], "ㅉ": [4365, 12617], "ㅊ": [4366, 12618], "ㅋ": [4367, 12619], "ㅌ": [4368, 12620], "ㅍ": [4368, 12621], "ㅎ": [4370, 12622]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        if UIDevice.current.userInterfaceIdiom == .pad {
            collectionLayout.itemSize = CGSize(width: self.view.bounds.height/24.8, height: self.view.bounds.height/24.8)
        } else {
            collectionLayout.itemSize = CGSize(width: self.view.bounds.height/25, height: self.view.bounds.height/25)
        }
        collectionLayout.minimumLineSpacing = self.view.bounds.height/25
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: collectionLayout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = Texts.name.rawValue
        
        setFirestoreData(listIndex: listIndex)
        setConstraints()
        setNavigationBarItems()
    }
            
    override func viewWillDisappear(_ animated: Bool) {
        titleLabel.removeFromSuperview()
    }
    
    // MARK: Custom Method
    func setConstraints() {
        self.view.addSubview(collectionView)
        self.view.addSubview(tableView)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.snp.makeConstraints{ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.width.equalTo(self.view).multipliedBy(0.92)
                make.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.07)
            } else {
                make.width.equalTo(self.view)
                make.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.1)
            }
            make.centerX.equalTo(self.view)
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.snp.makeConstraints{ (make) in
            make.width.equalTo(self.view)
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.93)
            } else {
                make.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.9)
            }
            make.top.equalTo(self.collectionView.snp.bottom)
            make.centerX.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setNavigationBarItems() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        let targetView = self.navigationController?.navigationBar
        targetView?.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: (targetView?.centerXAnchor)!).isActive = true
        titleLabel.topAnchor.constraint(equalTo: (targetView?.topAnchor)!, constant: 10).isActive = true
        
        
        let buttonIcon = UIImage(named: "back")
        let buttonIconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 5, height: 5))
        let button = UIButton(frame: buttonIconSize)
        button.setBackgroundImage(buttonIcon, for: .normal)
        let barButton = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(popView(_:)), for: .touchUpInside)
        barButton.customView?.heightAnchor.constraint(equalToConstant: 15).isActive = true
        barButton.customView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        navigationItem.leftBarButtonItem = barButton
    }
    
    /// navigationController에서 pop하는 메소드
    @objc
    func popView(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
    
    // MARK: Firstore - read Data
    private func setFirestoreData(listIndex: Int) {
        let db = Firestore.firestore()
        db.collection(firestoreCollectionList[listIndex]).getDocuments() { (querySnapshot, err) in
            self.contactsData = []
            self.contactSectionTitles = []
            self.totalContactsKey = [:]
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.contactsData.append(document.data())
                }
                self.contactsData.sort{( $0["name"] as! String) < ($1["name"] as! String) }
            }
            for contact in self.contactsData {
                let contactName = contact["name"] as? String ?? ""
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
    
            self.tableView.reloadData()
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
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
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
}

// MARK: Extension
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firestoreCollectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.iconButton.setImage(UIImage(named: firestoreCollectionList[indexPath.row] + "_disable"), for: .normal)
        cell.iconButton.setImage(UIImage(named: firestoreCollectionList[indexPath.row] + "_enable"), for: .selected)
        cell.iconButton.imageView?.contentMode = .scaleAspectFit
        if indexPath.row == listIndex {
            cell.iconButton.isSelected = true
        } else {
            cell.iconButton.isSelected = false
        }
        cell.iconButton.addTarget(self, action: #selector(touchUpIconButton(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc
    func touchUpIconButton(_ sender: UIButton) {
        if sender.isSelected == false {
            for index in 0..<firestoreCollectionList.count {
                guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? CollectionViewCell else {
                    return
                }
                if cell.iconButton == sender {
                    setFirestoreData(listIndex: index)
                    cell.iconButton.isSelected = true
                } else {
                    cell.iconButton.isSelected = false
                }
            }
        } else {
            
        }
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering(){
            return 1
        } else {
            return contactSectionTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            return ""
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let number: Int = Int(round(UIScreen.main.bounds.width / 152))
                var blank = ""
                for _ in 1...number {
                    blank += " "
                }
                return blank + contactSectionTitles[section]
            } else {
                return contactSectionTitles[section]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        userContactsData = UserDefaults.standard.object(forKey: "userData") as? [[String : String]] ?? []
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else{
            return UITableViewCell()
        }
        cell.selectionStyle = .default
        let contactToDisplay:[String:Any]
        if isFiltering(){
            contactToDisplay = filteredContacts[indexPath.row]
            cell.textLabel?.text = contactToDisplay["name"] as? String ?? ""
        } else {
            let contactKey = contactSectionTitles[indexPath.section]
            if let contactValues = totalContactsKey[contactKey] {
                cell.textLabel?.text = contactValues[indexPath.row]["name"] as? String ?? ""
                let contactToString = contactValues as? [[String:String]] ?? []
                if userContactsData.contains(contactToString[indexPath.row]) {
                    cell.favoriteState = true
                } else {
                    cell.favoriteState = false
                }
                cell.changeStar(value: cell.favoriteState)
                cell.setUserDefaults(contacts: userContactsData, value: contactToString[indexPath.row])
            }
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentContact: [String:String] = [:]
        if isFiltering() {
            currentContact["name"] = filteredContacts[indexPath.row]["name"] as? String ?? ""
            currentContact["number"] = filteredContacts[indexPath.row]["number"] as? String ?? ""
        } else {
            currentContact["name"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["name"]) as? String ?? ""
            currentContact["number"] = (totalContactsKey[contactSectionTitles[indexPath.section]]?[indexPath.row]["number"]) as? String ?? ""
        }
        
        guard let number = URL(string: "tel://" + (currentContact["number"] ?? "")) else { return }
        UIApplication.shared.open(number)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DetailViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
