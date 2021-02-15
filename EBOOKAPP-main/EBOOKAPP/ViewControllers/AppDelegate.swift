//
//  AppDelegate.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 28.01.2021.
//

import UIKit
import Firebase
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var isActiveArray = [Bool]()
    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = { //Implemantation of core data

        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        if SYSTEM_VERSION_LESS_THAN(version: "13.0")
        {
            print("ios13.0 lower")
            let currentUser = Auth.auth().currentUser
            print("Core Data User Sayısı")
            print(CoreDataUtil.numberOfCoreUser())
            if currentUser != nil
            {
                if CoreDataUtil.getCurrentUser().getIsActive()
                {
                    let board = UIStoryboard(name: "Main", bundle: nil)
                    var openViewController = board.instantiateViewController(withIdentifier: "first") as! UIViewController
                    self.window?.rootViewController = openViewController
                }
                else//logout yap
                {
                    do
                    {
                        try Auth.auth().signOut()
                        CoreDataUtil.removeUserFromCoreData()
                    }
                    catch{print("error")}
                }
            }
            else
            {
                print("There is no user.")
            }
        
        }
           
        return true
    }
    
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version,
         options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

