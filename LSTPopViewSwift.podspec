Pod::Spec.new do |s|
  s.name             = 'LSTPopViewSwift'
  s.module_name      = 'LSTPopViewSwift'
  s.version          = '0.1.0'
  s.summary          = 'Native Swift/UIKit popups alongside the original Objective-C LSTPopView.'
  s.description      = 'An opt-in native Swift implementation with MainActor isolation, scoped sessions, priority queues, lifecycle callbacks, keyboard avoidance and accessibility support. The original LSTPopView Objective-C pod remains independent.'
  s.homepage         = 'https://github.com/LoSenTrad/LSTPopView'
  s.license          = { :type => 'MIT', :file => 'Swift/LICENSE' }
  s.author           = { '490790096@qq.com' => 'LoSenTrad@163.com' }
  # Independent Swift release tag; do not reuse or move existing OC version tags.
  # Before the first Swift release, use the documented :git + :branch installation.
  s.source           = { :git => 'https://github.com/LoSenTrad/LSTPopView.git', :tag => "swift-#{s.version}" }
  s.ios.deployment_target = '15.0'
  # Swift language mode 6; compiling the sources requires Swift compiler 6.2+.
  s.swift_version    = '6.0'
  s.source_files     = 'Swift/Sources/LSTPopViewSwift/**/*.swift'
  s.frameworks       = 'UIKit', 'Foundation', 'QuartzCore'
end
