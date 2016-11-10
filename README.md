# ALCameraViewController
A camera view controller with custom image picker and image cropping. Written in Swift.

![camera](https://cloud.githubusercontent.com/assets/932822/8455694/c61de812-2006-11e5-85c0-a57e3d980561.jpg)
![cropper](https://cloud.githubusercontent.com/assets/932822/8455697/c627ac44-2006-11e5-82be-7f96e73d9b1f.jpg)
![library](https://cloud.githubusercontent.com/assets/932822/8455695/c620ebb6-2006-11e5-9c61-75a81870c9de.jpg)
![permissions](https://cloud.githubusercontent.com/assets/932822/8455696/c62157fe-2006-11e5-958f-849cabf541ca.jpg)

### Features

- Front facing and rear facing camera support
- Simple and clean look
- Custom image picker with permission checking
- Image cropping (square only)
- Flash light support

### Installation & Requirements
This project requires Xcode 8 to run and compiles with swift 3.0

ALCameraViewController is available on CocoaPods. Add the following to your Podfile:

```ruby
pod 'ALCameraViewController'
```

### Usage

To use this component couldn't be simpler.
Add `import ALCameraViewController` to the top of you controller file.

In the viewController
```swift

let croppingEnabled = true
let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
	// Do something with your image here.
	// If cropping is enabled this image will be the cropped version

	self?.dismiss(animated: true, completion: nil)
}

present(cameraViewController, animated: true, completion: nil)
```

## License
ALCameraViewController is available under the MIT license. See the LICENSE file for more info.
