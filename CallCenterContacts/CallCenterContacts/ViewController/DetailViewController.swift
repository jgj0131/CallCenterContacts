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
import GoogleMobileAds

class DetailViewController: UIViewController {
    
    // MARK: UI Property
    lazy var collectionView = UICollectionView()
    lazy var tableView = UITableView()
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = Texts.title.rawValue
        title.textColor = .white
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    var bannerView: GADBannerView!
    
    // MARK: Property
    var adLoader: GADAdLoader?
    var nativeAds = [GADUnifiedNativeAd]()
    var nativeAdView: GADUnifiedNativeAdView!
    let adUnitID =  Keys.nativeTestID.rawValue
    let firestoreCollectionList = ["emergency", "finance", "culture", "civil complaint", "real property", "shopping", "security", "travel", "medical"]
    var listIndex = 0
    private var  contactsData: [[String:Any]] = []
    private var  userContactsData: [[String:String]] = []
    let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = true
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
    private var filteredContacts = [[String:Any]]()
    private var contactSectionTitles = [String]()
    private var totalContactsKey = [String:[[String:Any]]]()
    let prefixs: [String:[UInt32]] = ["ㄱ": [4352, 12593], "ㄲ": [4353, 12594], "ㄴ": [4354, 12596], "ㄷ": [4355, 12599], "ㄸ": [4356, 12600], "ㄹ": [4357, 12601], "ㅁ":[4358, 12609], "ㅂ": [4359, 12610], "ㅃ": [4360, 12611], "ㅅ": [4361, 12613], "ㅆ": [4362, 12614], "ㅇ": [4363, 12615], "ㅈ": [4364, 12616], "ㅉ": [4365, 12617], "ㅊ": [4366, 12618], "ㅋ": [4367, 12619], "ㅌ": [4368, 12620], "ㅍ": [4368, 12621], "ㅎ": [4370, 12622]]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let collectionLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                collectionLayout.itemSize = CGSize(width: self.view.bounds.height/18.6, height: self.view.bounds.height/18.6)
            } else {
                collectionLayout.itemSize = CGSize(width: self.view.bounds.width/18.6, height: self.view.bounds.width/18.6)
            }
        } else {
            collectionLayout.itemSize = CGSize(width: self.view.bounds.height/25, height: self.view.bounds.height/25)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation.isLandscape {
                collectionLayout.minimumLineSpacing = self.view.bounds.height/18.6
            } else {
                collectionLayout.minimumLineSpacing = self.view.bounds.width/18.6
            }
        } else {
            collectionLayout.minimumLineSpacing = self.view.bounds.height/25
        }
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: collectionLayout)
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = Keys.detailViewBannerAdID.rawValue
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        bannerView.delegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        
        self.searchController.searchResultsUpdater = self
        
        setFirestoreData(listIndex: listIndex)
        setConstraints()
        setGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBarItems()
    }
            
    override func viewWillDisappear(_ animated: Bool) {
//        titleLabel.removeFromSuperview()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: self.listIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: Constraints
    func setConstraints() {
        self.view.addSubview(collectionView)
        self.view.addSubview(tableView)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        collectionView.allowsSelection = true
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
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = Texts.title.rawValue        
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
    
    func setGesture() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(recognizer:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(recognizer:)))
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        
        tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    // MARK: Custom Method
    @objc
    func handleSwipeLeft(recognizer: UISwipeGestureRecognizer) {
        if listIndex == firestoreCollectionList.count - 1 {
            listIndex = 0
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        } else {
            listIndex += 1
        }
        setFirestoreData(listIndex: listIndex)
        guard let cell = collectionView.cellForItem(at: IndexPath(row: listIndex, section: 0)) as? CollectionViewCell else {
            return
        }
        cell.iconImage.image = UIImage(named: firestoreCollectionList[listIndex] + "_enable")
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: listIndex, section: 0), at: .centeredHorizontally, animated: true)
        
//        if listIndex == 0 {
//            navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 100/255, blue: 78/255, alpha: 1)
//        } else {
//            navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 171/255, blue: 142/255, alpha: 1)
//        }
    }
    
    @objc
    func handleSwipeRight(recognizer: UISwipeGestureRecognizer) {
        if listIndex == 0 {
            listIndex = firestoreCollectionList.count - 1
            collectionView.scrollToItem(at: IndexPath(row: firestoreCollectionList.count - 1, section: 0), at: .right, animated: true)
        } else {
            listIndex -= 1
        }
        setFirestoreData(listIndex: listIndex)
        guard let cell = collectionView.cellForItem(at: IndexPath(row: listIndex, section: 0)) as? CollectionViewCell else {
            return
        }
        cell.iconImage.image = UIImage(named: firestoreCollectionList[listIndex] + "_enable")
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: listIndex, section: 0), at: .centeredHorizontally, animated: true)
        
//        if listIndex == 0 {
//            navigationController?.navigationBar.barTintColor = UIColor(red: 1, green: 100/255, blue: 78/255, alpha: 1)
//        } else {
//            navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 171/255, blue: 142/255, alpha: 1)
//        }
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

// MARK: Extension - CollectionView
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firestoreCollectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.iconImage.image = UIImage(named: firestoreCollectionList[indexPath.row] + "_disable")
        cell.imageName = firestoreCollectionList[indexPath.row] + "_disable"
        cell.iconImage.contentMode = .scaleAspectFit
        if indexPath.row == listIndex {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
            cell.iconImage.image = UIImage(named: firestoreCollectionList[indexPath.row] + "_enable")
        } else {
            cell.iconImage.image = UIImage(named: firestoreCollectionList[indexPath.row] + "_disable")
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setFirestoreData(listIndex: indexPath.row)
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
            return
        }
        listIndex = indexPath.row
        cell.iconImage.image = UIImage(named: firestoreCollectionList[indexPath.row] + "_enable")
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {
            return
        }
        cell.iconImage.image = UIImage(named: firestoreCollectionList[indexPath.row] + "_disable")
    }
}

//extension DetailViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return CGSize(width: self.view.bounds.width/18.6, height: self.view.bounds.width/18.6)
//        } else {
//            return CGSize(width: self.view.bounds.height/25, height: self.view.bounds.height/25)
//        }
//    }
//}

// MARK: Extension - TableView
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 17
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
            let contactToStringDisplay = contactToDisplay as? [String:String] ?? [:]
            cell.textLabel?.text = contactToDisplay["name"] as? String ?? ""
            if userContactsData.contains(contactToStringDisplay) {
                cell.favoriteState = true
            } else {
                cell.favoriteState = false
            }
            cell.changeStar(value: cell.favoriteState)
            cell.setUserDefaults(contacts: userContactsData, value: contactToStringDisplay)
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
        cell.textLabel?.snp.makeConstraints{ (make) in
            make.centerY.equalTo(cell)
            make.height.equalTo(cell)
            make.left.equalTo(cell).offset(UIScreen.main.bounds.width / 22)
            make.right.equalTo(cell.homepageButton.snp.left)
        }
        cell.separatorInset = .zero
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

// MARK: Extension - BannerAd
extension DetailViewController: GADBannerViewDelegate {
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
