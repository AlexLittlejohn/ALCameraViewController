# ALCameraViewController
A camera view controller with custom image picker and image cropping. Written in Swift.

### Features

- Front facing andrear facing camera support
- Simple and clean look with smooth animations
- Custom image picker with permission checking
- Image cropping (square only)

### Installation & Requirements
This project requires Xcode 6.3 to run and compiles with swift 1.2

ALCameraViewController is available on CocoaPods. Add the following to your Podfile:

```ruby
pod 'ALCameraViewController'
```

### Usage

To use this component couldn't be simpler.

In your viewController
```swift

let croppingEnabled = true
let cameraViewController = ALCameraViewController(croppingEnabled: croppingEnabled) { image in
	// Do something with your image here. 
	// If cropping is enabled this image will be the cropped version
}

presentViewController(cameraViewController, animated: true, completion: nil)
```

## License
ALTextInputBar is available under the MIT license. See the LICENSE file for more info.