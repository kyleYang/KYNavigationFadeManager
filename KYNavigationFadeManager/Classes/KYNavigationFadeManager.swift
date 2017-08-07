//
//  KYNavigationFadeManager.swift
//  Pods
//
//  Created by Kyle on 2017/5/6.
//
//

import UIKit


@objc public protocol KYNavigationFadeManagerDelegate : NSObjectProtocol {
    // this delegate method , you can change the view appear by yourself
    // if return true , the view will not change by fade manager
    // you can not change special view ,if you return true
    @objc optional func fadeManagerBarBackgroudColorChange(_ manager: KYNavigationFadeManager , bar : UINavigationBar, alpha:CGFloat) ->Bool
    @objc optional func fadeManagerTitleColorChange(_ manager: KYNavigationFadeManager , alpha:CGFloat) ->Bool
    @objc optional func fadeManagerTitleViewColorChange(_ manager: KYNavigationFadeManager,title:UIView , alpha:CGFloat) ->Bool
    @objc optional func fadeManagerBarItemColorChange(_ manager: KYNavigationFadeManager , barItem : UIBarButtonItem, alpha:CGFloat) ->Bool

    //Custom subviews recoer
    //if return ture , the manager will not recover by store values
    //if you want to customed the appear of each item , you shoulde alse customed the recover of each item
    @objc optional func fadeManagerBarBackgroudrecover(_ manager: KYNavigationFadeManager , bar : UINavigationBar) ->Bool
    @objc optional func fadeManagerTitleRecover(_ manager: KYNavigationFadeManager) ->Bool
    @objc optional func fadeManagerTitleViewRecover(_ manager: KYNavigationFadeManager,title:UIView) ->Bool
    @objc optional func fadeManagerBarItemRecover(_ manager: KYNavigationFadeManager , barItem : UIBarButtonItem) ->Bool
}



public class KYNavigationFadeManager: NSObject {

    fileprivate enum StoreType : String {
        case title = "title"
        case titleView = "titleView"
        case leftBarItem = "leftBarItem"
        case rightBarItem = "rightBarItem"
    }

    fileprivate enum StoreCase : String {
        case backgroundColor = "backgroundColor"
        case textColor = "text"
        case image = "image"
        case backgroundImage = "backgroundImage"

    }

    fileprivate var scrollObserverContext = 0

    //MARK: store value
    fileprivate var shadowImage : UIImage?
    fileprivate var backgroundImage : UIImage?
    fileprivate var isTranslucent : Bool!

    fileprivate var originTintColor : UIColor!
    fileprivate var originBarTintColor : UIColor?

    fileprivate var navigationBar : UINavigationBar
    fileprivate var scrollView : UIScrollView
    fileprivate unowned var navigationController : UINavigationController
    fileprivate unowned var viewController : UIViewController
    fileprivate var navigationItem : UINavigationItem

    fileprivate var viewOriginImages : [String:UIImage] = [:]
    fileprivate var viewOriginColor : [String:UIColor] = [:]

    //MARK: public value that can be set
    public weak var delegate  : KYNavigationFadeManagerDelegate?

    //Default is true ,when is false the bar change at once
    public var isContinue : Bool = true
    public var isReversed : Bool = false{
        didSet{
            self.recontinueState()
        }
    }

    //the title show or hidden then the navigationbar is clear
    public var allowTitleHidden : Bool = true

    public var barColor : UIColor = UIColor.white
    public var tintColor : UIColor!{
        didSet{
            if let _ = originTintColor {

            }else{
                originTintColor = tintColor
            }
        }
    }
    public var barTintColor : UIColor?{
        didSet{
            if let _ = originBarTintColor {

            }else{
                originBarTintColor = barTintColor
            }
        }
    }

    //When the bar is translucent , the item color (image)
    public var zeroColor : UIColor
    //When the bar is not translucent , the item color (image)
    public var fullColor : UIColor

    fileprivate var currentAlphaValue : Float = -100

    //When the bar go to the min apla (default is 0) , the offset
    public var zeroAlphaOffset : CGFloat = 0
    //When the bar go to the max apla (default is 0) , the offset
    public var fullAlphaOffset : CGFloat = 200
    //the min alpha of the bar
    public var minAlphaValue : Float = 0
    //the max alpha of the bar
    public var maxAlphaValue : Float = 1

//    public var delegate : KYNavigationFadeManagerDelegate?

    //if the fade manager is working, readonly value
    private(set) var isObservable = false

