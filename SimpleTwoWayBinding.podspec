Pod::Spec.new do |s|
  s.name             = 'SimpleTwoWayBinding'
  s.version          = '0.0.1'
  s.summary          = 'Ultra light weight and simple two way binding for iOS UIControls.'
  s.description      = <<-DESC
Ultra light weight and simple two way binding for UIControls.
Written with love and hope in Swift 4.
                       DESC

  s.homepage         = 'https://github.com/manishkkatoch/SimpleTwoWayBinding'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Manish Katoch' => 'manish.katoch@gmail.com' }
  s.source           = { :git => 'https://github.com/manishkkatoch/SimpleTwoWayBinding.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'UIKit'

end