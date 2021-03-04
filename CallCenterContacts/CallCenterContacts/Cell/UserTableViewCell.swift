//
//  UserTableViewCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2021/03/04.
//  Copyright © 2021 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit

class UserTableViewCell: UITableViewCell {

    // MARK: UI Property
    lazy var editButton: EditButton = {
        let button = EditButton()
        button.setImage(UIImage(named: "edit"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    // MARK: Property
    static var identifier: String = "UserTableViewCell"
    
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
        self.contentView.addSubview(editButton)
        
        editButton.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self)
            make.width.height.equalTo(self.snp.height).multipliedBy(0.45)
            if UIDevice.current.userInterfaceIdiom == .pad {
                make.right.equalTo(self).multipliedBy(0.945)
            } else {
                make.right.equalTo(self).multipliedBy(0.9)
            }
        }
        
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
}

class EditButton: UIButton {
    var section: Int?
    var row: Int?
}
