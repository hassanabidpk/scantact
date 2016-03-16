//
//  FirstViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 2/16/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:  helper methods
    
    func getUserDetails()  {
        let strToken = NSUserDefaults.standardUserDefaults().stringForKey("userToken")
        if let strToken = strToken {
            
            let authToken = "Token \(strToken)"
            print("get userDetails with token: \(authToken)")
//            Token 45c0e9ef9b08d64315e1bed91e005663414bef78
            let headers = [
                "Authorization": authToken
            ]
        
            Alamofire.request(.GET, "http://localhost:8000/rest-auth/user", headers: headers, encoding: .JSON)
                .responseJSON { response in
                    
                    debugPrint(response)
                
                
                    if let userDetails = response.result.value {
                        let json = JSON(userDetails)
                        if let first_name = json["first_name"].string {
                
                            print("token: \(json) with firstName: \(first_name)")

                        } else {
                            print("login failed \(userDetails)")
                    }
                    
                }
                
            }
        }
        
        
        

    
    }

}

