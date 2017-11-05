Pod::Spec.new do |s|
  s.name         = "RxToBolts"
  s.version      = "0.1.0"
  s.summary      = "Objective-C Bolts wrapper for RxSwift one time event traits"
  s.homepage     = "https://github.com/junmo-kim/RxToBolts"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Junmo Kim" => "me@junmo.kim" }
  s.social_media_url   = "https://www.linkedin.com/in/junmo-kim/"
  
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/junmo-kim/RxToBolts.git",
                     :tag => s.version.to_s }
  s.source_files = "RxToBolts/*.swift"
end
