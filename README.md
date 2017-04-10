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
This project requires Xcode 8.3 to run and compiles with swift 3.1
> Note: This library makes use of the AVFoundation camera API's which are unavailable on the iOS simulator. You'll need a real device to run it.

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

You can also instantiate the image picker component by itself as well.
```swift

let croppingEnabled = true

/// Provides an image picker wrapped inside a UINavigationController instance
let imagePickerViewController = CameraViewController.imagePickerViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
		// Do something with your image here.
	 	// If cropping is enabled this image will be the cropped version

    self?.dismiss(animated: true, completion: nil)
}

present(imagePickerViewController, animated: true, completion: nil)

```

For more control you can create it directly.
> Note: This approach requires some familiarity with the PhotoKit library provided by apple

```swift
import Photos

let imagePickerViewController = PhotoLibraryViewController()
imagePickerViewController.onSelectionComplete = { asset in

		// The asset could be nil if the user doesn't select anything
		guard let asset = asset else {
			return
		}

    // Provides a PHAsset object
		// Retrieve a UIImage from a PHAsset using
		let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true

		PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { image, _ in
        if let image = image {
						// Do something with your image here
        }
    }
}

present(imagePickerViewController, animated: true, completion: nil)

```


## License
ALCameraViewController is available under the MIT license. See the LICENSE file for more info.
