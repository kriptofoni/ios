//
//  CoreData.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 31.03.2021.
//

import Foundation
import CoreData
import UIKit


class CoreData

{
    
    //Creates currency object for keeping currency data for fetching them more quickly
    static func createCurrency(currency: SearchCurrency)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "NewCurrency", into: context)
        newCurrency.setValue(currency.getId(), forKey: "id")
        newCurrency.setValue(currency.getImageUrl(), forKey: "imageUrl")
        newCurrency.setValue(currency.getMarketCapRank().int32Value, forKey: "marketCapRank")
        newCurrency.setValue(currency.getName(), forKey: "name")
        newCurrency.setValue(currency.getPriceChange24().int32Value, forKey: "priceChange24H")
        newCurrency.setValue(currency.getPriceChangePercantage24H().int32Value, forKey: "priceChangePercentage24H")
        newCurrency.setValue(currency.getPriceChangePercantage7D(), forKey: "priceChangePercentage7D")
        newCurrency.setValue(currency.getSymbol(), forKey: "symbol")
        do
        {
            try context.save()
            print("SAVED")
        }
        catch{print("error")}
    }
    
    static func getCurrencies() -> [SearchCurrency]
    {
        var newCurrencies = [SearchCurrency]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewCurrency")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                
                for result in results as! [NSManagedObject]
                {
                    let newCurrency = SearchCurrency()
                    if let id = result.value(forKey: "id") as? String
                    {
                        newCurrency.setId(id: id)
                    }
                    if let imageUrl = result.value(forKey: "imageUrl") as? String
                    {
                        newCurrency.setImageUrl(imageUrl: imageUrl)
                    }
                    if let marketCapRank = result.value(forKey: "marketCapRank") as? Int32
                    {
                        newCurrency.setMarketCapRank(marketCapRank: NSNumber(value: marketCapRank))
                    }
                    if let name = result.value(forKey: "name") as? String
                    {
                        newCurrency.setName(name: name)
                    }
                    if let priceChange24H = result.value(forKey: "priceChange24H") as? Int32
                    {
                        newCurrency.setPriceChange24H(priceChange24H: NSNumber(value: priceChange24H))
                    }
                    if let priceChangePercentage24H = result.value(forKey: "priceChangePercentage24H") as? Int32
                    {
                        newCurrency.setPriceChangePercentage24H(priceChangePercentage24H: NSNumber(value: priceChangePercentage24H))
                    }
                    if let priceChangePercentage7D = result.value(forKey: "priceChangePercentage7D") as? Int32
                    {
                        newCurrency.setPriceChangePercentage7D(priceChangePercentage7D: NSNumber(value: priceChangePercentage7D))
                    }
                    if let symbol = result.value(forKey: "symbol") as? String
                    {
                        newCurrency.setSymbol(symbol: symbol)
                    }
                    newCurrencies.append(newCurrency)
                }
            }
            else
            {
                print("There is no currency in core data...")
            }
        }
        catch
        {
            print("There is a error")
        }
        return newCurrencies
    }
    

    static func isEmpty() -> Bool
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewCurrency")
        var bool = true
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                print("FULL")
                bool = false
            }

        }
        catch
        {
            print("There is a error")
        }
        return bool
    }
    
    static func deleteAll()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewCurrency")
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do
        {
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]
            for item in items
            {
                context.delete(item)
                print("DELETED")
            }
            // Save Changes
            try context.save()

        }
        catch
        {
           
        }
    }
}
