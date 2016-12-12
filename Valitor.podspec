#
# Be sure to run `pod lib lint Valitor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Valitor'
  s.version          = '0.1.2'
  s.summary          = 'Valitor iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Valitor iOS Library to communicate with ValitorPosiTengdur
                       DESC

  s.homepage         = 'https://www.valitor.is'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ivar' => 'ivarhuni@stokkur.is' }
  s.source           = { :git => 'https://bitbucket.org/stokkur/valitorcocoapod.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'Valitor/Classes/*.{h,a}'

  #s.vendored_library = 'Valitor/Classes/libValitor.a'

  s.public_header_files = 'Valitor/Classes/*.h'
  s.frameworks = 'Security', 'AVFoundation', 'CoreAudio', 'AudioToolbox', 'MessageUI', 'CoreBluetooth', 'CFNetwork', 'ExternalAccessory', 'SystemConfiguration', 'CoreGraphics', 'UIKit', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
