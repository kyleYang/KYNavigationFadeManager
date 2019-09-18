#
# Be sure to run `pod lib lint KYNavigationFadeManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KYNavigationFadeManager'
  s.version          = '0.3.0'
  s.summary          = 'A easy way to fade UINavigationController bar and support change bar item color'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    This fade manager is a easy way to manage the uinavigationbar Support to change UIBarButtonItem and title color when scroll , the navigation can be clear color (change the alpha from 0 - 1) The UIBarButtonItem only support UIBarButtonItem.image and UIBarButtonItem's customView is UIButton (image and backgroundimage) 。 The fullColor shoulde be set. Not detech the image color because it's maybe wrong!
                       DESC

  s.homepage         = 'https://github.com/kyleYang/KYNavigationFadeManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kyleYang' => 'yangzychina@gmail.com' }
  s.source           = { :git => 'https://github.com/kyleYang/KYNavigationFadeManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/*.swift'
  s.frameworks = 'UIKit'

end
