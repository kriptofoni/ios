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
    //
    
    static func getLastUpdateTime(completionBlock: @escaping (Date) -> Void) -> Void
    {
        DispatchQueue.main.async
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.newBackgroundContext()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
            fetchRequest.returnsObjectsAsFaults = false
            do
            {
                let results = try context.fetch(fetchRequest)
                if results.count > 0
                {
                    print(String(results.count) + "RESULT.COUNT")
                    let result = results.last as! NSManagedObject
                    if let date = result.value(forKey: "time") as? Date
                    {
                        completionBlock(date)
                    }
                }
                else{print("There is no crypto-currency in core data...")}
            }
            catch{print("There is a error")}
        }
    }
    
    static func getCoins(completionBlock: @escaping ([Coin]) -> Void) -> Void
    {
        var newCoins = [Coin]()
        DispatchQueue.main.async
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.newBackgroundContext()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
            fetchRequest.returnsObjectsAsFaults = false
            do
            {
                let results = try context.fetch(fetchRequest)
                if results.count > 0
                {
                    print(String(results.count) + "RESULT.COUNT")
                    let result = results.last as! NSManagedObject
                    if let string = result.value(forKey: "string") as? String
                    {
                        do
                        {
                            if let json = string.data(using: String.Encoding.utf8)
                            {
                                if let jsonData = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray
                                {
                                    for jsonElement in jsonData as! [[String: Any]]
                                    {
                                        if let id = jsonElement["id"] as? String
                                        {
                                            if let symbol = jsonElement["symbol"] as? String
                                            {
                                                
                                                if let name = jsonElement["name"] as? String
                                                {
                                                    if let image = jsonElement["image"] as? String
                                                    {
                                                         let marketCapRank = (jsonElement["market_cap_rank"] as? NSNumber) ?? 100000000000 as NSNumber
                                                         let priceChange24H = (jsonElement["price_change_24h"] as? NSNumber) ?? 0 as NSNumber
                                                         let priceChangePercentage24H = (jsonElement["price_change_percentage_24h_in_currency"] as? NSNumber) ?? 0 as NSNumber
                                                         let priceChangePercentage7D = (jsonElement["price_change_percentage_7d_in_currency"] as? NSNumber) ?? 0 as NSNumber
                                                         let currentPrice = (jsonElement["current_price"] as? NSNumber) ?? 0 as NSNumber
                                                         let change7d = currentPrice.doubleValue - (currentPrice.doubleValue/(priceChangePercentage7D.doubleValue/100 + 1))
                                                         let coin = Coin(id: id, count: 0, iconViewUrl: image, name: name, percent: priceChangePercentage24H, change: priceChange24H, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D, change7d: NSNumber(value: change7d), marketCapRank: marketCapRank)
                                                         newCoins.append(coin)
                                                    }
                                                    else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                                }
                                                else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                            }
                                            else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                        }
                                        else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                    }
                                    completionBlock(newCoins);
                                }
                                else{print("JSON Error")}
                            }
                        }
                        catch{print(error.localizedDescription)}
                    }
                    
                }
                else{print("There is no crypto-currency in core data...")}
            }
            catch{print("There is a error")}
        }
        
    }
    

    static func isEmpty() -> Bool
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
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
    
    
    
    
    /// Gets saved currency types from core data and convert these types to string array from a string
    static func getSupportedCurrencies(completionBlock: @escaping ([String]) -> Void) -> Void
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyTypes")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let types = result.value(forKey: "types") as? String
                    {
                        
                        let currencyTypes = types.components(separatedBy: ",")//first index will be empty so be careful in table view
                        completionBlock(currencyTypes)
                    }
                    
                }
            }
            else
            {
                print("Error : There is no currency type in core data")
            }
        }
        catch
        {
            print("Error: Core Data Currency")
        }
    }
    
    
  
 
}

