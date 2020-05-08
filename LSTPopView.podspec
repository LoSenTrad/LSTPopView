#
# Be sure to run `pod lib lint LSTPopView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSTPopView'
  s.version          = '0.1.05081545'
  s.summary          = 'A short description of LSTPopView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'LSTPopView是一个万能弹窗,满足大部分需求!!!'

  s.homepage         = 'https://github.com/LoSenTrad/LSTPopView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '490790096@qq.com' => 'LoSenTrad@163.com' }
  s.source           = { :git => 'https://github.com/LoSenTrad/LSTPopView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Code'
  
  s.subspec 'Code' do |code|
      code.source_files = 'LSTPopView/Classes/Code/**/*'
      #core.public_header_files = 'LSTAlertView/Classes/Core/**/*.h'
      code.frameworks = 'UIKit'
  end
  # s.resource_bundles = {
  #   'LSTAlertView' => ['LSTAlertView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'LSTCategory/UIView+LSTView'
  s.dependency 'LSTCategory/NSString+LSTString'
  s.dependency 'LSTCategory/UIColor+LSTColor'
  s.dependency 'LSTCategory/UIView+LSTView'
  s.dependency 'LSTCategory/LSTGestureEvents'
  s.dependency 'LSTCategory/LSTControlEvents'

end
