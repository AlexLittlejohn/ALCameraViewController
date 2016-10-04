import UIKit

extension UIView {
  func autoRemoveConstraint(_ constraint : NSLayoutConstraint?) {
    if constraint != nil {
      self.removeConstraint(constraint!)
    }
  }
}
