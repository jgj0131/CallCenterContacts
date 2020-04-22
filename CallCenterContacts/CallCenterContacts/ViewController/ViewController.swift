//
//  ViewController.swift
//  CallCenterContacts
//
//  Created by jang gukjin on 2020/03/15.
//  Copyright © 2020 jang gukjin. All rights reserved.
//

import UIKit
import SnapKit
import Intents

class ViewController: UIViewController {

    // MARK: UI Property
    lazy var tableView = UITableView()
    
    // MARK: Property
    let contactsList = ["긴급", "금융", "문화", "민원", "부동산", "쇼핑", "안보", "여행", "의료", "추가등록"]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        INPreferences.requestSiriAuthorization { (status) in
            if status == .authorized {
                print("Siri access allowed")
            } else {
                print("Siri access denied")
            }
        }
        
        SiriDataManager.sharedManager.saveContacts(contacts: UserDefaults.standard.object(forKey: "userData") as? [[String : String]] ?? [])
                
        setConstraints()
    }
    
    // MARK: Custom Method
    func setConstraints() {
        self.view.addSubview(tableView)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.snp.makeConstraints{ (make) in
            make.width.height.equalTo(self.view.safeAreaLayoutGuide)
            make.center.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

// MARK: Extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contactsList[indexPath.row]
        if cell.textLabel?.text == "긴급" {
            cell.textLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .label
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == contactsList.count - 1{
            let userDefaultViewontroller = UserDefaultViewController()
            navigationController?.pushViewController(userDefaultViewontroller, animated: true)
        } else {
            let detailViewontroller = DetailViewController()
            detailViewontroller.listIndex = indexPath.row
            navigationController?.pushViewController(detailViewontroller, animated: true)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
