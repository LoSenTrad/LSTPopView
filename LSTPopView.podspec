#
# Be sure to run `pod lib lint LSTPopView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSTPopView'
  s.version          = '0.2.122201'
  s.summary          = 'LSTPopView是一个iOS万能弹窗组件'
  s.description      = 'LSTPopView 万能弹窗,功能强大,易于拓展,性能优化和内存控制让其运行更加的流畅和稳健, LSTPopView的出现,可以让我们更专注弹窗页面的布局. 省心省力 ! 提高开发效率 !'
  s.homepage         = 'https://github.com/LoSenTrad/LSTPopView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '490790096@qq.com' => 'LoSenTrad@163.com' }
  s.source           = { :git => 'https://github.com/LoSenTrad/LSTPopView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  
  s.default_subspec = 'Code'
  s.subspec 'Code' do |code|
      code.source_files = 'LSTPopView/Classes/Code/**/*'
      code.frameworks = 'UIKit'
  end


  s.dependency 'LSTTimer'

 

end
