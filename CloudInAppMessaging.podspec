Pod::Spec.new do |s|
  s.name             = 'CloudInAppMessaging'
  s.version          = '0.1.0'
  s.summary          = 'Send In-App Messages via CloudKit without a hassle.'

  s.description      = <<-DESC
CloudInAppMessaging is CloudKit-powered SDK 
which allows you to engage active app users with contextual messages.
                       DESC

  s.homepage         = 'https://github.com/podkovyrin/CloudInAppMessaging'
  s.license          = 'MIT'
  s.author           = { 'Andrew Podkovyrin' => 'podkovyrin@gmail.com' }
  s.source           = { :git => 'https://github.com/Andrew Podkovyrin/CloudInAppMessaging.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/podkovyr'

  s.ios.deployment_target = '10.0'

  s.source_files = 'CloudInAppMessaging/**/*'
  s.public_header_files = 'CloudInAppMessaging/*.h'
  s.private_header_files = 'CloudInAppMessaging/Private/*.h'
     
  s.frameworks = 'UIKit', 'Foundation', 'CloudKit'
end
