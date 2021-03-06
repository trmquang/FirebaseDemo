//
//  ViewController.swift
//  FirebaseDemo
//
//  Created by Quang Minh Trinh on 8/11/16.
//  Copyright © 2016 Quang Minh Trinh. All rights reserved.
//

import UIKit
import Firebase
class ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        if let isLoggedIn = NSUserDefaults.standardUserDefaults().valueForKey("isLoggedIn") as? Bool{
            appDelegate.isLoggedIn = isLoggedIn
            if appDelegate.isLoggedIn == true {
                view.hidden = true
            }
            
            
            
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
//        if let isLoggedIn = NSUserDefaults.standardUserDefaults().valueForKey("isLoggedIn") as? Bool{
//            appDelegate.isLoggedIn = isLoggedIn
//            if appDelegate.isLoggedIn == true {
//                if let user = FIRAuth.auth()?.currentUser {
//                    // User is signed in.
//                    appDelegate.user = User(id: user.uid, email: user.email!)
//                    let workListNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WorkListNavigationController") as? UINavigationController
//                    self.presentViewController(workListNavigationController!, animated: true, completion: {
//                        self.view.hidden = false
//                    })
//                } else {
//                    // No user is signed in.
//                    self.view.hidden = false
//                }
//            }
//        }
    }

    // MARK: - IBAction
    
    @IBAction func loginBtn_TouchUpInside(sender: UIButton) {
        FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error == nil {
                self.appDelegate.user = User(id: user!.uid, email: user!.email!)
                self.appDelegate.isLoggedIn = true
                NSUserDefaults.standardUserDefaults().setBool(self.appDelegate.isLoggedIn!, forKey: "isLoggedIn")
                NSUserDefaults.standardUserDefaults().setValue(self.appDelegate.user!.id, forKey: "uid")
                NSUserDefaults.standardUserDefaults().setValue(self.appDelegate.user!.email, forKey: "email")
                NSUserDefaults.standardUserDefaults().setValue(self.passwordTextField.text, forKey: "password")
                
                let destinationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WorkListNavigationController") as? UINavigationController
                self.presentViewController(destinationVC!, animated: true, completion: {
                    self.appDelegate.authenticateListener = self.appDelegate.addLitener()
                })
            }
            else {
                print(error?.localizedDescription)
            }
        })
    }
}

