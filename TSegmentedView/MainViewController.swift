//
//  MainViewController.swift
//  TSegmentedView
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
}

// MARK: Delegate & DataSource
extension MainViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "顶部View上方固定"
        case 1:
            cell.textLabel?.text = "顶部View居中"
        default:
            cell.textLabel?.text = "顶部View一同移动"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ViewController()
        switch indexPath.row {
        case 0:
            vc.headerViewType = .topFixed
            vc.title = "顶部View上方固定"
        case 1:
            vc.headerViewType = .centerFixed
            vc.title = "顶部View居中"
        default:
            vc.headerViewType = .bottomFixed
            vc.title = "顶部View一同移动"
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


