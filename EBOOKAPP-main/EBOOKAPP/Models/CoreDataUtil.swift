//
//  CoreDataUtil.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 2.02.2021.
//

import Foundation
import CoreData
import UIKit

class CoreDataUtil
{
    ///Creates IsActiveEntity with isActive bool when registering operation
    static func createEntityCoreData(isActive: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context =  appDelegate.persistentContainer.viewContext
        let newEntity = NSEntityDescription.insertNewObject(forEntityName:"IsActiveElement", into: context)
        newEntity.setValue(isActive, forKey: "isActive")
        do{try context.save()}
        catch{print("error")}
    }
    
    ///Creates user object for keeping user's data
    static func createUserCoreData(user: User)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        newUser.setValue(user.getUserId(), forKey: "userId")
        newUser.setValue(user.getLanguage(), forKey: "language")
        newUser.setValue(user.getGender(), forKey: "gender")
        newUser.setValue(user.getEmail(), forKey: "email")
        newUser.setValue(user.getCountry(), forKey: "country")
        newUser.setValue(user.getAge(), forKey: "age")
        do{try context.save()}
        catch{print("error")}
        
    }
}
