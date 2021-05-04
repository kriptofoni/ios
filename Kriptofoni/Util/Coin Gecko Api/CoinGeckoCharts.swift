//
//  CoinGeckoCharts.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 4.05.2021.
//


import Foundation
import CoreData
import Charts

class CoinGeckoCharts
{
    
    static func getDataPortfolioChart(ids: [String: Double], currency: String,secondTime: String,completionBlock: @escaping ([ChartDataEntry]) -> Void)  -> Void
    {
        /*
        var array = [ChartDataEntry]()
        let now = NSDate().timeIntervalSince1970
        let nowString = String(now)
        //let urlFor24H = "https://api.coingecko.com/api/v3/coins/\(id)/market_chart/range?vs_currency=\(currency)&from=\(secondTime)&to=\(nowString)"
        let url = NSURL(string: urlFor24H)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                return
            }
            /*
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode)
            else
            {
                  print("Error with the response, unexpected status code: \(response)")
                  return
            }
            */
            if let data = data
            {
                do
                {
                    
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let prices = jSONResult["prices"] as! [[NSNumber]]
                    var x: Double = 1.0
                    for (index,price) in prices.enumerated() // take quarter of this
                    {
                        if index % 4 == 0
                        {
                            let epochTime = TimeInterval(price[0].doubleValue / 1000)
                            let charData = ChartDataEntry(x: epochTime , y: price[1].doubleValue)
                            array.append(charData)
                            x = x + 1
                        }
                    }
                    completionBlock(array)
                    
                }
                catch{print("API FETCH FAILED CALL COUNT getDataForCharts"}
            }
        }
        task.resume()
      */
    }
 
    
    
    
    
    static func getDataForCharts(id: String, currency: String, type : String, completionBlock: @escaping ([ChartDataEntry]) -> Void)  -> Void
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
        let url = NSURL(string: urlFor24H)
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Check if Error took place
            if let error = error
            {
                print("Error took place \(error)")
                return
            }
            /*
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode)
            else
            {
                  print("Error with the response, unexpected status code: \(response)")
                  return
            }
            */
            if let data = data
            {
                do
                {
                    
                    let jSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    let prices = jSONResult["prices"] as! [[NSNumber]]
                    var x: Double = 1.0
                    for (index,price) in prices.enumerated() // take quarter of this
                    {
                        if index % 4 == 0
                        {
                            let epochTime = TimeInterval(price[0].doubleValue / 1000)
                            let charData = ChartDataEntry(x: epochTime , y: price[1].doubleValue)
                            array.append(charData)
                            x = x + 1
                        }
                    }
                    completionBlock(array)
                    
                }
                catch{print("API FETCH FAILED CALL COUNT getDataForCharts")}
            }
        }
        task.resume()
        
    }
}
