Pod::Spec.new do |spec|
  spec.name               = "ALCameraViewController"
  spec.version            = "4.0.0"
  spec.summary            = "A camera view controller with custom image picker and image cropping."
  spec.source             = { :git => "https://github.com/uncledoc/ALCameraViewController.git", :tag => spec.version.to_s }
  spec.requires_arc       = true
  spec.platform           = :ios, "10.0"
  spec.license            = "MIT"
  spec.source_files       = "ALCameraViewController/**/*.{swift}"
  spec.resources          = ["ALCameraViewController/ViewController/ConfirmViewController.xib", "ALCameraViewController/CameraViewAssets.xcassets", "ALCameraViewController/CameraView.strings"]
  spec.homepage           = "https://github.com/uncledoc/ALCameraViewController"
  spec.author             = { "Alex Littlejohn" => "alexlittlejohn@me.com" }
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end
