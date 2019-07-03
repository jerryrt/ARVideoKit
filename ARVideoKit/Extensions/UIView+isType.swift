//
//  UIView+isType.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit
import RealityKit

@available(iOS 11.0, *)
extension UIScreen {
    /**
     `isiPhone10` is a boolean that returns if the device is iPhone X or not.
     */
    var isiPhone10: Bool {
        return self.nativeBounds.size == CGSize(width: 1125, height: 2436) || self.nativeBounds.size == CGSize(width: 2436, height: 1125)
    }
}
@available(iOS 11.0, *)
extension UIView {
    var parent: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder!.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    var isButton: Bool {
        return (self is UIButton)
    }
    
    var isARView: Bool {
        if #available(iOS 13.0, *) {
            return (self is ARSCNView) || (self is ARSKView) || (self is RealityKit.ARView)
        } else {
            return (self is ARSCNView) || (self is ARSKView)
        }
    }
    
    func imageViaLayerDraw() -> UIImage? {//always black
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func imageViaViewDraw() -> UIImage? {//very slow
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let capturedImage = renderer.image {
            (ctx) in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return capturedImage
    }
}
