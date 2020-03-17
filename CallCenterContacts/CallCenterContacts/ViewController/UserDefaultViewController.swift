//
//  UserDefaultViewController.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/18.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit

class UserDefaultViewController: UIViewController {

    // MARK: UI Property
    lazy var tableView = UITableView()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setConstraints()
    }
    
    // MARK: Custom Method
    func setConstraints() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(self.view.safeAreaLayoutGuide)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: Extension
extension UserDefaultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
