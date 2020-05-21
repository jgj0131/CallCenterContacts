//
//  CollectionViewCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/05/16.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    // MARK: Property
    static var identifier: String = "CollectionViewCell"

    // MARK: UI Property
    lazy var iconImage = UIImageView()
    
    // MARK: Property
    var imageName = "emergency_disable"
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraint()
    }
    
    // MARK: Custom Method
    func setConstraint() {
        self.contentView.addSubview(iconImage)
        
        iconImage.image = UIImage(named: "emergency_disable")
        iconImage.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self.contentView)
            make.width.equalTo(self)
            make.height.equalTo(self)
            make.top.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImage.image = UIImage(named: imageName)
    }
}
