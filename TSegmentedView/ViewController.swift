//
//  ViewController.swift
//  TSegmentedView
//
//  Created by 邵伟男 on 2017/7/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import Masonry

class ViewController: UIViewController {
    var sview: TSegmentedView!
    var refreshCount: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        
        sview = TSegmentedView()
        self.view.addSubview(sview)
        sview.mas_makeConstraints { (make) in
            make!.edges.equalTo()(self.view)!.insets()(UIEdgeInsets.init(top: 64, left: 0, bottom: 0, right: 0))
        }
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
            return self.createTBView()
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
        return 100
    }
    
    func segmentedViewHeaderMinHeight(in segmentedView: TSegmentedView) -> CGFloat {
        return 20
    }
    
    
    func segmentedViewHeaderView(in segmentedView: TSegmentedView) -> UIView {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 350, height: 100))
        let label = UILabel()
        view.addSubview(label)
        label.mas_makeConstraints { (make) in
            make!.centerX.equalTo()(view.mas_centerX)
            make!.centerY.equalTo()(view.mas_centerY)
            make!.height.mas_equalTo()(20)
            make!.width.mas_equalTo()(300)
            //            make!.bottom.equalTo()(view.mas_bottom)!.offset()(-20)
            
        }
        label.text = "这是segmentedViewHeaderView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.brown
        
        return view
    }
    
    func createView() -> UIView {
        let view = UIView()
        let label = UILabel.init(frame: CGRect.init(x: 100, y: 100, width: 200, height: 100))
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
        view.mas_makeConstraints { (make) in
            make!.left.top().right().bottom().equalTo()(scView)
            make!.height.mas_equalTo()(900)
            make!.width.mas_equalTo()(UIScreen.main.bounds.width)
        }
        let label = UILabel.init(frame: CGRect.init(x: 100, y: 100, width: 200, height: 100))
        label.text = "这个是UIScrollView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.brown
        view.addSubview(label)
        return scView
    }
    
    func createTBView() -> UITableView {
        let tbView = UITableView()
        let hv = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
        hv.backgroundColor = UIColor.brown
        let label = UILabel()
        label.text = "这个是UITableView"
        label.textAlignment = .center
        label.backgroundColor = UIColor.red
        hv.addSubview(label)
        label.mas_makeConstraints { (make) in
            make!.centerX.equalTo()(hv.mas_centerX)
            make!.centerY.equalTo()(hv.mas_centerY)
            make!.height.mas_equalTo()(50)
            make!.width.mas_equalTo()(300)
        }
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "1") ?? UITableViewCell.init(style: .default, reuseIdentifier: "1")
        cell.textLabel?.text = "\(indexPath.section) - \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 30))
        label.text = "  第\(section)组"
        label.backgroundColor = UIColor.gray
        return label
    }
}




