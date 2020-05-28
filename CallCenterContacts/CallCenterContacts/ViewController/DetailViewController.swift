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
        title.textColor = .label
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    // MARK: Property
    var adLoader: GADAdLoader!
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
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5

        adLoader = GADAdLoader(adUnitID: Keys.adUnitID.rawValue, rootViewController: self,
            adTypes: [GADAdLoaderAdType.unifiedNative],
            options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
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
        setGesture()
    }
            
    override func viewWillDisappear(_ animated: Bool) {
        titleLabel.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: self.listIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: Custom Method
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
    
    func setGesture() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(recognizer:)))
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(recognizer:)))
        leftSwipeGestureRecognizer.direction = .left
        rightSwipeGestureRecognizer.direction = .right
        
        tableView.addGestureRecognizer(leftSwipeGestureRecognizer)
        tableView.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
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

extension DetailViewController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
    
    // MARK: Google Mobile Ads
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
      print("Received unified native ad: \(nativeAd)")
//      refreshAdButton.isEnabled = true
      // Create and place ad in view hierarchy.
      let nibView = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil)?.first
      guard let nativeAdView = nibView as? GADUnifiedNativeAdView else {
        return
      }
//      setAdView(nativeAdView)
        self.tableView.addSubview(nativeAdView)

      // Associate the native ad view with the native ad object. This is
      // required to make the ad clickable.
      nativeAdView.nativeAd = nativeAd

      // Set the mediaContent on the GADMediaView to populate it with available
      // video/image asset.
      nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

      // Populate the native ad view with the native ad assets.
      // The headline is guaranteed to be present in every native ad.
      (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

      // These assets are not guaranteed to be present. Check that they are before
      // showing or hiding them.
      (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
      nativeAdView.bodyView?.isHidden = nativeAd.body == nil

      (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
      nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

      (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
      nativeAdView.iconView?.isHidden = nativeAd.icon == nil

//      (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:nativeAd.starRating)
      nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

      (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
      nativeAdView.storeView?.isHidden = nativeAd.store == nil

      (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
      nativeAdView.priceView?.isHidden = nativeAd.price == nil

      (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
      nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

      // In order for the SDK to process touch events properly, user interaction
      // should be disabled.
      nativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad was shown.
    }

    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad was clicked on.
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will present a full screen view.
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will dismiss a full screen view.
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad did dismiss a full screen view.
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
      // The native ad will cause the application to become inactive and
      // open a new application.
    }
}
