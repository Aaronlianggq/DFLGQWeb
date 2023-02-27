Pod::Spec.new do |s|
  s.name         = 'DFLGQWeb'
  s.version      = '1.0.0'
  s.summary      = '东福WebSDk集成'
  s.homepage     = 'https://github.com/Aaronlianggq/DFLGQWeb'
  s.license      = 'MIT'
  s.authors      = {'aaronlianggq' => '897135405@qq.com'}
  s.platform     = :ios, '11.0'
  s.source       = {:git => 'https://github.com/Aaronlianggq/DFLGQWeb.git', :tag => s.version}
  s.source_files = 'DFLGQWeb/**/*.{h,m,swift}' 
  s.swift_versions = ['5.0']
  s.xcconfig = {
      'LIBRARY_SEARCH_PATHS' => '$(SDKROOT)/usr/lib/swift',
  }
  s.framework    = 'UIKit','Foundation','QuartzCore','ImageIO','CoreGraphics','AVFoundation'
  s.requires_arc = true
end
