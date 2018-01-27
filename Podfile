use_frameworks!

target 'RxMVVM+Texture' do
pod 'Texture'
pod 'SnapKit'
pod 'RxSwift'
pod 'RxCocoa'
pod 'RxAlamofire'
pod 'RxASControlEvent'
pod 'MBProgressHUD'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
