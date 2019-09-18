//
//  ViewController.swift
//  KYNavigationFadeManager
//
//  Created by kyleYang on 05/06/2017.
//  Copyright (c) 2017 kyleYang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var tableView: UITableView!

    fileprivate let titleArray : [String] = ["透明无title","透明有title"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tablecell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")
        cell?.textLabel?.text = titleArray[indexPath.row]
        if(indexPath.row == 0){
             cell?.imageView?.image = UIImage(named:"lx_common_share")
        }else if (indexPath.row == 1){
            cell?.imageView?.image = UIImage(named:"lx_common_share")?.imageWithColor(color: UIColor.green)
        }else if (indexPath.row == 2){
            cell?.imageView?.image = UIImage(named:"lx_common_share")?.imageWithColor(color: UIColor.green)
        }else{
            cell?.imageView?.image = UIImage(named:"lx_common_share")?.imageWithColor(color: UIColor(patternImage:UIImage(named:"lx_common_share")!).withAlphaComponent(1))
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.row == 0){

            let vc = TableViewController(nibName: nil, bundle: nil);
            vc.title = "透明无title"
            vc.shouldeHiddenTitle = true
            let navi = NavigationViewController(rootViewController: vc)
            self.present(navi, animated: true, completion: { 

            });

        }else if (indexPath.row == 1){
            let vc = TableViewController(nibName: nil, bundle: nil);
            vc.title = "透明有title"
            vc.shouldeHiddenTitle = false
            let navi = NavigationViewController(rootViewController: vc)
            self.present(navi, animated: true, completion: {

            });

        }
        
    }
}


extension UIImage{

    class func pureImage(color : UIColor,size : CGSize? = nil)->UIImage{
        var rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        if let _ = size {
            rect.size = size!
        }

        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
        
    }


    func imageWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}



fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}


extension UIColor{

    func changeAlpah(_ alpha : CGFloat) -> UIColor {

        let cgColor = self.cgColor
        let numComponents = cgColor.numberOfComponents

        var newColor : UIColor!

        if (numComponents == 4){
            let components = cgColor.components!
            let red = components[0]
            let green = components[1]
            let blue = components[2]
            newColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            return newColor

        }else if(numComponents == 2){
            let components = cgColor.components!
            let white = components[0]
            newColor = UIColor(white: white, alpha: alpha)
            return newColor
        }

        return self
    }


    convenience init(red: Int, green: Int, blue: Int, alpha: Float? = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0.0 && alpha <= 1.0, "Invalid alpha component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha!))
    }

    convenience init(rgb: UInt32,alpha: Float? = 1.0) {
        self.init(
            red: Int(rgb >> 16) & 0xff,
            green: Int(rgb >> 8) & 0xff,
            blue: Int(rgb) & 0xff,
            alpha:alpha
        )
    }

    convenience init(rgba: UInt32) {
        self.init(
            red: Int(rgba >> 24) & 0xff,
            green: Int(rgba >> 16) & 0xff,
            blue: Int(rgba >> 8) & 0xff,
            alpha: Float(rgba & 0xff) / 255.0
        )
    }
}
