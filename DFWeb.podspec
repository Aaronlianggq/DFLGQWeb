Pod::Spec.new do |s|
  s.name         = 'DFWeb'
  s.version      = '1.0.0'
  s.summary      = '东福WebSDk集成'
  s.homepage     = 'https://github.com/Aaronlianggq/DFWeb'
  s.license      = 'MIT'
  s.authors      = {'aaronlianggq' => '897135405@qq.com'}
  s.platform     = :ios, '11.0'
  s.source       = {:git => 'https://github.com/Aaronlianggq/DFWeb.git', :tag => s.version}
  s.source_files = 'DFSDKApp/SDK/*.{h,m,swift}' #'DFSDKApp/Third/*.{h,m,swift}'
  s.framework    = 'UIKit','Foundation.framework','QuartzCore','ImageIO','CoreGraphics','AVFoundation'
  s.requires_arc = true
end
