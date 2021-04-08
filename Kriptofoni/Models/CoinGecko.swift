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
    init()
    {
    
    }
    //completionBlock: @escaping ([String: [ChartDataEntry]]) -> Void, onFailure: () -> Void)  -> Void
    
    func getDataForCharts(id: String, currency: String, type : String, completionBlock: @escaping ([ChartDataEntry]) -> Void, onFailure: () -> Void)  -> Void
    {
        var array = [ChartDataEntry]()
        let now = NSDate().timeIntervalSince1970
        let nowString = String(now)
        var secondTime = ""
        switch type
        {
            case "twentyFour_hours": secondTime  = String(now - (60*60*24))
            case "one_week_before": secondTime = String(now - (60*60*24*7))
            case "one_month_before": secondTime = String(now - (60*60*24*31))
            case "three_months_before": secondTime = String(now - (60*60*24*31*3))
            case "six_months_before": secondTime = String(now - (60*60*24*31*6))
            case "one_year_before": secondTime = String(now - (60*60*24*31*12))
            case "all": secondTime = String(0)
            default:print("HATA")
        }
        let urlFor24H = "https://api.coingecko.com/api/v3/coins/\(id)/market_chart/range?vs_currency=\(currency)&from=\(secondTime)&to=\(nowString)"
        print(urlFor24H + "URL" + id)
        let url = NSURL(string: urlFor24H)
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
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            if let data = data
            {
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let prices = jSONResult["prices"] as! [[NSNumber]]
                    var x: Double = 1.0
                    for price in prices
                    {
                        let charData = ChartDataEntry(x: x, y: price[1].doubleValue)
                        array.append(charData)
                        x = x + 1
                    }
                    completionBlock(array)
                    
                }
                catch
                {
                    print("Error when fetching chart datas.")
                }
            }
        }
        task.resume()
        
    }
    
    func getCoinVolume(id: String, currency: String, completionBlock: @escaping (NSNumber) -> Void, onFailure: () -> Void) -> Void
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
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            if let data = data
            {
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let dict = jSONResult[id] as! [String:Any]
                    let newStr = currency + "_24h_vol"
                    volumefor24H = (dict[newStr] as? NSNumber) ?? 0
                    completionBlock(volumefor24H)
                }
                catch
                {
                    print("Error when fetching currency types")
                }
            }
        }
        task.resume()
        
    }
    
    func getCoinDetails(id: String, currencyType: String ,completionBlock: @escaping ([String : NSNumber]) -> Void, onFailure: () -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/coins" + "/" + id
        var coinDict = [String : NSNumber]()
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
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            if let data = data
            {
                do
                {
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
                    self.getCoinVolume(id: id, currency: currencyType) { (result) in
                        coinDict["volumeFor24H"] = result
                        completionBlock(coinDict)
                    } onFailure: {
                        print("Error: when fetching volume")
                    }
                }
                catch
                {
                    print("Error when fetching currency types")
                }
            }
        }
        task.resume()
        
        
    }
  
    
    func getSupportedCurrencies (completionBlock: @escaping (String) -> Void,onFailure: () -> Void) -> Void
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
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            if let data = data
            {
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                    for jsonElement in jSONResult as! [String]
                    {
                        
                        concatedString = concatedString + "," + jsonElement
                    }
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

    func getCoinMarkets(vs_currency :String,  order : String, per_page : Int,  page : Int, sparkline : Bool, priceChangePercentage : String , index : Int, completionBlock: @escaping ([SearchCoin]) -> Void,onFailure: () -> Void) -> Void
    {
        let baseUrl = "https://api.coingecko.com/api/v3/"
        let newString = baseUrl + "coins/markets/"
        var array = [SearchCoin]()
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
                                         let newCurrency = SearchCoin(id: id, imageUrl: image, name: name, symbol: symbol, marketCapRank: marketCapRank, priceChange24H: priceChange24H,priceChangePercentage24H: priceChangePercentage24H, priceChangePercentage7D: priceChangePercentage7D)
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
    
    func getTotalMarketValue(currency : String, symbol: String, completionBlock: @escaping (String) -> Void, onFailure: () -> Void) -> Void
    {
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
                return
            }
            // Read HTTP Res3ponse Status code
            //if let response = response as? HTTPURLResponse{print("Response HTTP Status code: \(response.statusCode)")}
            if let data = data
            {
                do
                {
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    if let data = jSONResult["data"] as? [String : Any]
                    {
                        if let totalVolumeDict = data["total_market_cap"] as? [String:Any]
                        {
                            if let totalVolumeForCurrency = totalVolumeDict[currency] as? NSNumber
                            {
                                navigationTitle = totalVolumeForCurrency.stringValue + " " + symbol
                                completionBlock(navigationTitle);
                            }
                        }
                    }
                }
                catch
                {
                    print("Error when fetching total market value.")
                }
            }
        }
        task.resume()
        
    }
    
    func getCoins(vs_currency :String, ids: String,  order : String, per_page : Int,  page : Int, sparkline : Bool, hashMap : [String : Int], priceChangePercentage : String, completionBlock: @escaping ([Coin]) -> Void,onFailure: () -> Void) -> Void
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
                                            let currency = Coin(id: id, count: 0, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D)
                                            array.append(currency)
                                        }
                                        else
                                        {
                                            let currency = Coin(id: id, count: hashMap[id]!, iconViewUrl: image, name: name, percent: percent, change: change, price: currentPrice, shortening: symbol, percent7d: priceChangePercentage7D)
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
