source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0’

use_frameworks!

target 'ALCameraViewController' do
pod 'ALCameraViewController', :git => 'https://github.com/cyclic/ALCameraViewController', :branch => 'develop'
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '3.2'
    end
  end
end