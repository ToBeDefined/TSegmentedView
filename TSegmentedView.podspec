Pod::Spec.new do |s|
  s.name                  = "TSegmentedView"
  s.version               = "1.1.0"
  s.summary               = "You can use TSegmentedView create scroll page views"
  s.description           = "You can use TSegmentedView create scroll page views, homepage is https://github.com/tobedefined/TSegmentedView"
  s.homepage              = "https://github.com/tobedefined/TSegmentedView"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "ToBeDefined" => "weinanshao@163.com" }
  s.social_media_url      = "http://tbd.tech/"
  s.ios.deployment_target = "8.0"
  s.source                = { :git => "https://github.com/tobedefined/TSegmentedView.git", :tag => "#{s.version}" }
  s.source_files          = "Source/*.swift"
  s.exclude_files         = "Classes/Exclude"
  s.frameworks            = "Foundation", "UIKit"
  s.swift_version         = '4.0'
end
