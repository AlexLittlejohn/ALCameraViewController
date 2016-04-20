import UIKit

extension UIView {
  func autoRemoveConstraint(constraint : NSLayoutConstraint?) {
    if constraint != nil {
      self.removeConstraint(constraint!)
    }
  }
}