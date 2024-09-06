Pod::Spec.new do |s|
  s.name             = 'XYMediaFfmpeg'
  s.version          = '0.0.2'
  s.summary          = 'XYMediaFfmpeg'
  s.description      = 'XYMediaFfmpeg dynamic library'
  s.homepage         = 'https://github.com/RTE-Dev/RedPlayer/source/ios/RedPlayerDemo/Submodules/XYMediaFfmpeg'
  s.license          = { :type => 'LGPL', :file => 'LICENSE' }
  s.author           = { 'chengyifeng' => 'chengyifeng@xiaohongshu.com' }
  s.source           = { :git => 'git@github.com/RTE-Dev/RedPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.ios.framework = ['AVFoundation', 'CoreVideo', 'AudioToolbox', 'VideoToolbox', 'MetalKit']
  s.ios.library = 'c++', 'resolv', 'sqlite3', 'z', 'bz2'

  s.vendored_framework = 'Sources/*.framework'

end
