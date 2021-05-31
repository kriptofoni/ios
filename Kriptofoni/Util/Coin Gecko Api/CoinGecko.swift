//
//  CoinGecko.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import Foundation
import CoreData
import Charts

class CoinGecko
{
    
    static var apiCallCount = 0
    
    
    
    
    static func getCoinVolume(id: String, currency: String, completionBlock: @escaping (NSNumber) -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/simple/price?ids=\(id)&vs_currencies=\(currency)&include_24hr_vol=true"
        let url = NSURL(string: baseUrl)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        var volumefor24H : NSNumber = 0
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                return
            }
           
            if let data = data
            {
                do
                {
                    apiCallCount += 1
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let dict = jSONResult[id] as! [String:Any]
                    let newStr = currency + "_24h_vol"
                    volumefor24H = (dict[newStr] as? NSNumber) ?? 0
                    completionBlock(volumefor24H)
                }
                catch{print("API FETCH FAILED CALL COUNT getCoinVolume" + String(apiCallCount))}
            }
        }
        task.resume()
        
    }
    
    
    ///Gets coin details from api and writes these datas into a dict.
    static func getCoinDetails(id: String, currencyType: String ,completionBlock: @escaping ([String : Any]) -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/coins" + "/" + id
        var coinDict = [String : Any]()
        let url = NSURL(string: baseUrl)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                return
            }
            
            if let data = data
            {
                do
                {
                    apiCallCount += 1
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    guard let marketData = jSONResult["market_data"] as? [String:Any] else {return}
                    guard let market_cap = marketData["market_cap"] as? [String:Any] else {return}
                    guard let current_price = marketData["current_price"] as? [String:Any] else {return}
                    if let price_change_24h_in_currency = marketData["price_change_percentage_24h_in_currency"] as? [String:Any]
                    {
                        coinDict["price_change_percentage_24h"] = (price_change_24h_in_currency[currencyType] as? NSNumber) ?? 0 as NSNumber
                        coinDict["price_change_percentage_24h_bitcoin"] = (price_change_24h_in_currency["btc"] as? NSNumber) ?? 0 as NSNumber
                    }
                    else{coinDict["price_change_percentage_24h"] = 0}
                    if let price_change_percentage_1h_in_currency = marketData["price_change_percentage_1h_in_currency"] as? [String:Any]
                    {
                        coinDict["price_change_percentage_1h_in_currency"] = (price_change_percentage_1h_in_currency[currencyType] as? NSNumber) ?? 0 as NSNumber
                    }
                    else{coinDict["price_change_percentage_1h_in_currency"] = 0}
                    if let price_change_percentage_7d_in_currency = marketData["price_change_percentage_7d_in_currency"] as? [String:Any]
                    {
                        coinDict["price_change_percentage_7d_in_currency"] = (price_change_percentage_7d_in_currency[currencyType] as? NSNumber) ?? 0 as NSNumber
                    }
                    else{coinDict["price_change_percentage_7d_in_currency"] = 0}
                    coinDict["current_price_for_currency"] = (current_price[currencyType] as? NSNumber) ?? 0 as NSNumber
                    coinDict["current_price_for_bitcoin"] = (current_price["btc"] as? NSNumber) ?? 0 as NSNumber
                    coinDict["market_cap"] = (market_cap[currencyType] as? NSNumber) ?? 0 as NSNumber
                    coinDict["total_supply"] = (marketData["total_supply"] as? NSNumber) ?? 0 as NSNumber
                    coinDict["circulating_supply"] = (marketData["circulating_supply"] as? NSNumber) ?? 0 as NSNumber
                    if let links = jSONResult["links"] as? [String: Any]
                    {
                        if let website = links["homepage"] as? [Any] { coinDict["website"] = (website[0] as? String) ?? "https://www.google.com/\(id)" as String }
                        if let twitter = links["twitter_screen_name"] {coinDict["twitter"] = (twitter as? String) ??  "https://www.twitter.com/\(id)" as String  }
                        if let reddit = links["subreddit_url"] {coinDict["reddit"] = (reddit as? String) ?? "https://www.reddit.com/\(id)" as String   }
                    }
                    self.getCoinVolume(id: id, currency: currencyType) { (result) in
                        coinDict["volumeFor24H"] = result
                        completionBlock(coinDict)
                    }
                }
                catch{print("API FETCH FAILED CALL COUNT getCoinDetails" + String(apiCallCount))}
            }
        }
        task.resume()
        
        
    }
  
    
    static func getSupportedCurrencies (completionBlock: @escaping (String) -> Void) -> Void
    {
        var concatedString = String()
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "/simple/supported_vs_currencies"
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
            
            if let data = data
            {
                do
                {
                    apiCallCount += 1
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for jsonElement in jSONResult as! [String]
                    {
                        concatedString = concatedString + "," + jsonElement
                    }
                    completionBlock(concatedString)
                }
                catch{print("API FETCH FAILED CALL COUNT getSupportedCurrencies")}
            }
        }
        task.resume()
    }

    
    static func getTotalMarketValue(currency : String, symbol: String, completionBlock: @escaping (String) -> Void) -> Void
    {
        print("MArket2")
        var navigationTitle = String()
        let baseUrl = "https://api.coingecko.com/api/v3/global"
        let url = NSURL(string: baseUrl)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                completionBlock("")
            }
           
            if let data = data
            {
                do
                {
                    apiCallCount += 1
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    if let data = jSONResult["data"] as? [String : Any]
                    {
                        if let totalVolumeDict = data["total_market_cap"] as? [String:Any]
                        {
                            if let totalVolumeForCurrency = totalVolumeDict[currency] as? NSNumber
                            {
                                print(totalVolumeForCurrency.stringValue + "cem")
                                navigationTitle = Util.toPrice(totalVolumeForCurrency.doubleValue, isCoinDetailPrice: false) + " " + symbol
                                completionBlock(navigationTitle);
                            }
                        }
                    }
                }
                catch{print("API FETCH FAILED COUNT getTotalMarketValue" + String(apiCallCount))}
            }
        }
        task.resume()
        
    }
    
    static func getCoins(vs_currency :String, ids: String,  order : String, per_page : Int,  page : Int, sparkline : Bool, hashMap : [String : Int], priceChangePercentage : String, completionBlock: @escaping ([Coin]) -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "coins/markets/"
        
        var array = [Coin]()
        var components = URLComponents(string: newString)
        components?.queryItems =
        [
            URLQueryItem(name: "vs_currency", value: vs_currency),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "per_page", value: String(per_page)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: String(sparkline)),
            URLQueryItem(name: "ids", value: ids),
            URLQueryItem(name: "price_change_percentage", value: priceChangePercentage)
        ]
        var request = URLRequest(url: (components?.url)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                completionBlock([Coin]())
            }
            
            if let data = data
            {
               // print("Response data string:\n \(dataString)")
                do
                {
                    apiCallCount += 1
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for jsonElement in jSONResult as! [[String: Any]]
                    {
                        if let id = jsonElement["id"] as? String
                        {
                            if let symbol = jsonElement["symbol"] as? String
                            {
                                if let name = jsonElement["name"] as? String
                                {
                                    if let image = jsonElement["image"] as? String
                                    {
                                        let change = (jsonElement["price_change_24h"] as? NSNumber) ?? 0 as NSNumber
                                        let currentPrice = (jsonElement["current_price"] as? NSNumber) ?? 0 as NSNumber
                                        let percent = (jsonElement["price_change_percentage_24h_in_currency"] as? NSNumber)  ?? 0 as NSNumber
                                        let priceChangePercentage7D = (jsonElement["price_change_percentage_7d_in_currency"] as? NSNumber) ?? 0 as NSNumber
                                        let marketCapRank = (jsonElement["market_cap_rank"] as? NSNumber) ?? 100000000000 as NSNumber
                                        let change7d = currentPrice.doubleValue - (currentPrice.doubleValue/(priceChangePercentage7D.doubleValue/100 + 1))
                                        if hashMap.isEmpty
                                        {
                                            let currency = Coin(id: id, count: 0, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D, change7d: NSNumber(value: change7d), marketCapRank: marketCapRank)
                                            array.append(currency)
                                        }
                                        else
                                        {
                                            let currency = Coin(id: id, count: hashMap[id]!, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D, change7d: NSNumber(value: change7d), marketCapRank: marketCapRank)
                                            array.append(currency)
                                        }
                                    }
                                    else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                                }
                                else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                            }
                            else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                        }
                        else{print("JSON Error : Cannot get one of the attirbutes of coin...")}
                    }
                    completionBlock(array);
                }
                catch{print("API FETCH FAILED COUNT getCoins" + String(apiCallCount))}
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
}
