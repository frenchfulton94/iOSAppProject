//
//  UniversalLibrary.swift
//  MyMC
//
//  Created by Joe  Riess on 5/24/16.
//  Copyright © 2016 Manhattan College. All rights reserved.
//

import UIKit
import ReachabilitySwift
import Foundation
import ObjectiveC
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class UniversalLibrary {
    

    
    static var currentViewController: UIViewController!
    var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
 
    internal static func noConnection(_ vc: UIViewController) {
        if vc.view.viewWithTag(69) == nil {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let connectionVC = storyboard.instantiateViewController(withIdentifier: "noConnectionVC") as! noConnectionViewController
        
        vc.addChildViewController(connectionVC)
        
        let connectionView = connectionVC.view
        let gesture = UITapGestureRecognizer(target: vc, action: #selector(vc.viewDidLoad))
        
        connectionView?.isHidden = true
        connectionView?.addGestureRecognizer(gesture)
        connectionView?.tag = 69
        vc.view.addSubview(connectionView!)
            vc.view.bringSubview(toFront: vc.view.viewWithTag(69)!)
        } else {
            for bitches in vc.childViewControllers {
                if bitches.title == "noConnectionVC" {
                    print("dope")
                    bitches.viewDidLoad()
                }
            }
            
        }
        
    }
   
    static func convertSpecialCharacters(_ string: String) -> String {
        let encodedData = string.data(using: String.Encoding.utf8)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue) as AnyObject
        ]
        var attributedString: NSAttributedString!
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            
        }
        let decodedString = attributedString.string
        return decodedString
    }
  
}




class uniNavViewController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for vc in viewControllers {
            addMenuButton(vc.navigationItem)
            for button in vc.navigationController!.navigationBar.subviews
            {
                button.isExclusiveTouch = true
            }
            
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        addMenuButton(viewController.navigationItem)
        super.pushViewController(viewController, animated: animated)
        for button in viewController.navigationController!.navigationBar.subviews
        {
            button.isExclusiveTouch = true
        }
    }
 
    func addMenuButton(_ item: UINavigationItem){
        if item.rightBarButtonItem == nil {
            let button = UIBarButtonItem()
            button.title = " "
            button.image = UIImage(named: "hamburgerSmall(gray)")
            button.target = self
            button.action = #selector(addMenu)
            item.rightBarButtonItem = button
            
        }
    }
    
    
    func addMenu() {
       
        let main = UIScreen.main.bounds
       
        visibleViewController!.navigationItem.leftBarButtonItems = nil
        if visibleViewController!.navigationItem.rightBarButtonItems?.count > 1 {
        visibleViewController!.navigationItem.rightBarButtonItems!.removeLast()
        }

        if visibleViewController!.view.viewWithTag(21) == nil  {
            
            visibleViewController!.navigationItem.setHidesBackButton(true, animated: false)
            //print(visibleViewController!.childViewControllers[0])
            if visibleViewController!.title == "HOME" && visibleViewController!.childViewControllers[0].title == "SEARCH" {
                print("first")
                visibleViewController!.childViewControllers[0].view.endEditing(true)
               
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menuVC = storyboard.instantiateViewController(withIdentifier: "Menu") as! mainMenuViewController
            
            
            visibleViewController!.addChildViewController(menuVC)
            let temp = menuVC.view
            
            temp?.frame = CGRect(x: 0, y: -main.height , width: (temp?.frame.width)!, height: (temp?.frame.height)! + 304)
            temp?.center = CGPoint(x:main.width/2 , y: -main.height/2)
            temp?.tag = 21 
            visibleViewController!.view.addSubview(temp!)
            visibleViewController!.view.didAddSubview(temp!)
            visibleViewController!.view.bringSubview(toFront: visibleViewController!.view.viewWithTag(21)!)
            
            print("blue")
            animateMenu()
            
            
        } else {
 
            print(visibleViewController!.childViewControllers)
            if visibleViewController!.title == "HOME" && visibleViewController!.childViewControllers[0].title == "SEARCH" {
                print("second")
                if (visibleViewController!.childViewControllers[0] as! SearchViewController).MCShieldImageView.alpha == 0.0 {
                       visibleViewController!.childViewControllers[0].navigationController?.navigationBar.backgroundColor = Colors.Grey.light
                }
             
            }

                UIView.setAnimationBeginsFromCurrentState(true)
                visibleViewController!.animator.removeAllBehaviors()
          
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                    
                    
                    self.visibleViewController!.view.viewWithTag(21)!.center = CGPoint(x:main.width/2 , y: -main.height)
                    }, completion: {
                        void in
                        if self.viewControllers.count > 1 {
                            self.visibleViewController!.navigationItem.setHidesBackButton(false, animated: false)
                        }
                        if self.visibleViewController != self.viewControllers[0] {
                            self.visibleViewController!.viewWillAppear(false)
                        }
                        for vc in self.visibleViewController!.childViewControllers {
                            if vc.title == "Menu" {
                                print("jeeps")
                                vc.removeFromParentViewController()
                                self.visibleViewController!.view.viewWithTag(21)!.removeFromSuperview()
                                
                            } else {
                                vc.viewWillAppear(false)
                            }
                            
                        }
                       
                })
        }
    }
    
    func animateMenu() {
        let main = visibleViewController!.view.frame
        
        visibleViewController!.animator = UIDynamicAnimator(referenceView: visibleViewController!.view)
        let anchor = CGPoint(x:main.width/2 , y: -main.height)
        let mainView = visibleViewController!.view
        let gravity = UIGravityBehavior(items:[(mainView?.viewWithTag(21)!)!])
        gravity.magnitude = 15.0
        let attachement = UIAttachmentBehavior(item: (mainView?.viewWithTag(21)!)!, attachedToAnchor: anchor)
        attachement.length =  main.height + (main.height/2.12)
        attachement.damping = 0.6
        attachement.frequency = 2.7
        
        
        if visibleViewController!.animator.behaviors.count == 0 {
            visibleViewController!.animator.addBehavior(gravity)
            visibleViewController!.animator.addBehavior(attachement)
            
        }
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

var AssociatedObjectHandle:UIDynamicAnimator? = nil

protocol animate {
    var animator: UIDynamicAnimator! { get set }
}

extension UIViewController {
    
    
    var animator: UIDynamicAnimator! {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? UIDynamicAnimator
        }
        set{
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue as UIDynamicAnimator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
}

