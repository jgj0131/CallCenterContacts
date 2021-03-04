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
import GoogleMobileAds

class ViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate {

    // MARK: UI Property
    lazy var tableView = UITableView()
    private var bannerView: GADBannerView!
    
    // MARK: Property
    let contactsList = ["긴급", "금융", "문화", "민원", "부동산", "쇼핑", "안보", "여행", "의료", "추가등록"]
    let firestoreCollectionList = ["emergency", "finance", "culture", "civil complaint", "real property", "shopping", "security", "travel", "medical"]
    let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.hidesNavigationBarDuringPresentation = true
        search.definesPresentationContext = true
        search.searchBar.placeholder = Texts.name.rawValue
        if let textfield = search.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = .systemBackground
            textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.secondaryLabel])
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = .secondaryLabel
            }
        }
        return search
    }()
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
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = Keys.bannerAdID.rawValue
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
        
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
    
    // MARK: Constraints
    func setConstraints() {
        self.view.addSubview(tableView)
        
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.snp.makeConstraints{ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.left.right.bottom.equalTo(self.view)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setNavigationBarItems() {
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.showsLargeContentViewer = true
//        navigationController?.navigationBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
//        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = Texts.title.rawValue
//        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 171/255, blue: 142/255, alpha: 1)
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(red: 0, green: 171/255, blue: 142/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
//        DispatchQueue.main.async {
//            self.tableView.performBatchUpdates({
//                self.tableView.reloadData()
//            }, completion: nil)
//        }
    }
    
    // MARK: Life Cycle
    /// firestore 데이터를 읽어오는 메소드
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
    
    /// 초성 분리 메소드
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

// MARK: Extension - TableView
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
        cell.separatorInset = .zero
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

// MARK: Extension- UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: Extension - GADBannerAd
extension ViewController: GADBannerViewDelegate {
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        } else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
      
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide.topAnchor,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
     }

    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
          bannerView.alpha = 1
        })
        addBannerViewToView(bannerView)
        print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
