//
//  SecondViewController.swift
//  KYNavigationFadeManager
//
//  Created by Kyle on 2017/5/9.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    deinit {
        print("SecondViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        // Do any additional setup after loading the view.
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
