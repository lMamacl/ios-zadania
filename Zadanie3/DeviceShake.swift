import SwiftUI
import UIKit

extension NSNotification.Name {
    public static let deviceDidShakeNotification = NSNotification.Name("DeviceShakeNotification")
}

// SwiftUI has no shake API, so UIWindow forwards the shake as a notification.
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
        }
    }
}
