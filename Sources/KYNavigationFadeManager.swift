//
//  KYNavigationFadeManager.swift
//  Pods
//
//  Created by Kyle on 2017/5/6.
//
//

import UIKit

public protocol KYNavigationFadeManagerDelegate : NSObjectProtocol {
    // this delegate method , you can change the view appear by yourself
    // if return true , the view will not change by fade manager
    // you can not change special view ,if you return true
    optional func fadeManagerBarBackgroudColorChange(_ manager: KYNavigationFadeManager , bar : UINavigationBar?, alpha:CGFloat) -> Bool
    optional func fadeManagerTitleColorChange(_ manager: KYNavigationFadeManager , alpha:CGFloat) -> Bool
    optional func fadeManagerTitleViewColorChange(_ manager: KYNavigationFadeManager,title:UIView , alpha:CGFloat) -> Bool
    optional func fadeManagerBarItemColorChange(_ manager: KYNavigationFadeManager , barItem : UIBarButtonItem, alpha:CGFloat) -> Bool

    //Custom subviews recoer
    //if return ture , the manager will not recover by store values
    //if you want to customed the appear of each item , you shoulde alse customed the recover of each item
    optional func fadeManagerBarBackgroudRecover(_ manager: KYNavigationFadeManager , bar : UINavigationBar) -> Bool
    optional func fadeManagerTitleRecover(_ manager: KYNavigationFadeManager) -> Bool
    optional func fadeManagerTitleViewRecover(_ manager: KYNavigationFadeManager,title:UIView) -> Bool
    optional func fadeManagerBarItemRecover(_ manager: KYNavigationFadeManager , barItem : UIBarButtonItem) -> Bool

    optional func fadeManager(_ manager: KYNavigationFadeManager, changeState:KYNavigationFadeState)
}

public enum KYNavigationFadeState : Int {
    case unknow
    case faded
    case unfaded
}

public class KYNavigationFadeManager: NSObject {

    enum StoreType : Int {
        case title = 10000
        case titleView = 20000
        case leftBarItem = 30000
        case rightBarItem = 40000
    }

    enum StoreCase : Int {
        case backgroundColor = 1000
        case textColor = 2000
        case image = 3000
        case backgroundImage = 4000
    }

    fileprivate var scrollObserverContext = 0

    var isShaowImageShow = false
    // MARK: store value
    var shadowImage : UIImage?
    var backgroundImage : UIImage?
    var isTranslucent : Bool!
    var barBackgroundColor : UIColor?

    var originTintColor : UIColor!
    var originBarTintColor : UIColor?

    weak var navigationBar : UINavigationBar?
    var scrollView : UIScrollView
    weak var navigationController : UINavigationController?
    weak var viewController : UIViewController?
    var navigationItem : UINavigationItem

    var viewOriginImages : [Int:UIImage] = [:]
    var viewOriginColor : [Int:UIColor] = [:]

    // MARK: public value that can be set
    public weak var delegate  : KYNavigationFadeManagerDelegate?

    //Default is true ,when is false the bar change at once
    public var isContinue : Bool = true
    public var isReversed : Bool = false {
        didSet {
            self.isShaowImageShow = true
            self.recontinueState()
        }
    }

    public var state : KYNavigationFadeState = .unknow {
        didSet {
            self.delegate?.fadeManager?(self, changeState: state)
        }
    }

    //the title show or hidden then the navigationbar is clear
    public var allowTitleHidden : Bool = true
    public var allowShowShowImage : Bool = true
    public var onlyShowShadowImage : Bool = true

    public var barColor : UIColor = UIColor.white
    public var tintColor : UIColor! {
        didSet {
            if  originTintColor == nil {
                originTintColor = tintColor
            }
        }
    }
    public var barTintColor : UIColor? {
        didSet {
             if originBarTintColor == nil {
                 originBarTintColor = barTintColor
                return
            }
        }
    }

    //When the bar is translucent , the item color (image)
    public var zeroColor : UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    //When the bar is not translucent , the item color (image)
    public var fullColor : UIColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)

    var currentAlphaValue : Float = -100

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

    // MARK: instanc method
    public init<T>( viewController : T!,scollView : UIScrollView!,zeroColor:UIColor? = nil,fullColor:UIColor? = nil) where T: UIViewController, T: KYNavigationFadeManagerDelegate {

        guard let navi = viewController.navigationController else {
            fatalError("viewController has no navigationcontroller ")
        }
        self.navigationItem = viewController.navigationItem
        self.navigationController = navi
        self.viewController = viewController
        self.delegate = viewController
        self.scrollView = scollView
        self.navigationBar = self.navigationController?.navigationBar
        if let v = zeroColor {
            self.zeroColor = v
        }
        if let v = fullColor {
            self.fullColor = v
        }
    
        super.init()

        self.storeOriginValues()
        self.prepareForFade()

        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: &scrollObserverContext)

    }

    public override init() {
        fatalError("plese use init( viewController : UIViewController!,scollView : UIScrollView!,zeroColor:UIColor!,fullColor:UIColor!) ")
    }

    // MARK: this two method called when you want to observer fade or not
    open func viewWillAppear(_ animation : Bool) {
        self.isObservable = true
        self.recontinueState()
    }

    open func viewDidAppear(_ animation : Bool) {
        self.currentAlphaValue = -100
        self.didScroll(fadeBackground: false)
    }

    open func viewWillDisappear(_ animation : Bool) {
        print("viewWillDisappear")
        self.recoverState()
        self.isObservable = false
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if change != nil, context == &scrollObserverContext {
            self.didScroll()
        }
    }
    
    //continue fade scroll
    public func recontinueState() {
        self.prepareForFade()
        self.didScroll()
    }
    
    //recover to the initialization state
    public func recoverState() {
        self.recoverOriginValues()
        self.recoverTitleColor()
        self.recoverNavigationItemColor()
        self.state = .unfaded
    }

    deinit {
        self.scrollView .removeObserver(self, forKeyPath: "contentOffset")
    }
}
