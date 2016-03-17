//
//  HomeTabBarViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 3/14/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit

class HomeTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("HomeTabBarViewController - viewDidLoad")
        self.delegate = self
        self.selectedIndex = 2
        tabBarController(self, didSelectViewController: self.selectedViewController!)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if(viewController.isKindOfClass(ProfileViewController)) {
            print("profileviewcontroller")
        }
    }
}
