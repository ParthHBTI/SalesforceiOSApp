//
//  NonMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 1/22/15.
//  Copyright (c) 2015 Yuji Hato. All rights reserved.
//

import UIKit

import SalesforceRestAPI
import SalesforceSDKCore
class NonMenuController: UIViewController,SFRestDelegate {
    
    weak var delegate: LeftMenuProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.handleSdkManagerLogout()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.removeNavigationBarItem()
    }
  
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard let vc = (self.slideMenuController()?.mainViewController as? UINavigationController)?.topViewController else {
                return
            }
            if vc.isKindOfClass(NonMenuController)  {
                self.slideMenuController()?.removeLeftGestures()
                self.slideMenuController()?.removeRightGestures()
            }
        })
    }
  
    @IBAction func didTouchToMain(sender: UIButton) {
        delegate?.changeViewController(LeftMenu.Main)
    }
   
}
