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

        let backBarItem = UIBarButtonItem(image: UIImage(named:"lx_common_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(SecondViewController.buttonTapped(sender:)))
        self.navigationItem.leftBarButtonItem = backBarItem

        let imageView = UIImageView(frame: CGRect(x:0,y:0,width:0,height:0))
        imageView.image = UIImage(named:"bgimage")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func buttonTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true);
    }
    
}
