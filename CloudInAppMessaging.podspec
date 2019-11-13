#
# Be sure to run `pod lib lint CloudInAppMessaging.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CloudInAppMessaging'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CloudInAppMessaging.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Andrew Podkovyrin/CloudInAppMessaging'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrew Podkovyrin' => 'podkovyrin@gmail.com' }
  s.source           = { :git => 'https://github.com/Andrew Podkovyrin/CloudInAppMessaging.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/podkovyr'

  s.ios.deployment_target = '11.0'

  s.source_files = 'CloudInAppMessaging/**/*'
  s.public_header_files = 'CloudInAppMessaging/*.h'
  s.private_header_files = 'CloudInAppMessaging/Private/*.h'
     
  s.frameworks = 'UIKit', 'Foundation', 'CloudKit'
end
