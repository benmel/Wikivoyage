//
//  NavigationController.swift
//  Wikivoyage
//
//  Created by Ben Meline on 10/9/15.
//  Copyright (c) 2015 Ben Meline. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    // Need this to avoid WKActionSheet error
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let vc = presentedViewController {
            vc.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}
