Pod::Spec.new do |spec|
  spec.name               = "ALCameraViewController-Tulleb"
  spec.version            = "3.1"
  spec.summary            = "A camera view controller with custom image picker and image cropping."
  spec.source             = { :git => "https://github.com/Tulleb/ALCameraViewController.git", :tag => spec.version.to_s }
  spec.requires_arc       = true
  spec.platform           = :ios, "9.0"
  spec.license            = "MIT"
  spec.source_files       = "ALCameraViewController/**/*.{swift}"
  spec.resources          = ["ALCameraViewController/ViewController/ConfirmViewController.xib", "ALCameraViewController/CameraViewAssets.xcassets", "ALCameraViewController/CameraView.strings"]
  spec.homepage           = "https://github.com/Tulleb/ALCameraViewController"
  spec.author             = { "Alex Littlejohn" => "alexlittlejohn@me.com", "Guillaume Bellut" => "guillaume@bellut.com" }
  spec.swift_version      = '5.0'
end
