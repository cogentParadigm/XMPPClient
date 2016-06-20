#
# Be sure to run `pod lib lint XMPPClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XMPPClient'
  s.version          = '0.1.0'
  s.summary          = 'A short description of XMPPClient.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cogentParadigm/XMPPClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ali Gangji' => 'ali@neonrain.com' }
  s.source           = { :git => 'https://github.com/cogentParadigm/XMPPClient.git', :tag => s.version.to_s }

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.dependency 'JSQMessagesViewController'
  s.dependency 'JSQSystemSoundPlayer', '~> 2.0'  
  s.dependency 'XMPPFramework'

  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit', 'CFNetwork', 'Security', 'XMPPFramework'
  s.source_files = 'XMPPClient/Classes/**/*'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/XMPPFramework/module', 'ENABLE_BITCODE' => 'NO'}
end
