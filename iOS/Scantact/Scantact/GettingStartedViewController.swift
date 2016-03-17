//
//  GettingStartedViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 2/17/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit

class GettingStartedViewController: UIViewController {
    
    
    @IBOutlet weak var gettingStartedMessage: UILabel!
    @IBOutlet weak var gettingStartedImage: UIImageView!
    
    var pageIndex: Int?
    var titleText : String!
    var imageName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gettingStartedImage.image = UIImage(named: imageName)
        self.gettingStartedMessage.text = self.titleText
        self.gettingStartedMessage.alpha = 0.1
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.gettingStartedMessage.alpha = 1.0
        })
        
    }
    
}
