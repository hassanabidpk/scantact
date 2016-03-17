//
//  MainViewController.swift
//  Scantact
//
//  Created by Hassan Abid on 2/17/16.
//  Copyright © 2016 Hassan Abid. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    let pageTitles = ["Get in touch", "Share with ease!"]
    var images = ["gettingStarted2.png","gettingStarted1.png"]
    var count = 0
    
    var pageViewController : UIPageViewController!
    
    @IBAction func swipeLeft(sender: AnyObject) {
        print("SWipe left")
    }
    @IBAction func swiped(sender: AnyObject) {
        
        self.pageViewController.view .removeFromSuperview()
        self.pageViewController.removeFromParentViewController()
        reset()
    }
    
    func reset() {
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        /* We are substracting 30 because we have a start again button whose height is 30*/
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 30)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    @IBAction func start(sender: AnyObject) {
        let pageContentViewController = self.viewControllerAtIndex(0)
        self.pageViewController.setViewControllers([pageContentViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Main | ViewWillAppear")

        let strToken = NSUserDefaults.standardUserDefaults().stringForKey("userToken")
        if let _ = strToken {
            print("user logged in already with token:")
            let tabController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeTabBarViewController") as! HomeTabBarViewController
            let appDelegate = UIApplication.sharedApplication().delegate

            let navigationViewController = UINavigationController(rootViewController: tabController)
            let logoutButton = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: nil, action: "actionLogoutUser:")
            logoutButton.tintColor = UIColor.blackColor()
            navigationViewController.navigationItem.leftBarButtonItem = logoutButton
            
            appDelegate?.window??.rootViewController = navigationViewController
            
            
        }
        else {
         reset()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Main | ViewWillAppear")
    }
    
    func actionLogoutUser(sender:UIBarButtonItem) {
        print("logout")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! GettingStartedViewController).pageIndex!
    index++
    if(index >= self.images.count){
    return nil
    }
    return self.viewControllerAtIndex(index)
    
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    
    var index = (viewController as! GettingStartedViewController).pageIndex!
    if(index <= 0){
    return nil
    }
    index--
    return self.viewControllerAtIndex(index)
    
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
    if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
    return nil
    }
    let gettingStartedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GettingStartedViewController") as! GettingStartedViewController
    
    gettingStartedViewController.imageName = self.images[index]
    gettingStartedViewController.titleText = self.pageTitles[index]
    gettingStartedViewController.pageIndex = index
    return gettingStartedViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
    }
    
    
}