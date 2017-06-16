//
//  KYNavigationFadeManager.swift
//  Pods
//
//  Created by Kyle on 2017/5/6.
//
//

import UIKit

public class KYNavigationFadeManager: NSObject {

    private static let leftKey = "ky_bar_left"
    private static let rightKey = "ky_bar_right"

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

    fileprivate var barItemOriginImages : [String:UIImage] = [:]

    //MARK: public value that can be set

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
    public var barItemZeroColor : UIColor
    //When the bar is not translucent , the item color (image)
    public var barItemFullColor : UIColor
    public var barTitleFullColor : UIColor?

    fileprivate var currentAlphaValue : Float = -100

    //When the bar go to the min apla (default is 0) , the offset
    public var zeroAlphaOffset : CGFloat = 0
    //When the bar go to the max apla (default is 0) , the offset
    public var fullAlphaOffset : CGFloat = 200
    //the min alpha of the bar
    public var minAlphaValue : Float = 0
    //the max alpha of the bar
    public var maxAlphaValue : Float = 1

    //if the fade manager is working, readonly value
    private(set) var isObservable = false

    //MARK: instanc method
    public init( viewController : UIViewController!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!) {

        guard let navi = viewController.navigationController else{
            fatalError("viewController has no navigationcontroller ")
        }
        self.navigationItem = viewController.navigationItem
        self.navigationController = navi
        self.viewController = viewController
        self.scrollView = scollView
        self.navigationBar = self.navigationController.navigationBar
        self.barItemZeroColor = zeroColor
        self.barItemFullColor = fullColor

        super.init()

        self.storeOriginValues()
        self.prepareForFade()

        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: &scrollObserverContext)

    }

    public override init() {
        fatalError("plese use init( viewController : UIViewController!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!) ")
    }


    public func viewWillAppear(_ animation : Bool){
        self.isObservable = true
        self.viewController.fixNavigationBarCorruption()
        self.recontinueState()
    }

    public func viewWillDisappear(_ animation : Bool){
        self.recoverState()
        self.isObservable = false

    }




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
        self.currentAlphaValue = currentAlpha
    }

    //change the navigationBarColor fade
    fileprivate func chageNavigationBarColor(_ alpha : Float){

        let alphaColor = self.barColor.withAlphaComponent(CGFloat(alpha))
        let image = UIImage(color: alphaColor,size:CGSize(width: self.navigationBar.frame.width, height: self.navigationBar.frame.height))
        self.navigationBar.setBackgroundImage(image, for: .default)
    }

    // change the navitationTitle color
    fileprivate func changeTitleColor(_ alpha : Float){

        guard let attribute = self.navigationBar.titleTextAttributes else{
            return
        }

        if let _ = self.barTitleFullColor {

        }else{
            self.barTitleFullColor = attribute[NSForegroundColorAttributeName] as? UIColor
        }

        var cAlpha : Float!
        var colorNow : UIColor? = self.barTitleFullColor
        if self.allowTitleHidden {
            cAlpha =   (alpha - self.minAlphaValue)/(self.maxAlphaValue + self.minAlphaValue) * 1;
        }else{
            if (alpha < (self.maxAlphaValue + self.minAlphaValue)/2){
                colorNow = self.barItemZeroColor
            }
            cAlpha = self.calculateWithZeroDifferentColor(alpha);
        }

        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSForegroundColorAttributeName] = colorNow?.withAlphaComponent(CGFloat(cAlpha))
        self.navigationBar.titleTextAttributes = textAttr as? [String:Any]
    }

    // recover the navitationTitle color
    fileprivate func recoverTitleColor(){
        guard let attribute = self.navigationBar.titleTextAttributes else{
            return
        }
        let textAttr  = NSMutableDictionary(dictionary: attribute)
        textAttr[NSForegroundColorAttributeName] = self.barTitleFullColor
        self.navigationBar.titleTextAttributes = textAttr as? [String:Any]
    }

    // change the navigationItem color with alpha
    fileprivate func changeNavigationItemColor(_ alpha : Float){

        var colorNow : UIColor!
        if (alpha < (self.maxAlphaValue + self.minAlphaValue)/2){
            colorNow = self.barItemZeroColor
        }else{
            colorNow = self.barItemFullColor
        }

        let cAlpha =  self.calculateWithZeroDifferentColor(alpha);

        if let leftBarItems = self.navigationItem.leftBarButtonItems {
            var index = 0
            for item in leftBarItems {

                self.changeBarButtonItem(item, color: colorNow,alpha: cAlpha, side: KYNavigationFadeManager.leftKey, index: index)
                index += 1
            }
        }

        if let rightBarItems = self.navigationItem.rightBarButtonItems {
            var index = 0
            for item in rightBarItems {
                self.changeBarButtonItem(item,color: colorNow,alpha:cAlpha, side: KYNavigationFadeManager.rightKey, index: index)
                index += 1
            }
        }
    }

    //recover the navigationItem color
    fileprivate func recoverNavigationItemColor(){

        if let leftBarItems = self.navigationItem.leftBarButtonItems {
            var index = 0
            for item in leftBarItems {

                self.recoverBarButtonItem(item, side: KYNavigationFadeManager.leftKey, index: index)
                index += 1
            }
        }

        if let rightBarItems = self.navigationItem.rightBarButtonItems {
            var index = 0
            for item in rightBarItems {
                self.recoverBarButtonItem(item, side: KYNavigationFadeManager.rightKey, index: index)
                index += 1
            }
        }


    }


    fileprivate func changeBarButtonItem(_ item : UIBarButtonItem ,color:UIColor ,alpha:Float , side:String ,index:Int){

        if let image =  item.image {

            let key = KYNavigationFadeManager.keyForItem(side, index: index)
            let colorNow = color.withAlphaComponent(CGFloat(alpha))
            let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
            item.image = imageNow?.withRenderingMode(.alwaysOriginal)

        }else if let customView = item.customView{
            if let imageView = customView as? UIImageView {

                if let image =  imageView.image {

                    let key = KYNavigationFadeManager.keyForItem(side, index: index)
                    let colorNow = color.withAlphaComponent(CGFloat(alpha))
                    let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                    item.image = imageNow

                }

            }else if let button = customView as? UIButton {

                let states = [UIControlState.normal,UIControlState.highlighted,UIControlState.disabled,UIControlState.selected];

                for state in states {

                    if let image = button.image(for:state){

                        let key = KYNavigationFadeManager.keyForItem(side, index: index,state: state)
                        let colorNow = color.withAlphaComponent(CGFloat(alpha))
                        let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                        button.setImage(imageNow, for: state)

                    }else if let image = button.backgroundImage(for: .normal) {

                        let key = KYNavigationFadeManager.keyForItem(side, index: index,state: state)
                        let colorNow = color.withAlphaComponent(CGFloat(alpha))
                        let imageNow = self.storeOriginImage(image, key: key).kyImageWithColor(color: colorNow)
                        button.setBackgroundImage(imageNow, for: state)
                    }



                }

            }
        }

    }


    fileprivate func recoverBarButtonItem(_ item : UIBarButtonItem ,side:String ,index:Int){

        if let image =  item.image {

            let key = KYNavigationFadeManager.keyForItem(side, index: index)
            let imageNow = self.storeOriginImage(image, key: key)
            item.image = imageNow

        }else if let customView = item.customView{
            if let imageView = customView as? UIImageView {

                if let image =  imageView.image {

                    let key = KYNavigationFadeManager.keyForItem(side, index: index)
                    let imageNow = self.storeOriginImage(image, key: key)
                    item.image = imageNow

                }

            }else if let button = customView as? UIButton {

                let states = [UIControlState.normal,UIControlState.highlighted,UIControlState.disabled,UIControlState.selected];

                for state in states {

                    if let image = button.image(for:state){

                        let key = KYNavigationFadeManager.keyForItem(side, index: index,state: state)
                        let imageNow = self.storeOriginImage(image, key: key)
                        button.setImage(imageNow, for: state)

                    }else if let image = button.backgroundImage(for: .normal) {
                        let key = KYNavigationFadeManager.keyForItem(side, index: index,state: state)
                        let imageNow = self.storeOriginImage(image, key: key)
                        button.setBackgroundImage(imageNow, for: state)
                    }

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


    //MARK: calculate the current alpha with offset
    fileprivate func calculatAlpha(_ offset : CGFloat) -> Float {

        var currentAlpha  : Float = Float((offset - self.zeroAlphaOffset) / (self.fullAlphaOffset - self.zeroAlphaOffset))
        currentAlpha = currentAlpha < self.minAlphaValue ? self.minAlphaValue : currentAlpha
        currentAlpha = currentAlpha > self.maxAlphaValue ? self.maxAlphaValue : currentAlpha
        currentAlpha = self.isReversed ? self.maxAlphaValue + self.minAlphaValue - currentAlpha : currentAlpha;
        return currentAlpha
    }

    fileprivate func calculateWithZeroDifferentColor(_ alpha : Float) -> Float{

        let cAlpha =   0.5 + (abs((self.maxAlphaValue + self.minAlphaValue)/2 - alpha)/((self.maxAlphaValue + self.minAlphaValue)/2)) * 0.5;
        return cAlpha
    }



    deinit {
        self.scrollView .removeObserver(self, forKeyPath: "contentOffset")
        self.recoverState()
    }

    //MARK: Tool Method

    //the key or each item with side(left or right)
    fileprivate class func keyForItem(_ side : String, index:Int, state : UIControlState? = .normal) -> String{
        return String(format:"%@_%ld_%ld",side,index,state!.rawValue)
    }

    //store the barItem's originImage
    fileprivate func storeOriginImage(_ image : UIImage,key:String) -> UIImage{

        if let storeImage = self.barItemOriginImages[key] {
            return storeImage
        }else{
            self.barItemOriginImages[key] = image
            return image
        }
    }

}

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

