//
//  AfterTableViewController.swift
//  KYNavigationFadeManager
//
//  Created by Kyle on 2017/6/28.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import KYNavigationFadeManager
import WZLBadge

open class AfterTableViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    var fadeManager : KYNavigationFadeManager!
    var searchBarView : CustomSearchBarView!

    var messageBarItem : UIBarButtonItem!

    public var shouldeHiddenTitle : Bool = true

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true;
        self.automaticallyAdjustsScrollViewInsets = false

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
        self.view.addSubview(self.tableView);
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[table]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["table":self.tableView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["table":self.tableView]))

        let headerView = UIImageView(frame: CGRect(x:0,y:0,width:0,height:200))
        headerView.image = UIImage(named:"header2")
        headerView.contentMode = .scaleAspectFill
        self.tableView.tableHeaderView = headerView


        let backBarItem = UIBarButtonItem(image: UIImage(named:"lx_common_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(TableViewController.buttonTapped(sender:)))
        self.navigationItem.leftBarButtonItem = backBarItem

        searchBarView = CustomSearchBarView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 28))
        searchBarView.searchBar.placeholder = "快速找直播、问答、直播达人";
        self.navigationItem.titleView = searchBarView;

        let mssageButton = UIButton()
        mssageButton.setImage(UIImage(named:"live_navi_message"), for: .normal)
        mssageButton.frame = CGRect(x: 0, y: 0, width: 38, height: 30)
        mssageButton.badgeCenterOffset = CGPoint(x:-10,y:8);
        mssageButton.badgeBgColor = UIColor(rgb:0xFD6D5E);
        self.messageBarItem = UIBarButtonItem(customView: mssageButton);

        let shareBarItem = UIBarButtonItem(image: UIImage(named:"lx_common_share")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(TableViewController.buttonTapped(sender:)))
        self.navigationItem.rightBarButtonItems = [shareBarItem,self.messageBarItem]

        self.fadeManager = KYNavigationFadeManager(viewController: self, scollView: self.tableView, zeroColor: UIColor(rgb:0xFFFFFF), fullColor: UIColor(rgb:0xFD6D5E))
        self.fadeManager.allowTitleHidden = shouldeHiddenTitle

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fadeManager.viewWillAppear(animated)
        self.fixNavigationBarCorruption()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        self.fadeManager.viewWillDisappear(animated)
        super .viewWillDisappear(animated)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buttonTapped(sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }

    deinit {
        print("TableViewController deinit")
    }


}


extension AfterTableViewController : UITableViewDelegate,UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")
        cell?.textLabel?.text = String(format: "%ld", arguments: [indexPath.row])
        cell?.imageView?.image = UIImage(color:  UIColor.black.withAlphaComponent(CGFloat(Float(indexPath.row)/Float(100))), size: CGSize(width: 20, height: 10))

        return cell!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = SecondViewController(nibName: nil, bundle: nil);
        vc.title = "二级"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension AfterTableViewController : KYNavigationFadeManagerDelegate {

    //custom bar item by yourself
    public func fadeManagerBarItemColorChange(_ manager: KYNavigationFadeManager, barItem: UIBarButtonItem, alpha: CGFloat) -> Bool {

        if barItem == self.messageBarItem {
            return true
        }
        return false;
    }
}

