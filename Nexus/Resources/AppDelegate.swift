//
//  AppDelegate.swift
//  Nexus
//
//  Created by Clifford Yin on 1/11/18.
//  Copyright © 2018 Clifford Yin. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import Alamofire
import NotificationBannerSwift

extension String {
    /*
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     - Parameter length: Desired maximum lengths of a string
     - Parameter trailing: A 'String' that will be appended after the truncation.
     
     - Returns: 'String' object.
     */
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? String(self.prefix(length)) : self
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    ///
    var restrictRotation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        print("IQKeyboard")
        Reachability.shared.reachabilityManager?.startListening()
        return true
    }

    ///
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
//        switch UIDevice.current.orientation {
//
//        }
        
        print("return orientation")
        //ItemFrames.shared.rotate()
        return self.restrictRotation
    }
    
    func listenForNetwork() {
        Reachability.shared.reachabilityManager?.startListening()
    }
    
    //
    // Now test what happens for unsecure network
    func checkConnection() {
        
        let task = DispatchWorkItem {
            print("TASK RUN")
            if Reachability.shared.reachabilityManager?.networkReachabilityStatus == Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.reachable(NetworkReachabilityManager.ConnectionType.ethernetOrWiFi) {
                    if Reachability.shared.warningBanner.isDisplaying == false {
                        Reachability.shared.dangerBanner.dismiss()
                        Reachability.shared.warningBanner.show()
                        }
                }
            return
        }
        
        // execute task in 5 seconds
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: task)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                task.cancel()
                print("task canceled?: \(task.isCancelled)")
            })
            
        })
        
        
        let strURL = APIKeys.shared.baseURL
        Alamofire.request(strURL,
                          method: .head,
                          parameters: nil)
            .validate()
            .responseJSON { response in
                // Put an async await for the response
                print("Check connection response: \(response)")
                guard response.result.isSuccess else {
                    
                    // TODO: Refactor everything and make neat
                    print("Alamofire error: \(String(describing: response.result.error!))")
                    if String(describing: response.result.error!).trunc(length: 65) == """
                        Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."
                        """ {
                            print("Unsecure parsed")
                            if task.isCancelled == false {
                                print("Not secure")
                                Reachability.shared.dangerBanner.dismiss()
                                Reachability.shared.warningBanner.show()
                            }
                        } else if String(describing: response.result.error!).trunc(length: 117) == "responseValidationFailed(reason: Alamofire.AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 401))" {
                            print("Internet")
                            task.cancel()
                            Reachability.shared.warningBanner.dismiss()
                            Reachability.shared.dangerBanner.dismiss()
                            Reachability.shared.successBanner.show()
                    }
                    return
                }
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Nexus", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Los Altos Hacks.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}



