//
//  EditTableViewCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/18.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit

class EditTableViewCell: UITableViewCell {

    // MARK: UI Property
    lazy var insertButton = UIButton(type: .contactAdd)
    lazy var editButton = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
    
    func setConstraint() {
        self.contentView.addSubview(insertButton)
        self.contentView.addSubview(editButton)
        
        insertButton.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(10)
        }
        
        editButton.titleLabel?.text = "Edit"
        editButton.snp.makeConstraints{ (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-10)
        }
    }

}
