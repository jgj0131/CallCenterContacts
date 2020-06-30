//
//  ACImageView.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/07/01.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit

class ACImageView: UIImageView {

    override func draw(_ rect: CGRect) {
        self.layer.borderColor = UIColor.black
        self.layer.borderWidth = 1
    }
}
