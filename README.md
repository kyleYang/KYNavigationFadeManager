# KYNavigationFadeManager

[![CI Status](http://img.shields.io/travis/kyleYang/KYNavigationFadeManager.svg?style=flat)](https://travis-ci.org/kyleYang/KYNavigationFadeManager)
[![Version](https://img.shields.io/cocoapods/v/KYNavigationFadeManager.svg?style=flat)](http://cocoapods.org/pods/KYNavigationFadeManager)
[![License](https://img.shields.io/cocoapods/l/KYNavigationFadeManager.svg?style=flat)](http://cocoapods.org/pods/KYNavigationFadeManager)
[![Platform](https://img.shields.io/cocoapods/p/KYNavigationFadeManager.svg?style=flat)](http://cocoapods.org/pods/KYNavigationFadeManager)

## introduction
This fade manager is a easy way to manage the uinavigationbar
Support to change UIBarButtonItem and title color when scroll , the navigation can be clear color (change the alpha from 0 - 1)
The UIBarButtonItem only support UIBarButtonItem.image and UIBarButtonItem's customView is UIButton (image and backgroundimage) 。
The fullColor shoulde be set. Not detech the image color because it's maybe wrong

## Example
![image](https://github.com/kyleYang/KYNavigationFadeManager/blob/master/Example/example.gif)


To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Easy to use it

### init
```swift
self.fadeManager = KYNavigationFadeManager(viewController: self, scollView: self.tableView, zeroColor: UIColor.white, fullColor: UIColor.red)
self.fadeManager.allowTitleHidden = shouldeHiddenTitle
self.fadeManager.zeroAlphaOffset  = 0
self.fadeManager.fullAlphaOffset  = 200
```
### prepare and run
```swift
 open override func viewWillAppear(_ animated: Bool) {
   super.viewWillAppear(animated)
   self.fadeManager.viewWillAppear(animated)
   self.fixNavigationBarCorruption() 
}

open override func viewWillDisappear(_ animated: Bool) {
   self.fadeManager.viewWillDisappear(animated)
   super .viewWillDisappear(animated)
 }

```


## Requirements

## Installation

KYNavigationFadeManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "KYNavigationFadeManager"
```

## Author

kyleYang, yangzychina@gmail.com

## License

KYNavigationFadeManager is available under the MIT license. See the LICENSE file for more info.
