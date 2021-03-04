//
//  TableViewCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/04/07.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit

class TableViewCell: UITableViewCell {

    // MARK: UI Property
    lazy var favoriteStarButton = UIButton()
    lazy var homepageButton = UIButton()
    
    // MARK: Property
    static var identifier: String = "TableViewCell"
    var favoriteState = false
    private var favoriteContact: [String:String] = [:]
    private var favoriteContacts: [[String:String]] = []
    
    // MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraint()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Override Method
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: Custom Method
    func setConstraint() {
        self.contentView.addSubview(favoriteStarButton)
        self.contentView.addSubview(homepageButton)
        
        if favoriteState == false {
            favoriteStarButton.setImage(UIImage(named: "favorite_off"), for: .normal)
        } else {
            favoriteStarButton.setImage(UIImage(named: "greenStar"), for: .normal)
        }
        favoriteStarButton.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self)
            make.width.height.equalTo(self.snp.height).multipliedBy(0.45)
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.right.equalTo(self).multipliedBy(0.945)
            } else {
                make.right.equalTo(self).multipliedBy(0.9)
            }
        }
        favoriteStarButton.addTarget(self, action:#selector(touchUpFavorite(_:)), for: .touchUpInside)
        
        homepageButton.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(self.snp.height).multipliedBy(0.45)
            make.width.equalTo(self.homepageButton.snp.height).multipliedBy(1.12)
            make.right.equalTo(self.favoriteStarButton.snp.left).multipliedBy(0.95)
        }
        homepageButton.addTarget(self, action: #selector(touchUpHomePage(_:)), for: .touchUpInside)
        
        textLabel?.font = UIFont(name: "NotoSansKR-Regular", size: UIScreen.main.bounds.width * 0.045)
        textLabel?.font = textLabel?.font.withSize(UIScreen.main.bounds.width * 0.045)
        textLabel?.adjustsFontSizeToFitWidth = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            textLabel?.textAlignment = .left
            textLabel?.snp.makeConstraints{ (make) in
                make.centerY.equalTo(self.contentView)
                make.left.equalTo(self).offset(UIScreen.main.bounds.width / 22)
            }
        }
    }
    
    /// favoriteState에 따라 별 색깔을 다르게하는 메소드
    func changeStar(value: Bool) {
        if value == true {
            favoriteStarButton.setImage(UIImage(named: "greenStar"), for: .normal)
        } else {
            favoriteStarButton.setImage(UIImage(named: "favorite_off"), for: .normal)
        }
    }
    
    /// 받은 값을 Userdefaults에 저장하는 메소드
    func setUserDefaults(contacts: [[String:Any]], value: [String:Any]) {
        favoriteContacts = contacts as? [[String:String]] ?? []
        favoriteContact = value as? [String:String] ?? [:]
        DispatchQueue.main.async {
            if self.favoriteContact["address"] != nil {
                self.homepageButton.setImage(UIImage(named: "homepage_enable"), for: .normal)
            } else {
                self.homepageButton.setImage(UIImage(named: "homepage_disable"), for: .normal)
            }
        }
    }
    
    @objc
    func touchUpFavorite(_ sender: UIButton) {
        favoriteState = !favoriteState
        if favoriteState == true {
            changeStar(value: favoriteState)
            if !favoriteContacts.contains(favoriteContact) {
                favoriteContacts.append(favoriteContact)
                UserDefaults.standard.set(favoriteContacts, forKey: "userData")
            }
        } else {
            changeStar(value: favoriteState)
            if favoriteContacts.contains(favoriteContact) {
                if let index = favoriteContacts.firstIndex(of: favoriteContact) {
                    favoriteContacts.remove(at: index)
                }
                UserDefaults.standard.set(favoriteContacts, forKey: "userData")
            }
        }
    }
    
    @objc
    func touchUpHomePage(_ sender: UIButton) {
        if homepageButton.currentImage == UIImage(named: "homepage_enable") {
            guard let url = URL(string: favoriteContact["address"] ?? "") else { return }
            UIApplication.shared.open(url)
        }
    }
}
