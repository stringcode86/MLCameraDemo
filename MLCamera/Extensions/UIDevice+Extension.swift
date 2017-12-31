//
//  UIDevice+Extension.swift
//  MLCamera
//
//  Created by Michael Inger on 13/06/2017.
//  Copyright © 2017 stringCode ltd. All rights reserved.
//

import UIKit
import AVFoundation

func orientation(videoOrientation: AVCaptureVideoOrientation, deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
	switch deviceOrientation {
	case .unknown:
		return videoOrientation
	case .portrait:
		// Device oriented vertically, home button on the bottom
		return .portrait
	case .portraitUpsideDown:
		// Device oriented vertically, home button on the top
		return .portraitUpsideDown
	case .landscapeLeft:
		// Device oriented horizontally, home button on the right
		return .landscapeRight
	case .landscapeRight:
		// Device oriented horizontally, home button on the left
		return .landscapeLeft
	case .faceUp:
		// Device oriented flat, face up
		return videoOrientation
	case .faceDown:
		// Device oriented flat, face down
		return videoOrientation
	}
}

extension UIDevice {

    /// Subscribes target to default NotificationCenter .UIDeviceOrientationDidChange
    class func subscribeToDeviceOrientationNotifications(_ target: AnyObject, selector: Selector) {
        let center = NotificationCenter.default
        let name =  NSNotification.Name.UIDeviceOrientationDidChange
        let selector = selector
        center.addObserver(target, selector: selector, name: name, object: nil)
    }
}
