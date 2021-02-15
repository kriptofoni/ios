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
    
    
    
    
    ///Creates user object for keeping user's data
    static func createUserCoreData(user: CurrentUser)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: context)
        newUser.setValue(user.getUserId(), forKey: "userId")
        newUser.setValue(user.getGender(), forKey: "gender")
        newUser.setValue(user.getEmail(), forKey: "email")
        newUser.setValue(user.getCountry(), forKey: "country")
        newUser.setValue(user.getAge(), forKey: "age")
        newUser.setValue(user.getIsActive(), forKey: "isActive")
        newUser.setValue(user.getCurrentBookId(), forKey: "currentBookId")
        do{
            try context.save()
            print("SAVED")
            print(CoreDataUtil.numberOfCoreUser())
            print(CoreDataUtil.getCurrentUser().toString())
            
        }
        catch{print("error")}
    }
    
    
    static func getCurrentUser() -> CurrentUser
    {
        var currentUser = CurrentUser()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                
                for result in results as! [NSManagedObject]
                {
                    if let userId = result.value(forKey: "userId") as? String
                    {
                        currentUser.setUserId(userId: userId)
                    }
                    if let gender = result.value(forKey: "gender") as? String
                    {
                        currentUser.setGender(gender: gender)
                    }
                    if let email = result.value(forKey: "email") as? String
                    {
                        currentUser.setEmail(email: email)
                    }
                    if let country = result.value(forKey: "country") as? String
                    {
                        currentUser.setCountry(country: country)
                    }
                    if let age = result.value(forKey: "age") as? String
                    {
                        currentUser.setAge(age: age)
                    }
                    if let isActive = result.value(forKey: "isActive") as? Bool
                    {
                        currentUser.setIsActive(isActive: isActive)
                    }
                    if let currentBookId = result.value(forKey: "currentBookId") as? String
                    {
                        currentUser.setCurrentBookId(currentBookId: currentBookId)
                    }
                }
            }
        }
        catch
        {
            print("There is a error")
        }
        return currentUser
    }
    
    ///Removes user from core data
    static func removeUserFromCoreData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do
        {
            try context.execute(deleteRequest)
        }
        catch let error as NSError {
            // TODO: handle the error
            print(error.localizedDescription)
        }
    }
    
    ///Sets true or false to isActive bool
    static func updateCurrentUserOnAccount(age: String, country: String, gender:String){
        var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let result = try? managedObjectContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            object.setValue(age, forKey: "age")
            object.setValue(country, forKey: "country")
            object.setValue(gender, forKey: "gender")
        }
        do
        {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    ///Update user's current book id
    static func updateCurrentUserBookId(currentBookId : String)
    {
        var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let result = try? managedObjectContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            object.setValue(currentBookId, forKey: "currentBookId")
        }
        do
        {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /// Returns number of current usser for an error
    static func numberOfCoreUser() -> Int
    {
        var currentUserNumber = Int()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            currentUserNumber = results.count
        }
        catch
        {
            print("There is a error")
        }
        return currentUserNumber
    }
    
    static func getDocFromLibraryDirectory(id : String) -> URL
    {
       
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //https://www.youtube.com/watch?v=asB8PIveZsI&ab_channel=TheSwiftGuy
        //
        
    }
    
    
}
