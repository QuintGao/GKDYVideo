source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

target 'GKDYVideo' do
  use_frameworks!

  pod 'AFNetworking'
  pod 'SDWebImage'
  pod 'Masonry'
  pod 'YYModel'
  pod 'GKNavigationBar'
  pod 'TXLiteAVSDK_Player'  # 腾讯云播放器-独立播放器
  pod 'MJRefresh'
  pod 'GKPageScrollView'
  pod 'JXCategoryView'

end

post_install do |installer|
  # 消除版本警告
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
