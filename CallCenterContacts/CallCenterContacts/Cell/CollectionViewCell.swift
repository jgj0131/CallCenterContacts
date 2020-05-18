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
    lazy var iconButton = UIButton()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setConstraint()
    }
    
    // MARK: Custom Method
    func setConstraint() {
        self.contentView.addSubview(iconButton)
        
        iconButton.setImage(UIImage(named: "emergency_disable"), for: .normal)
//        imageView.layer.borderWidth = 0
//        imageView.layer.borderColor = UIColor.label.cgColor
        iconButton.snp.makeConstraints{ (make) in
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
        iconButton.setImage(nil, for: .normal)
        iconButton.setImage(nil, for: .selected)
    }
}
