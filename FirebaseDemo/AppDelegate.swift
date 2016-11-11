//
//  AppDelegate.swift
//  FirebaseDemo
//
//  Created by Quang Minh Trinh on 8/11/16.
//  Copyright © 2016 Quang Minh Trinh. All rights reserved.
//

import UIKit
import CoreData
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isLoggedIn: Bool? = false
    var user: User?
    var authenticateListener: FIRAuthStateDidChangeListenerHandle?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        FIRAnalytics.logEventWithName(kFIREventSignUp, parameters: [
            :])
//        NSNotificationCenter.defaultCenter().addObserver(self,
//                                                         selector: #selector(tokenRefreshNotification(_:)),
//                                                         name: kFIRInstanceIDTokenRefreshNotification,
//                                                         object: nil)
        // Override point for customization after application launch.
        if let isLoggedIn = NSUserDefaults.standardUserDefaults().valueForKey("isLoggedIn") as? Bool {
            if isLoggedIn == true {
                let user = FIRAuth.auth()?.currentUser
                let email = NSUserDefaults.standardUserDefaults().valueForKey("email") as? String
                let password = NSUserDefaults.standardUserDefaults().valueForKey("password") as? String
                let credential = FIREmailPasswordAuthProvider.credentialWithEmail(email!, password: password!)
                user?.reauthenticateWithCredential(credential, completion: { error in
                    if let error = error {
                        //
                        if self.authenticateListener != nil {
                            FIRAuth.auth()?.removeAuthStateDidChangeListener(self.authenticateListener!)
                        }
                        
                        print(error)
                        self.isLoggedIn = false
                        NSUserDefaults.standardUserDefaults().setBool(self.isLoggedIn!, forKey: "isLoggedIn")
                        if let rootViewController = self.window?.rootViewController as? ViewController {
                            rootViewController.view.hidden = false
                            if let navigationController = rootViewController.presentedViewController as? UINavigationController {
                                navigationController.dismissViewControllerAnimated(true, completion: nil)
                            }
                            else {
                            }
                        }
                    } else {
                        self.user = User(id: (user?.uid)!, email: (user?.email)!)
                        self.authenticateListener = self.addLitener()
                        if let rootViewController = self.window?.rootViewController as? ViewController {
                            if (rootViewController.presentedViewController as? UINavigationController) != nil {
                                rootViewController.view.hidden = false
                            }
                            else {
                                let workListNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WorkListNavigationController") as? UINavigationController
                                rootViewController.presentViewController(workListNavigationController!, animated: true, completion: {
                                    rootViewController.view.hidden = false
                                })
                            }
                        }
                    }
                
                })
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        
//        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
//    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Quang-Minh-Trinh.FirebaseDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FirebaseDemo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        // NOTE: It can be nil here
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        
        //connectToFcm()
    }
    func addLitener() -> FIRAuthStateDidChangeListenerHandle {
        return (FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.user = User(id: user.uid, email: user.email!)
                self.isLoggedIn = true
                NSUserDefaults.standardUserDefaults().setBool(self.isLoggedIn!, forKey: "isLoggedIn")
                NSUserDefaults.standardUserDefaults().setValue(self.user!.id, forKey: "uid")
                NSUserDefaults.standardUserDefaults().setValue(self.user!.email, forKey: "email")
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    if (rootViewController.presentedViewController as? UINavigationController) != nil {
                    }
                    else {
                        let workListNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WorkListNavigationController") as? UINavigationController
                        rootViewController.presentViewController(workListNavigationController!, animated: true, completion: {
                            rootViewController.view.hidden = false
                        })
                    }
                }
            }
            else {
                self.user = nil
                self.isLoggedIn = false
                NSUserDefaults.standardUserDefaults().setBool(self.isLoggedIn!, forKey: "isLoggedIn")
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    if let navigationController = rootViewController.presentedViewController as? UINavigationController {
                        navigationController.dismissViewControllerAnimated(true, completion: nil)
                        rootViewController.view.hidden = false
                    }
                    else {
                        rootViewController.view.hidden = false
                    }
                }
            }
        }))!
    }
    /*
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
 */

}

