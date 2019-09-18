//
//  TableViewController.swift
//  KYNavigationFadeManager
//
//  Created by Kyle on 2017/5/8.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

open class TableViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)
    var fadeManager : KYNavigationFadeManager!
    
    var shareButton : UIButton!
    var backButton : UIButton!
    var backBarItem : UIBarButtonItem!

    public var shouldeHiddenTitle : Bool = true

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true;
        self.automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
        self.view.addSubview(self.tableView);
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[table]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["table":self.tableView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[table]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["table":self.tableView]))

        let headerView = UIImageView(frame: CGRect(x:0,y:0,width:0,height:200))
        headerView.image = UIImage(named:"header")
        headerView.contentMode = .scaleAspectFill
        self.tableView.tableHeaderView = headerView
        
        self.backButton = UIButton()
        self.backButton.setImage(UIImage(named:"navigationBar_back"), for: .normal)
        self.backButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        self.backButton.addTarget(self, action: #selector(TableViewController.buttonTapped(sender:)), for: .touchUpInside)
        self.backBarItem = UIBarButtonItem(customView: self.backButton);
        self.navigationItem.leftBarButtonItem = self.backBarItem

        self.shareButton = UIButton()
        self.shareButton.setImage(UIImage(named:"navi_collect"), for: .normal)
        self.shareButton.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        let shareBarItem = UIBarButtonItem(customView: self.shareButton);

        self.navigationItem.rightBarButtonItems = [shareBarItem]

        self.fadeManager = KYNavigationFadeManager(viewController: self, scollView: self.tableView)
        self.fadeManager.allowTitleHidden = shouldeHiddenTitle
        self.fadeManager.zeroAlphaOffset = 0;
        self.fadeManager.fullAlphaOffset = 200;

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fadeManager.viewWillAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        self.fadeManager.viewWillDisappear(animated)
        super .viewWillDisappear(animated)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func buttonTapped(sender: UIButton) {

        self.dismiss(animated: true) { 

        };
    }

    deinit {
        print("TableViewController deinit")
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if (self.fadeManager != nil && self.fadeManager.state == .faded) {
            return .lightContent;
        }
        return .default;
    }

}


extension TableViewController : UITableViewDelegate,UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")
        cell?.textLabel?.text = String(format: "%ld", arguments: [indexPath.row])
        return cell!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let vc = AfterTableViewController(nibName: nil, bundle: nil);
        vc.title = "下一个"
        self.navigationController?.pushViewController(vc, animated: true)
    }


}


extension TableViewController : KYNavigationFadeManagerDelegate {
    
    public func fadeManagerBarItemColorChange(_ manager: KYNavigationFadeManager, barItem: UIBarButtonItem, alpha: CGFloat) -> Bool {
        
        if (barItem == self.backBarItem) {
            return false
        }
        
        if (alpha > 0.3) {
            self.shareButton.setImage(UIImage(named:"navi_collect"), for: .normal)
        }else {
            self.shareButton.setImage(UIImage(named:"navi_collect_fade"), for: .normal)
        }
        
        return true
    }
    
    public func fadeManager(_ manager: KYNavigationFadeManager, changeState: KYNavigationFadeState) {
         self.setNeedsStatusBarAppearanceUpdate()
    }
}


