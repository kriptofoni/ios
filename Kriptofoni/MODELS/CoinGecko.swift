//
//  CoinGecko.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import Foundation

class CoinGecko
{
    init()
    {
    
    }

    func getCoinMarkets(vs_currency :String,  order : String, per_page : Int,  page : Int, sparkline : Bool, priceChangePercentage : String , index : Int, completionBlock: @escaping ([SearchCurrency]) -> Void,onFailure: () -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "coins/markets/"
        var array = [SearchCurrency]()
        var components = URLComponents(string: newString)
        
        components?.queryItems =
        [
            URLQueryItem(name: "vs_currency", value: vs_currency),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "per_page", value: String(per_page)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: String(sparkline)),
            URLQueryItem(name: "price_change_percentage", value: priceChangePercentage)
        ]
        var request = URLRequest(url: (components?.url)!)
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
            if let data = data, let dataString = String(data: data, encoding: .utf8)
            {
               // print("Response data string:\n \(dataString)")
                do
                {
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
                                         let marketCapRank = (jsonElement["market_cap_rank"] as? NSNumber) ?? 100000000000 as NSNumber
                                         let priceChange24H = (jsonElement["price_change_24h"] as? NSNumber) ?? 0 as NSNumber
                                         let priceChangePercentage24H = (jsonElement["price_change_percentage_24h_in_currency"] as? NSNumber) ?? 0 as NSNumber
                                         let priceChangePercentage7D = (jsonElement["price_change_percentage_7d_in_currency"] as? NSNumber) ?? 0 as NSNumber
                                         if symbol == "wet"
                                         {
                                            print("AVİİİİİ" + priceChangePercentage24H.stringValue)
                                         }
                                         let newCurrency = SearchCurrency(id: id, imageUrl: image, name: name, symbol: symbol, marketCapRank: marketCapRank, priceChange24H: priceChange24H,priceChangePercentage24H: priceChangePercentage24H, priceChangePercentage7D: priceChangePercentage7D)
                                         array.append(newCurrency)
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
                catch
                {
                
                }
            }
        }
        task.resume()
    }
    
    func getCoins(vs_currency :String, ids: String,  order : String, per_page : Int,  page : Int, sparkline : Bool, hashMap : [String : Int], priceChangePercentage : String, completionBlock: @escaping ([Currency]) -> Void,onFailure: () -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "coins/markets/"
        var array = [Currency]()
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
                return
            }
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8)
            {
               // print("Response data string:\n \(dataString)")
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    let number = 1
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
                                        if hashMap.isEmpty
                                        {
                                            let currency = Currency(id: id, count: 0, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D)
                                            array.append(currency)
                                        }
                                        else
                                        {
                                            let currency = Currency(id: id, count: hashMap[id]!, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D)
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
                catch
                {
                
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
}
