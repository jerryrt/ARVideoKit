//
//  UIViewController+hasType.swift
//  AR Video
//
//  Created by Ahmed Bekhit on 10/18/17.
//  Copyright © 2017 Ahmed Fathi Bekhit. All rights reserved.
//

import UIKit
import ARKit
#if canImport(RealityKit)
import RealityKit
#endif

@available(iOS 11.0, *)
extension UIViewController {
    var hasARView: Bool {
        let views = self.view.subviews
        for v in views {
            if #available(iOS 13.0, *) {
                if v is ARSCNView || v is ARSKView || v is RealityKit.ARView {
                    return true
                }
            } else {
                if v is ARSCNView || v is ARSKView  {
                    return true
                }
            }
        }
        return false
    }
}
