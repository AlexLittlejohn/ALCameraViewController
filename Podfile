source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0’

use_frameworks!

target 'ALCameraViewController' do
pod 'Fabric'
pod 'Crashlytics'
pod 'Masonry'
pod 'SnapKit'
pod 'Mixpanel'
pod 'ALCameraViewController', :git => 'https://github.com/Cyclic/ALCameraViewController', :branch => 'develop'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end
