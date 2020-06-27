//
//  UnifiedNativeAdCell.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/06/08.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import GoogleMobileAds

class UnifiedNativeAdCell: UITableViewCell {
        
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var viewView: UIView!
    @IBOutlet weak var HeadlineLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var starRating: UILabel!
    @IBOutlet weak var adLavel: UILabel!
    @IBOutlet weak var advertiserLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var callToAction: UIButton!
    // MARK: Property
    static var identifier: String = "UnifiedNativeAdCell"
    
    // MARK: Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
}
