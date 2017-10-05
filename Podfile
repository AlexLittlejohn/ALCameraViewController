source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0’

use_frameworks!

target 'ALCameraViewController' do
pod 'Fabric'
pod 'Crashlytics'
pod 'Masonry'
pod 'SnapKit', '~> 3.2.0'
pod 'Mixpanel'
pod 'ALCameraViewController', :git => 'https://github.com/Cyclic/ALCameraViewController', :branch => 'feature/pinch-to-zoom-camera'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
  end
end
