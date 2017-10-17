//
//  File.swift
//  MyMC
//
//  Created by Joe  Riess on 6/2/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

//import Foundation
//import pop
//
//class Animations {
//    
//    internal static func makeItBounceHeavy(view: UIView) {
//        let rect = view.layer.bounds
//        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
//        bounceAnimation.fromValue = NSValue(CGRect: CGRectMake(0, 0, 75, 75))
//        bounceAnimation.toValue = NSValue(CGRect: rect)
//        bounceAnimation.springBounciness = 20
//        view.layer.pop_addAnimation(bounceAnimation, forKey: "bounce")
//    }
//    
//    internal static func makeItBounceLight(view: UIView) {
//        let rect = view.layer.bounds
//        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPLayerBounds)
//        bounceAnimation.fromValue = NSValue(CGRect: CGRectMake(0, 0, 25, 25))
//        bounceAnimation.toValue = NSValue(CGRect: rect)
//        bounceAnimation.springBounciness = 15
//        view.layer.pop_addAnimation(bounceAnimation, forKey: "bounce")
//    }
//    
//}