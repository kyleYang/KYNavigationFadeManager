//
//  NavigationViewController.swift
//  KYNavigationFadeManager
//
//  Created by Kyle on 2017/5/9.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage.pureImage(color: UIColor(rgb:0xFFFFFF)), for: .default)
        self.navigationBar.shadowImage = UIImage();
        self.navigationBar.barTintColor = UIColor.white;
        self.navigationBar.tintColor = UIColor.white;

        self.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor:UIColor(rgb:0x333333)]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let viewController = self.topViewController {
            return viewController.preferredStatusBarStyle
        }
        return .default
    }
}
