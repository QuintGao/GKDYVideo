Pod::Spec.new do |s|
  s.name             = 'RedPlayer'
  s.version          = '0.0.1'
  s.summary          = 'RedPlayer'
  s.description      = 'RedPlayer SDK'
  s.homepage         = 'https://github.com/RTE-Dev/RedPlayer/source/ios/XYRedPlayer/Submodules/RedPlayer'
  s.license          = { :type => 'LGPL', :file => 'LICENSE' }
  s.author           = { 'zijie' => 'zijie@xiaohongshu.com' }
  s.source           = { :git => 'git@github.com/RTE-Dev/RedPlayer.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.resources = "RedPlayer/Resouces/**.*"
  s.vendored_framework = 'RedPlayer/Sources/*.framework'
  
  s.dependency "XYMediaFfmpeg"
  # s.dependency "opensoundtouch"

end