    //MARK:
    //MARK: instanc method
    public init<T>( viewController : T!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!) where T: UIViewController, T: KYNavigationFadeManagerDelegate {

        guard let navi = viewController.navigationController else{
            fatalError("viewController has no navigationcontroller ")
        }
        self.navigationItem = viewController.navigationItem
        self.navigationController = navi
        self.viewController = viewController
        self.delegate = viewController
        self.scrollView = scollView
        self.navigationBar = self.navigationController.navigationBar
        self.zeroColor = zeroColor
        self.fullColor = fullColor

        super.init()

        self.storeOriginValues()
        self.prepareForFade()

        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: &scrollObserverContext)

    }


    //MARK: init method for Object-C
    //if want custom by self , should set delegte
    public init(objectCViewController viewController : UIViewController!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!){

        guard let navi = viewController.navigationController else{
            fatalError("viewController has no navigationcontroller ")
        }
        self.navigationItem = viewController.navigationItem
        self.navigationController = navi
        self.viewController = viewController
        self.scrollView = scollView
        self.navigationBar = self.navigationController.navigationBar
        self.zeroColor = zeroColor
        self.fullColor = fullColor

        super.init()

        self.storeOriginValues()
        self.prepareForFade()

        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: &scrollObserverContext)
        
    }


    public override init() {
        fatalError("plese use init( viewController : UIViewController!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!) ")
    }

    //MARK:
    //MARK: this two method called when you want to observer fade or not
    public func viewWillAppear(_ animation : Bool){
        self.isObservable = true
        self.viewController.fixNavigationBarCorruption()
        self.recontinueState()
    }

    public func viewWillDisappear(_ animation : Bool){
        self.recoverState()
        self.isObservable = false
    }

    //MARK:
    //MARK: private method

    // prepare before fade
    fileprivate func prepareForFade(){
        self.currentAlphaValue = -100
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let _ = change, context == &scrollObserverContext {
            self.didScroll()
        }

    }


    fileprivate func didScroll(){

        if (!self.isObservable){
            return
        }

        let offset = self.scrollView.contentOffset
        let currentAlpha = self.calculatAlpha(offset.y)

        if (self.currentAlphaValue == currentAlpha) {
            return
        }

        if !isContinue {
            if (currentAlpha != self.minAlphaValue && currentAlpha != self.maxAlphaValue){
                return;
            }
        }

        if (currentAlpha < 0.3){
            self.navigationBar.isTranslucent = true;
        }else if (currentAlpha >= 0.7){
            self.navigationBar.isTranslucent = false;
        }

        self.chageNavigationBarColor(currentAlpha)
        self.changeNavigationItemColor(currentAlpha)
        self.changeTitleColor(currentAlpha)
        self.changeTitleViewColor(currentAlpha)
        self.currentAlphaValue = currentAlpha
    }

    //MARK:
    //MARK: change appear when scroll

    //change the navigationBarColor fade
    fileprivate func chageNavigationBarColor(_ alpha : Float){

        if let customed = self.delegate?.fadeManagerBarBackgroudColorChange?(self, bar: self.navigationBar, alpha: CGFloat(alpha)),customed{
            return ;
        }

        let alphaColor = self.barColor.withAlphaComponent(CGFloat(alpha))
        let image = UIImage(color: alphaColor,size:CGSize(width: self.navigationBar.frame.width, height: self.navigationBar.frame.height))
        self.navigationBar.setBackgroundImage(image, for: .default)
    }

    // change the navitationTitle color, support self.navigationItem.title
    fileprivate func changeTitleColor(_ alpha : Float){

        if let customed = self.delegate?.fadeManagerTitleColorChange?(self, alpha: CGFloat(alpha)),customed{
            return ;
        }

        guard let attribute = self.navigationBar.titleTextAttributes ,let color = attribute[NSForegroundColorAttributeName] as? UIColor else{
            return
        }

        let key = KYNavigationFadeManager.keyForView(.title, storeCase: .textColor)
        let originColor = self.storeOringinColor(color, key: key)

        var cAlpha : Float!
        let colorNow : UIColor
        if self.allowTitleHidden { //The title alpha will be zero when the navigation bar is translucent
            cAlpha =  (alpha - self.minAlphaValue)/(self.maxAlphaValue - self.minAlphaValue) + self.minAlphaValue;
            colorNow = originColor.withAlphaComponent(CGFloat(cAlpha))
        }else{
            colorNow = self.colorWithAlpha(alpha: alpha, originColor: originColor)
        }

        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSForegroundColorAttributeName] = colorNow
        self.navigationBar.titleTextAttributes = textAttr as? [String:Any]
    }

    fileprivate func changeTitleViewColor(_ alpha : Float){

        guard let titleView = self.navigationItem.titleView else{
            return;
        }

        if let customed = self.delegate?.fadeManagerTitleViewColorChange?(self, title: titleView, alpha: CGFloat(alpha)),customed{
            return ;
        }

        self.changeViewAppear(view: titleView, alpha: alpha, type: .title)
    }


    // change the navigationItem color with alpha
    fileprivate func changeNavigationItemColor(_ alpha : Float){


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


    fileprivate func changeBarButtonItem(_ item : UIBarButtonItem ,alpha:Float, type:StoreType ,index:Int){

        if let customed = self.delegate?.fadeManagerBarItemColorChange?(self, barItem: item, alpha: CGFloat(alpha)),customed {
            return ;
        }

        if let image =  item.image {

            let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index)
            let colorNow = self.colorWithAlpha(alpha: alpha)
            let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
            item.image = imageNow?.withRenderingMode(.alwaysOriginal)

        }else if let customView = item.customView{
            self.changeViewAppear(view: customView, alpha: alpha, type:type,index: index);
        }

    }


    fileprivate func changeViewAppear(view : UIView ,alpha : Float, type : StoreType, index : Int? = 0){

        if let label = view as? UILabel {

            let key = KYNavigationFadeManager.keyForView(type, storeCase: .textColor)
            let originColor = self.storeOringinColor(label.textColor, key: key)
            let colorNow = self.colorWithAlpha(alpha: alpha, originColor: originColor)
            label.textColor = colorNow

        }else if let imageView = view as? UIImageView {

            if let image =  imageView.image {
                let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index )
                let colorNow = self.colorWithAlpha(alpha: alpha)
                let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                imageView.image = imageNow?.withRenderingMode(.alwaysOriginal)
            }

        }else if let button = view as? UIButton {

            let states = [UIControlState.normal,UIControlState.highlighted,UIControlState.disabled,UIControlState.selected];

            for state in states {

                //save button image
                if let image = button.image(for:state){
                    let key = KYNavigationFadeManager.keyForView(type,storeCase:.image,index: index ,state: state)
                    let colorNow = self.colorWithAlpha(alpha: alpha)
                    let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                    button.setImage(imageNow, for: state)

                }
                //save button background image
                if let image = button.backgroundImage(for:state) {
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .backgroundImage ,index: index ,state: state)
                    let colorNow = self.colorWithAlpha(alpha: alpha)
                    let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                    button.setBackgroundImage(imageNow, for: state)
                }
                //save button textcolor
                if let textColor = button.titleColor(for: state){
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .textColor,index: index ,state: state)
                    let originColor = self.storeOringinColor(textColor, key: key)
                    let colorNow =  self.colorWithAlpha(alpha: alpha, originColor: originColor)
                    button.setTitleColor(colorNow, for: state)
                }
            }
        }
        
    }

    //MARK:
    //MARK: recover all of the appear which stored when should be

    // recover the navitationTitle color
    fileprivate func recoverTitleColor(){

        if let customed = self.delegate?.fadeManagerTitleRecover?(self),customed {
            return ;
        }

        guard let attribute = self.navigationBar.titleTextAttributes ,let color = attribute[NSForegroundColorAttributeName] as? UIColor else{
            return
        }

        let key = KYNavigationFadeManager.keyForView(.title, storeCase: .textColor)
        let originColor = self.storeOringinColor(color, key: key)

        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSForegroundColorAttributeName] = originColor
        self.navigationBar.titleTextAttributes = textAttr as? [String:Any]

    }

    fileprivate func recoverTitleView(){

        guard let titleView = self.navigationItem.titleView else{
            return;
        }

        if let customed = self.delegate?.fadeManagerTitleViewRecover?(self, title: titleView),customed{
            return ;
        }
        self.recoverViewAppear(view: titleView, type: .title)

    }



    //recover the navigationItem color
    fileprivate func recoverNavigationItemColor(){

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
    


    fileprivate func recoverBarButtonItem(_ item : UIBarButtonItem ,type:StoreType ,index:Int){

        if let customed = self.delegate?.fadeManagerBarItemRecover?(self, barItem: item),customed{
            return ;
        }

        if let image =  item.image {

            let key = KYNavigationFadeManager.keyForView(type, storeCase: .image, index: index)
            let imageNow = self.storeOriginImage(image, key: key)
            item.image = imageNow

        }else if let customView = item.customView {
            self.recoverViewAppear(view: customView, type: type,index: index)
        }
    }

    fileprivate func recoverViewAppear(view : UIView, type : StoreType, index : Int? = 0){

        if let label = view as? UILabel {

            let key = KYNavigationFadeManager.keyForView(type, storeCase: .textColor)
            let originColor = self.storeOringinColor(label.textColor, key: key)
            label.textColor = originColor

        }else if let imageView = view as? UIImageView {

            if let image =  imageView.image {
                let key = KYNavigationFadeManager.keyForView(type, storeCase:.image,index: index )
                let imageNow = self.storeOriginImage(image, key: key)
                imageView.image = imageNow
            }

        }else if let button = view as? UIButton {

            let states = [UIControlState.normal,UIControlState.highlighted,UIControlState.disabled,UIControlState.selected];

            for state in states {

                //save button image
                if let image = button.image(for:state){
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
                if let textColor = button.titleColor(for: state){
                    let key = KYNavigationFadeManager.keyForView(type,storeCase: .textColor,index: index ,state: state)
                    let originColor = self.storeOringinColor(textColor, key: key)
                    button.setTitleColor(originColor, for: state)
                }
            }
        }
        
    }

    //MARK store or recover the navigationbar
    // store the origin value
    fileprivate func storeOriginValues(){

        self.isTranslucent = self.navigationBar.isTranslucent
        self.tintColor = self.navigationBar.tintColor
        self.barTintColor = self.navigationBar.barTintColor
        self.shadowImage = self.navigationBar.shadowImage
        self.backgroundImage = self.navigationBar.backgroundImage(for: .default)
        if let image = self.backgroundImage {
            let color = UIColor(patternImage: image)
            self.barColor = color
        }
    }
    // recover to the init value
    fileprivate func recoverOriginValues(){
        self.navigationBar.setBackgroundImage(self.backgroundImage, for: .default)
        self.navigationBar.isTranslucent = self.isTranslucent
        self.navigationBar.tintColor = self.originTintColor
        self.navigationBar.barTintColor = self.originBarTintColor
        self.navigationBar.shadowImage = self.shadowImage
    }


    fileprivate func recontinueState(){
        self.prepareForFade()
        self.didScroll()
    }

    fileprivate func recoverState(){
        self.recoverOriginValues()
        self.recoverTitleColor()
        self.recoverNavigationItemColor()
    }

    deinit {
        self.scrollView .removeObserver(self, forKeyPath: "contentOffset")
//        self.recoverState()
    }

    //MARK: Tool Method
    //MARK: calculate the current alpha with offset
    fileprivate func calculatAlpha(_ offset : CGFloat) -> Float {

        var currentAlpha  : Float = Float((offset - self.zeroAlphaOffset) / (self.fullAlphaOffset - self.zeroAlphaOffset))
        currentAlpha = currentAlpha < self.minAlphaValue ? self.minAlphaValue : currentAlpha
        currentAlpha = currentAlpha > self.maxAlphaValue ? self.maxAlphaValue : currentAlpha
        currentAlpha = self.isReversed ? self.maxAlphaValue + self.minAlphaValue - currentAlpha : currentAlpha;
        return currentAlpha
    }

    //with fullColor and zeroColor different ,
    //alpha =  (self.maxAlphaValue + self.minAlphaValue)/2 ,color's alpha = 0.5
    //alpha = self.minAlphaValue or alpha = self.maxAlphaValue ,color's alpha = 1
    fileprivate func calculateWithZeroDifferentColor(_ alpha : Float) -> Float{

        let cAlpha =   0.5 + (abs((self.maxAlphaValue + self.minAlphaValue)/2 - alpha)/((self.maxAlphaValue + self.minAlphaValue)/2)) * 0.5;
        return cAlpha
    }

    // detect which color with the alpha ,can convert it with alpha
    fileprivate func colorWithAlpha(alpha:Float,originColor : UIColor? = nil) -> UIColor {
        var color : UIColor

        //detech use zeroColor or fullColor/originColor
        //when alpha < (self.maxAlphaValue + self.minAlphaValue)/2 ,use zeroColor
        //else use fullColor if not has originColor
        if (alpha < (self.maxAlphaValue + self.minAlphaValue)/2){
            color = self.zeroColor
        }else{
            if let _color = originColor {
                color = _color
            }else{
                color = self.fullColor
            }
        }

        let cAlpha = self.calculateWithZeroDifferentColor(alpha);
        return color.withAlphaComponent(CGFloat(cAlpha))
    }

    //store the view's originImage
    fileprivate func storeOriginImage(_ image : UIImage,key:String) -> UIImage{

        if let storeImage = self.viewOriginImages[key] {
            return storeImage
        }else{
            self.viewOriginImages[key] = image
            return image
        }
    }

    //store the view's textColor
    fileprivate func storeOringinColor(_ color : UIColor,key:String) -> UIColor{

        if let storeColor = self.viewOriginColor[key] {
            return storeColor
        }else{
            self.viewOriginColor[key] = color
            return color
        }
    }

    //the key or each view with type , case ,index and state
    fileprivate class func keyForView(_ StoreType : StoreType,storeCase : StoreCase, index:Int?=0, state : UIControlState? = .normal) -> String{
        return String(format:"%@_%@_%ld_%ld",StoreType.rawValue,storeCase.rawValue,index!,state!.rawValue)
    }

}

//MARK:
//MARK: Category UIImage
extension UIImage {
    //create a pure image with color
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
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


extension UIViewController{

    //question:  corrupt UINavigationBar when swiping back fast using the default interactivePopGestureRecognizer
    //https://stackoverflow.com/questions/24226392/ios-7-corrupt-uinavigationbar-when-swiping-back-fast-using-the-default-interact/24289194
    //fuction copy form https://github.com/JKalash/FixNavBarCorruption/blob/master/FixNavBarCorruption.swift
    //By the way,when the bar alpha = 1.0 , this fuction not work well ~~
    public func fixNavigationBarCorruption() {
        if let coordinator = self.transitionCoordinator {
            if coordinator.initiallyInteractive {
                let mapTable = NSMapTable<AnyObject, AnyObject>(keyOptions: NSMapTableStrongMemory, valueOptions: NSMapTableStrongMemory, capacity: 0)
                coordinator.notifyWhenInteractionEnds({ (context) -> Void in
                    if let n = self.navigationController {
                        for view in n.navigationBar.subviews {
                            if let animationKeys = view.layer.animationKeys() {
                                let anims = NSMutableArray()
                                for animationKey in animationKeys {
                                    if let anim = view.layer.animation(forKey: animationKey) {
                                        if anim.isKind(of: CABasicAnimation.classForCoder()) {
                                            let animCopy = CABasicAnimation(keyPath: (anim as! CABasicAnimation).keyPath)
                                            // Make sure fromValue and toValue are the same, and that they are equal to the layer's final resting value
                                            animCopy.fromValue = view.layer.value(forKeyPath: (anim as! CABasicAnimation).keyPath!)
                                            animCopy.toValue = view.layer.value(forKeyPath: (anim as! CABasicAnimation).keyPath!)
                                            animCopy.byValue = (anim as! CABasicAnimation).byValue
                                            // CAPropertyAnimation properties
                                            animCopy.isAdditive = (anim as! CABasicAnimation).isAdditive
                                            animCopy.isCumulative = (anim as! CABasicAnimation).isCumulative
                                            animCopy.valueFunction = (anim as! CABasicAnimation).valueFunction
                                            // CAAnimation properties
                                            animCopy.timingFunction = anim.timingFunction
                                            animCopy.delegate = anim.delegate
                                            animCopy.isRemovedOnCompletion = anim.isRemovedOnCompletion
                                            // CAMediaTiming properties
                                            animCopy.speed = anim.speed
                                            animCopy.repeatCount = anim.repeatCount
                                            animCopy.repeatDuration = anim.repeatDuration
                                            animCopy.autoreverses = anim.autoreverses
                                            animCopy.fillMode = anim.fillMode
                                            // We want our new animations to be instantaneous, so set the duration to zero.
                                            // Also set both the begin time and time offset to 0.
                                            animCopy.duration = 0
                                            animCopy.beginTime = 0
                                            animCopy.timeOffset = 0
                                            anims.add(animCopy)
                                        }
                                    }
                                }
                                mapTable.setObject(anims, forKey: view)
                            }
                        }
                    }
                })
                coordinator.animate(alongsideTransition: nil, completion: { (context) -> Void in
                    for view in mapTable.keyEnumerator() {
                        if let v = view as? UIView {
                            if let anims = mapTable.object(forKey: v) as? [CABasicAnimation] {
                                for anim in anims {
                                    v.layer.add(anim, forKey: anim.keyPath)
                                }
                            }
                        }
                    }
                })
            }
        }
    }

}

