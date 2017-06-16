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

        self.navigationBar.setBackgroundImage(UIImage.pureImage(color: UIColor.green), for: .default)
        self.navigationBar.shadowImage = UIImage();
        self.navigationBar.barTintColor = UIColor.white;
        self.navigationBar.tintColor = UIColor.white;

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
