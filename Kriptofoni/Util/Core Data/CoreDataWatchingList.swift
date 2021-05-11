//
//  CoreDataWatchingList.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 1.05.2021.
//

import Foundation
import CoreData
import UIKit

class CoreDataWatchingList
{
    
    
    static func deleteCoinFromWatchingList(ids: [String],completionBlock: @escaping (Bool) -> Void) -> Void
    {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        getWatchingList { (array,concatedString) in
            if !array.isEmpty
            {
                var newStringToSave = "" //Our core data strings starts with
                var coreArray = array
                coreArray.remove(at: 0)
                for item in coreArray
                {
                    if !ids.contains(item) // If does not contains we don't delete so we will save it to core data again
                    {
                        newStringToSave =  newStringToSave + "," + item
                    }
                }
                let watchingList = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchingList")
                let result = try? managedObjectContext.fetch(watchingList)
                let resultData = result?[0] as! NSManagedObject
                resultData.setValue(newStringToSave, forKey: "list")
                do
                {
                    try managedObjectContext.save()
                    print("CURRENCIES ARE UPDATED TO WATCHINGLIST." + newStringToSave)
                    completionBlock(true)
                }
                catch{print("error")}
                
            }}
    }
    
    // Returns true if it adds item to watching list.
    static func addWatchingList(id: String) -> Bool
    {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        var isAdded = Bool()
        getWatchingList { (array,concatedString) in
            if array.isEmpty // Core data is not created before
            {
                let watchingList =   NSEntityDescription.insertNewObject(forEntityName: "WatchingList", into: managedObjectContext)
                let newData = "," + id
                watchingList.setValue(newData, forKey: "list")
                do
                {
                    try managedObjectContext.save()
                    print("WATCHINGLIST IS CREATED." + newData)
                }
                catch{print("error")}
                
            }
            else
            {
                if array.contains(id) // This coin is already inside of watcing list.
                {
                    isAdded = false
                }
                else
                {
                    let watchingList = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchingList")
                    let result = try? managedObjectContext.fetch(watchingList)
                    let resultData = result?[0] as! NSManagedObject
                    var newConcatString = concatedString
                    newConcatString = newConcatString + "," + id
                    resultData.setValue(newConcatString, forKey: "list")
                    do
                    {
                        try managedObjectContext.save()
                        print("CURRENCY IS SAVED TO WATCHINGLIST." + newConcatString)
                        isAdded = true
                    }
                    catch{print("error")}
                }
            }}
           return isAdded
    }
    
    static func getWatchingList(completionBlock: @escaping ([String],String) -> Void) -> Void
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchingList")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let concatedString = result.value(forKey: "list") as? String
                    {
                        let watchList = concatedString.components(separatedBy: ",") //converts string to array
                        completionBlock(watchList,concatedString)
                    }
                }
            }
            else
            {
                print("Empty Watching List...")
                let stringArray = [String]()
                completionBlock(stringArray,"")
            }
        }
        catch {print("Error: Core Data Watching List")}
    }
}
