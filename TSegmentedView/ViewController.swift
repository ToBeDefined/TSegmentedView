//
//  ViewController.swift
//  TSegmentedView
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    enum HeaderViewType {
        case topFixed
        case centerFixed
        case bottomFixed
    }
    var sview: TSegmentedView!
    var refreshCount: Int = 0
    var headerViewType: HeaderViewType = .centerFixed
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        
        sview = TSegmentedView()
        self.view.addSubview(sview)
        sview.tsv_makeConstraints([.left, .bottom, .right], equalTo: self.view)
        sview.tsv_makeConstraint(.top, equalTo: self.view, multiplier: 1.0, constant: 64)
        sview.delegate = self
        sview.reloadData()
        
        let barItem = UIBarButtonItem.init(barButtonSystemItem: .refresh,
                                           target: self,
                                           action: #selector(self.reloadSviewData))
        self.navigationItem.rightBarButtonItem = barItem
    }
    
    @objc func reloadSviewData() {
        self.refreshCount += 1
        self.sview.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension ViewController: TSegmentedViewDelegate {
    func segmentedViewTitles(in segmentedView: TSegmentedView) -> [String] {
        if self.refreshCount == 0 {
            return ["第一页", "第二页", "第三页"]
        } else {
            return ["第一页", "第二页", "第三页", "第\(self.refreshCount)刷"]
        }
    }
    
    func segmentedView(_ view: TSegmentedView, viewForIndex index: Int) -> UIView {
        switch index {
        case 0:
            return self.createView()
        case 1:
            return self.createScrollView()
        default:
            return self.createTableView()
        }
    }
    
    func segmentedViewSegmentedControlView(in segmentedView: TSegmentedView) -> UIView {
        let sc = TSegmentedControlView()
        return sc
    }
    
    func segmentedViewFirstStartSelectIndex(in segmentedView: TSegmentedView) -> Int {
        return 1
    }
    
    func segmentedViewHeaderMaxHeight(in segmentedView: TSegmentedView) -> CGFloat {
        return 150
    }
    
    func segmentedViewHeaderMinHeight(in segmentedView: TSegmentedView) -> CGFloat {
        return 60
    }
    
    
    func segmentedViewHeaderView(in segmentedView: TSegmentedView) -> UIView {
        let maxHeight = self.segmentedViewHeaderMaxHeight(in: sview)
        let minHeight = self.segmentedViewHeaderMinHeight(in: sview)
        let view = UIView.init(frame: CGRect.init(x: 0,
                                                  y: 0,
                                                  width: 350,
                                                  height: maxHeight))
        view.backgroundColor = UIColor.gray
        view.layer.masksToBounds = true
        
        let label  = UILabel()
        view.addSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor.brown
        label.text = "灰色的是segmentedViewHeaderView\n这是内部的label"
        switch self.headerViewType {
        case .topFixed:
            label.tsv_makeConstraint(.top, equalTo: view)
        case .centerFixed:
            label.tsv_makeConstraint(.centerY, equalTo: view)
        case .bottomFixed:
            label.tsv_makeConstraint(.bottom, equalTo: view)
        }
        label.tsv_makeConstraint(.centerX, equalTo: view)
        label.tsv_makeConstraint(.width, is: 300)
        label.tsv_makeConstraint(.height, is: minHeight)
        
        return view
    }
}

// MARK: Create View
extension ViewController {
    func createView() -> UIView {
        let view = UIView()
        let label = UILabel.init(frame: CGRect.init(x: 100,
                                                    y: 100,
                                                    width: 200,
                                                    height: 100))
        label.text = "这个是UIView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.brown
        view.addSubview(label)
        return view
    }
    
    func createScrollView() -> UIScrollView {
        let scView = UIScrollView()
        let view = UIView()
        view.backgroundColor = UIColor.blue
        scView.addSubview(view)
        view.tsv_makeConstraints([.left, .top, .right, .bottom], equalTo: scView)
        view.tsv_makeConstraint(.height, is: 900)
        view.tsv_makeConstraint(.width, is: UIScreen.main.bounds.width)
        let label = UILabel.init(frame: CGRect.init(x: 100,
                                                    y: 100,
                                                    width: 200,
                                                    height: 100))
        label.text = "这个是UIScrollView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.brown
        view.addSubview(label)
        return scView
    }
    
    func createTableView() -> UITableView {
        let tbView = UITableView()
        let hv = UIView.init(frame: CGRect.init(x: 0,
                                                y: 0,
                                                width: UIScreen.main.bounds.width,
                                                height: 120))
        hv.backgroundColor = UIColor.brown
        let label = UILabel()
        label.text = "这个是UITableView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.red
        hv.addSubview(label)
        label.tsv_makeConstraints([.centerX, .centerY], equalTo: hv)
        label.tsv_makeConstraint(.height, is: 50)
        label.tsv_makeConstraint(.width, is: 300)
        
        tbView.tableHeaderView = hv
        tbView.delegate = self
        tbView.dataSource = self
        tbView.reloadData()
        return tbView
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = "\(indexPath.section) - \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 0,
                                                    y: 0,
                                                    width: 100,
                                                    height: 30))
        label.text = "  第\(section)组"
        label.backgroundColor = UIColor.gray
        return label
    }
}




