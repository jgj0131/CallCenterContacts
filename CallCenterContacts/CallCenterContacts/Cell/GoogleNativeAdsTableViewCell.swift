//
//  GoogleNativeAdsTableViewCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/06/06.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds

class GoogleNativeAdTableViewCell: UITableViewCell {

    // MARK: UI Property
//    lazy var googleNativeAds = GADUnifiedNativeAdView()
    lazy var iconView = UIImageView()
    lazy var headlineLabel = UILabel()
    lazy var bodyLabel = UILabel()
    lazy var starRating = UILabel()
    lazy var adLavel = UILabel()
    lazy var advertiserLabel = UILabel()
    lazy var priceLabel = UILabel()
    lazy var callToAction = UIButton()
    
    // MARK: Property
    static var identifier: String = "GoogleNativeAdsTableViewCell"
    
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
        self.contentView.addSubview(iconView)
        self.contentView.addSubview(headlineLabel)
        self.contentView.addSubview(adLavel)
        
        adLavel.snp.makeConstraints{ (make) in
            make.left.top.equalTo(self)
            make.width.height.equalTo(self.snp.height).multipliedBy(0.5)
        }
        
        iconView.snp.makeConstraints{ (make) in
            make.left.equalTo(self.adLavel.snp.right).offset(5)
            make.centerY.equalTo(self)
            make.width.height.equalTo(self.snp.height).multipliedBy(0.9)
        }
        
        headlineLabel.textColor = .label
        headlineLabel.snp.makeConstraints{ (make) in
            make.left.equalTo(self.iconView.snp.right).offset(5)
            make.centerY.equalTo(self)
        }
    }
}
