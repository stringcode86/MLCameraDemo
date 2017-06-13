//
//  UIDevice+Extension.swift
//  MLCamera
//
//  Created by Michael Inger on 13/06/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDevice {
    
    /// Vidoe orientation for current device orientation
    var videoOrientation: AVCaptureVideoOrientation {
        let orientation: AVCaptureVideoOrientation
        switch self.orientation {
        // Device oriented vertically, home button on the bottom
        case .portrait: orientation = .portrait
        // Device oriented vertically, home button on the top
        case .portraitUpsideDown: orientation = .portraitUpsideDown
        // Device oriented horizontally, home button on the right
        case .landscapeLeft: orientation = .landscapeRight
        // Device oriented horizontally, home button on the left
        case .landscapeRight: orientation = .landscapeLeft
        // Device oriented flat, face up, Device oriented flat, face down
        default: orientation = .portrait
        }
        return orientation
    }
    
    /// Subscribes target to default NotificationCenter .UIDeviceOrientationDidChange
    class func subscribeToDeviceOrientationNotifications(_ target: AnyObject, selector: Selector) {
        let center = NotificationCenter.default
        let name =  NSNotification.Name.UIDeviceOrientationDidChange
        let selector = selector
        center.addObserver(target, selector: selector, name: name, object: nil)
    }
}
