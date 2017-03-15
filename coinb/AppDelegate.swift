//
//  AppDelegate.swift
//  coinb
//
//  Created by Hieu Nguyen on 3/11/17.
//  Copyright © 2017 FoodCompass. All rights reserved.
//

import UIKit
import CoreData
import coinbase_official

let COINBASE_CLIENT_ID = "0f303e77ab3f6b254c43f583473fd5936fe0a52c6a557909913aabead9184810"
let COINBASE_CLIENT_SECRET = "83ee2ee68a866639c2f06cdc8e02f34167757c3e24927ba2f00e90233bbede8a"
let COINBASE_SCHEME = "com.hugohn.coinb.coinbase-oauth"
let COINBASE_REDIRECT_URI = "com.hugohn.coinb.coinbase-oauth://coinbase-oauth"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //CoinbaseOAuth.startAuthentication(withClientId: COINBASE_CLIENT_ID, scope: "", redirectUri: COINBASE_REDIRECT_URI, meta: nil)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let hamburgerStoryboard = UIStoryboard(name: "Hamburger", bundle: nil)
        let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let newsfeeedStoryboard = UIStoryboard(name: "Newsfeed", bundle: nil)
        
        let hamburgerVC = hamburgerStoryboard.instantiateViewController(withIdentifier: "HamburgerViewController") as! HamburgerViewController
        let menuVC = menuStoryboard.instantiateViewController(withIdentifier: "MenuViewController")
        
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
        let newsfeedVC = newsfeeedStoryboard.instantiateViewController(withIdentifier: "NewsfeedViewController")
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeVC, newsfeedVC]
        
        hamburgerVC.menuViewController = menuVC
        hamburgerVC.contentViewController = tabBarController
        
        window?.rootViewController = hamburgerVC
        window?.makeKeyAndVisible()
        
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == COINBASE_SCHEME {
            CoinbaseOAuth.finishAuthentication(for: url, clientId: COINBASE_CLIENT_ID, clientSecret: COINBASE_CLIENT_SECRET, completion: { (result: Any?, error: Error?) in
                if error != nil {
                    // Could not authenticate.
                } else {
                    // Tokens successfully obtained!
                    // Do something with them (store them, etc.)
                    if let result = result as? [String : AnyObject] {
                        if let accessToken = result["access_token"] as? String {
                            ApiClient.sharedInstance.setupCoinbaseAccessToken(oAuthAccessToken: accessToken)
                        }
                    }
                    // Note that you should also store 'expire_in' and refresh the token using CoinbaseOAuth.getOAuthTokensForRefreshToken() when it expires
                }
            })
            return true
        }
        else {
            return false
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "coinb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

