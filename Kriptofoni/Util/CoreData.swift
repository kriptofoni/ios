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
    static func getCoins(completionBlock: @escaping ([SearchCoin]) -> Void,onFailure: () -> Void) -> Void
    {
        var newCurrencies = [SearchCoin]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                let newCurrency = SearchCoin()
                for result in results as! [NSManagedObject]
                {
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
                                                         let newCurrency = SearchCoin(id: id, imageUrl: image, name: name, symbol: symbol, marketCapRank: marketCapRank, priceChange24H: priceChange24H,priceChangePercentage24H: priceChangePercentage24H, priceChangePercentage7D: priceChangePercentage7D)
                                                         newCurrencies.append(newCurrency)
                                                    }
                                                    else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                                }
                                                else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                            }
                                            else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                        }
                                        else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                    }
                                    completionBlock(newCurrencies);
                                }
                                else
                                {
                                    
                                }
                            }
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                        
                    }
                    
                }
            }
            else
            {
                print("There is no crypto-currency in core data...")
            }
        }
        catch
        {
            print("There is a error")
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
    
    
    
    static func getSupportedCurrencies(type : String, completionBlock: @escaping (String) -> Void,onFailure: () -> Void) -> Void
    {
        var concatedString = String()
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "/simple/supported_vs_currencies"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrenyTypes")
        let url = NSURL(string: newString)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                return
            }
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            // Convert HTTP Response Data to a simple String
            if let data = data
            {
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for jsonElement in jSONResult as! [String]
                    {
                        concatedString = concatedString + jsonElement + ","
                    }
                    /*
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.newBackgroundContext()
                    if type == "first"
                    {
                        
                    }
                    else
                    {
                        
                    }
                    */
                    completionBlock(concatedString)
                }
                catch
                {
                    print("Error when fetching currency types")
                }
            }
        }
        task.resume()
    }
 
}
