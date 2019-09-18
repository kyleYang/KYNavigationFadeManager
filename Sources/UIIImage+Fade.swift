//
//  UIIImage+Fade.swift
//  KYNavigationFadeManager_Example
//
//  Created by Kyle on 2019/9/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

// MARK: Category UIImage
extension UIImage {
    //create a pure image with color
    public static func createImage(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        var rect = CGRect(origin: .zero, size: size)
        if #available(iOS 11.0, *) {
        } else {
            rect = CGRect(origin: .zero, size: CGSize(width: size.width, height: 64))
        }
        
        UIGraphicsBeginImageContext(rect.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let text = UIGraphicsGetCurrentContext()
        guard let context = text else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    //change the color of image
    func kyImageWithColor(color: UIColor) -> UIImage? {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
