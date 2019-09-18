//
//  KYNavigationFadeManager+Private.swift
//  KYNavigationFadeManager_Example
//
//  Created by Kyle on 2019/9/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

//private method
extension KYNavigationFadeManager {
    
    // MARK: store or recover the navigationbar
    // store the origin value
    func storeOriginValues() {
        
        self.shadowImage = self.navigationBar?.shadowImage
        self.isTranslucent = self.navigationBar?.isTranslucent
        self.tintColor = self.navigationBar?.tintColor
        self.barTintColor = self.navigationBar?.barTintColor
        
        self.backgroundImage = self.navigationBar?.backgroundImage(for: .default)
        //        self.barBackgroundColor = self.navigationBar.backgroundColor;
        if let image = self.backgroundImage {
            let color = UIColor(patternImage: image)
            self.barColor = color
        }
    }
    
    // MARK: private method
    func didScroll(fadeBackground : Bool? = true) {
        
        if !self.isObservable {
            return
        }
        
        let offset = self.scrollView.contentOffset
        let currentAlpha = self.calculatAlpha(offset.y)
        
        if self.currentAlphaValue == currentAlpha {
            return
        }
        
        if !isContinue , currentAlpha != self.minAlphaValue,currentAlpha != self.maxAlphaValue {
            return
        }
        
        var localState : KYNavigationFadeState = .unknow
        
        if currentAlpha < 0.3 {
            self.navigationBar?.isTranslucent = true
            self.navigationBar?.shadowImage = UIImage()
        } else if currentAlpha >= 0.7 {
            self.navigationBar?.isTranslucent = false
        }
        
        if fadeBackground! {
            if currentAlpha < 0.3 {
                localState = .faded
            } else {
                localState = .unfaded
            }
            if self.state != localState {
                self.state = localState
            }
        }
        
        if self.allowShowShowImage {
            if currentAlpha >= 0.9 && !self.isShaowImageShow {
                self.navigationBar?.shadowImage = UIImage(named: "navi_bar_line")
                self.isShaowImageShow = true
            } else if currentAlpha < 0.5 && self.isShaowImageShow {
                self.navigationBar?.shadowImage = UIImage()
                self.isShaowImageShow = false
            }
        }
        
        if (!self.onlyShowShadowImage) || (!fadeBackground! && self.state == .unfaded) { //just change shaowImage View
            return
        }
        
        if (fadeBackground!) {
            self.chageNavigationBarColor(currentAlpha)
            self.changeNavigationItemColor(currentAlpha)
        }
        self.changeTitleColor(currentAlpha)
        self.changeTitleViewColor(currentAlpha)
        self.currentAlphaValue = currentAlpha
    }
    
    // prepare before fade
    func prepareForFade() {
        self.currentAlphaValue = -100
        self.navigationBar?.shadowImage = UIImage()
        self.navigationBar?.isTranslucent = true
    }
    
    // recover to the init value
    func recoverOriginValues() {
        
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let size = CGSize(width: UIScreen.main.bounds.width, height: 64)
        
        self.navigationBar?.setBackgroundImage(UIImage.createImage(color: color, size: size) , for: .default)
        self.navigationBar?.isTranslucent = false
        self.navigationBar?.tintColor = self.originTintColor
        self.navigationBar?.barTintColor = self.originBarTintColor
        self.navigationBar?.shadowImage = UIImage()
    }
    
