Pod::Spec.new do |spec|
  spec.name               = "ALCameraViewController"
  spec.version            = "1.2.6"
  spec.summary            = "A camera view controller with custom image picker and image cropping. Written in Swift."
  spec.source             = { :git => "https://github.com/AlexLittlejohn/ALCameraViewController.git", :tag => spec.version.to_s }
  spec.requires_arc       = true
  spec.platform           = :ios, "9.0"
  spec.license            = "MIT"
  spec.source_files       = "ALCameraViewController/**/*.{swift}"
  spec.resources          = ["ALCameraViewController/ViewController/ConfirmViewController.xib", "ALCameraViewController/CameraViewAssets.xcassets", "ALCameraViewController/CameraView.strings"]
  spec.homepage           = "https://github.com/AlexLittlejohn/ALCameraViewController"
  spec.author             = { "Alex Littlejohn" => "alexlittlejohn@me.com" }
end