    // recover the navitationTitle color
    func recoverTitleColor() {
        
        if let customed = self.delegate?.fadeManagerTitleRecover?(self),customed {
            return
        }
        
        guard let attribute = self.navigationBar?.titleTextAttributes ,let color = attribute[.foregroundColor] as? UIColor else {
            return
        }
        
        let key = KYNavigationFadeManager.keyForView(.title, storeCase: .textColor)
        let originColor = self.storeOringinColor(color, key: key)
        
        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSAttributedString.Key.foregroundColor] = originColor
        self.navigationBar?.titleTextAttributes = textAttr as? [NSAttributedString.Key:Any]
    }
    
    //recover the navigationItem color
    func recoverNavigationItemColor() {
        
        if let leftBarItems = self.navigationItem.leftBarButtonItems {
            var index = 0
            for item in leftBarItems {
                
                self.recoverBarButtonItem(item, type: .leftBarItem, index: index)
                index += 1
            }
        }
        
        if let rightBarItems = self.navigationItem.rightBarButtonItems {
            var index = 0
            for item in rightBarItems {
                self.recoverBarButtonItem(item, type:.rightBarItem, index: index)
                index += 1
            }
        }
    }
    
    // MARK: fileprivate method

    //change the navigationBarColor fade
    fileprivate func chageNavigationBarColor(_ alpha : Float) {
        
        if let customed = self.delegate?.fadeManagerBarBackgroudColorChange?(self, bar: self.navigationBar, alpha: CGFloat(alpha)),customed {
            return
        }
        
        let alphaColor = self.barColor.withAlphaComponent(CGFloat(alpha))
        let size = CGSize(width: self.navigationBar?.frame.width ?? 1, height: self.navigationBar?.frame.height ?? 1)
        let image = UIImage.createImage(color: alphaColor,size:size)
        self.navigationBar?.setBackgroundImage(image, for: .default)
    }
    
    // change the navitationTitle color, support self.navigationItem.title
    fileprivate func changeTitleColor(_ alpha : Float) {
        
        if let customed = self.delegate?.fadeManagerTitleColorChange?(self, alpha: CGFloat(alpha)),customed {
            return
        }
        
        guard let attribute = self.navigationBar?.titleTextAttributes else {
            return
        }
        
        guard let color = attribute[NSAttributedString.Key.foregroundColor] as? UIColor else {
            return
        }
        
        let key = KYNavigationFadeManager.keyForView(.title, storeCase: .textColor)
        let originColor = self.storeOringinColor(color, key: key)
        
        var cAlpha : Float!
        let colorNow : UIColor
        if self.allowTitleHidden { //The title alpha will be zero when the navigation bar is translucent
            cAlpha =  (alpha - self.minAlphaValue)/(self.maxAlphaValue - self.minAlphaValue) + self.minAlphaValue
            colorNow = originColor.withAlphaComponent(CGFloat(cAlpha))
        } else {
            colorNow = self.colorWithAlpha(alpha: alpha, originColor: originColor)
        }
        
        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSAttributedString.Key.foregroundColor] = colorNow
        self.navigationBar?.titleTextAttributes = textAttr as? [NSAttributedString.Key : Any]
    }
    
    fileprivate func changeTitleViewColor(_ alpha : Float) {
        
        guard let titleView = self.navigationItem.titleView else {
            return
        }
        
        if let customed = self.delegate?.fadeManagerTitleViewColorChange?(self, title: titleView, alpha: CGFloat(alpha)),customed {
            return
        }
        
        self.changeViewAppear(view: titleView, alpha: alpha, type: .title)
    }
    
    // change the navigationItem color with alpha
    fileprivate func changeNavigationItemColor(_ alpha : Float) {
        if let leftBarItems = self.navigationItem.leftBarButtonItems {
            var index = 0
            for item in leftBarItems {
                self.changeBarButtonItem(item, alpha : alpha, type: .leftBarItem, index: index)
                index += 1
            }
        }
        
        if let rightBarItems = self.navigationItem.rightBarButtonItems {
            var index = 0
            for item in rightBarItems {
                self.changeBarButtonItem(item, alpha : alpha ,type: .rightBarItem, index: index)
                index += 1
            }
        }
    }
    
    fileprivate func changeBarButtonItem(_ item : UIBarButtonItem ,alpha:Float, type:StoreType ,index:Int) {
        
        if let customed = self.delegate?.fadeManagerBarItemColorChange?(self, barItem: item, alpha: CGFloat(alpha)),customed {
            return
        }
        
        if let image =  item.image {
            
            let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index)
            let colorNow = self.colorWithAlpha(alpha: alpha)
            let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
            item.image = imageNow?.withRenderingMode(.alwaysOriginal)
            
        } else if let customView = item.customView {
            self.changeViewAppear(view: customView, alpha: alpha, type:type,index: index)
        }
        
    }
    
    fileprivate func changeViewAppear(view : UIView ,alpha : Float, type : StoreType, index : Int? = 0) {
        
        if let label = view as? UILabel {
            
            let key = KYNavigationFadeManager.keyForView(type, storeCase: .textColor)
            let originColor = self.storeOringinColor(label.textColor, key: key)
            let colorNow = self.colorWithAlpha(alpha: alpha, originColor: originColor)
            label.textColor = colorNow
            
        } else if let imageView = view as? UIImageView {
            
            if let image =  imageView.image {
                let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index )
                let colorNow = self.colorWithAlpha(alpha: alpha)
                let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                imageView.image = imageNow?.withRenderingMode(.alwaysOriginal)
            }
            
        } else if let button = view as? UIButton {
            
            let states = [UIControl.State.normal,UIControl.State.highlighted,UIControl.State.disabled,UIControl.State.selected]
            
            for state in states {
                
                //save button image
                if let image = button.image(for:state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase:.image,index: index ,state: state)
                    let colorNow = self.colorWithAlpha(alpha: alpha)
                    let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                    button.setImage(imageNow, for: state) //Kyle undone
                }
                //save button background image
                if let image = button.backgroundImage(for:state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .backgroundImage ,index: index ,state: state)
                    let colorNow = self.colorWithAlpha(alpha: alpha)
                    let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                    button.setBackgroundImage(imageNow, for: state)
                }
                //save button textcolor
                if let textColor = button.titleColor(for: state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .textColor,index: index ,state: state)
                    let originColor = self.storeOringinColor(textColor, key: key)
                    let colorNow =  self.colorWithAlpha(alpha: alpha, originColor: originColor)
                    button.setTitleColor(colorNow, for: state)
                }
            }
        }
        
    }
    
    // MARK: recover all of the appear which stored when should be
    fileprivate func recoverTitleView() {
        
        guard let titleView = self.navigationItem.titleView else {
            return
        }
        
        if let customed = self.delegate?.fadeManagerTitleViewRecover?(self, title: titleView),customed {
            return
        }
        self.recoverViewAppear(view: titleView, type: .title)
    }
   
    fileprivate func recoverBarButtonItem(_ item : UIBarButtonItem ,type:StoreType ,index:Int) {
        
        if let customed = self.delegate?.fadeManagerBarItemRecover?(self, barItem: item),customed {
            return
        }
        
        if let image =  item.image {
            
            let key = KYNavigationFadeManager.keyForView(type, storeCase: .image, index: index)
            let imageNow = self.storeOriginImage(image, key: key)
            item.image = imageNow
            
        } else if let customView = item.customView {
            self.recoverViewAppear(view: customView, type: type,index: index)
        }
    }
    
    fileprivate func recoverViewAppear(view : UIView, type : StoreType, index : Int? = 0) {
        
        if let label = view as? UILabel {
            
            let key = KYNavigationFadeManager.keyForView(type, storeCase: .textColor)
            let originColor = self.storeOringinColor(label.textColor, key: key)
            label.textColor = originColor
            
        } else if let imageView = view as? UIImageView {
            
            if let image =  imageView.image {
                let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index )
                let imageNow = self.storeOriginImage(image, key: key)
                imageView.image = imageNow
            }
            
        } else if let button = view as? UIButton {
            
            let states = [UIControl.State.normal,UIControl.State.highlighted,UIControl.State.disabled,UIControl.State.selected]
            
            for state in states {
                
                //save button image
                if let image = button.image(for:state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase:.image,index: index ,state: state)
                    let imageNow = self.storeOriginImage(image, key: key)
                    button.setImage(imageNow, for: state)
                    
                }
                //save button background image
                if let image = button.backgroundImage(for:state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .backgroundImage ,index: index ,state: state)
                    let imageNow = self.storeOriginImage(image, key: key)
                    button.setBackgroundImage(imageNow, for: state)
                }
                //save button textcolor
                if let textColor = button.titleColor(for: state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .textColor,index: index ,state: state)
                    let originColor = self.storeOringinColor(textColor, key: key)
                    button.setTitleColor(originColor, for: state)
                }
            }
        }
    }
    
    // MARK: Tool Method
    // MARK: calculate the current alpha with offset
    fileprivate func calculatAlpha(_ offset : CGFloat) -> Float {
        
        var currentAlpha  : Float = Float((offset - self.zeroAlphaOffset) / (self.fullAlphaOffset - self.zeroAlphaOffset))
        currentAlpha = currentAlpha < self.minAlphaValue ? self.minAlphaValue : currentAlpha
        currentAlpha = currentAlpha > self.maxAlphaValue ? self.maxAlphaValue : currentAlpha
        currentAlpha = self.isReversed ? self.maxAlphaValue + self.minAlphaValue - currentAlpha : currentAlpha
        return currentAlpha
    }
    
    //with fullColor and zeroColor different ,
    //alpha =  (self.maxAlphaValue + self.minAlphaValue)/2 ,color's alpha = 0.5
    //alpha = self.minAlphaValue or alpha = self.maxAlphaValue ,color's alpha = 1
    fileprivate func calculateWithZeroDifferentColor(_ alpha : Float) -> Float {
        
        let cAlpha =   0.5 + (abs((self.maxAlphaValue + self.minAlphaValue)/2 - alpha)/((self.maxAlphaValue + self.minAlphaValue)/2)) * 0.5
        return cAlpha
    }
    
    // detect which color with the alpha ,can convert it with alpha
    fileprivate func colorWithAlpha(alpha:Float,originColor : UIColor? = nil) -> UIColor {
        var color : UIColor
        
        //detech use zeroColor or fullColor/originColor
        //when alpha < (self.maxAlphaValue + self.minAlphaValue)/2 ,use zeroColor
        //else use fullColor if not has originColor
        if (alpha < (self.maxAlphaValue + self.minAlphaValue)/2) {
            color = self.zeroColor
        } else {
            if let v = originColor {
                color = v
            } else {
                color = self.fullColor
            }
        }
        
        let cAlpha = self.calculateWithZeroDifferentColor(alpha)
        return color.withAlphaComponent(CGFloat(cAlpha))
    }
    
    //store the view's originImage
    fileprivate func storeOriginImage(_ image : UIImage,key:Int) -> UIImage {
        
        if let storeImage = self.viewOriginImages[key] {
            return storeImage
        } else {
            self.viewOriginImages[key] = image
            return image
        }
    }
    
    //store the view's textColor
    fileprivate func storeOringinColor(_ color : UIColor,key:Int) -> UIColor {
        
        if let storeColor = self.viewOriginColor[key] {
            return storeColor
        } else {
            self.viewOriginColor[key] = color
            return color
        }
    }
    
    //the key or each view with type , case ,index and state
    class func keyForView(_ storeType : StoreType, storeCase : StoreCase, index:Int?=0, state : UIControl.State? = .normal) -> Int {
        return storeType.rawValue + storeCase.rawValue + index!*10 + Int(state!.rawValue)
    }
}
