//
//  CoreDataPortfolio.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 30.04.2021.
//

import Foundation
import CoreData
import UIKit


class CoreDataPortfolio
{
    /// saves operation to portfolio
    static func saveToPortfolio(coinId: String,quantity: Double, date: Double, price: Double, fee: Double, note: String, type: Bool,completionBlock: @escaping (Bool) -> Void) -> Void
    {
        //type indicates that the type of the operation (buy -> true, sell -> false)
        //other parameters just pass inputs to core data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        do
        {
            let portfolioCoin = NSEntityDescription.insertNewObject(forEntityName: "PortfolioCoin", into: context)
            portfolioCoin.setValue(coinId, forKey: "coinId")
            portfolioCoin.setValue(quantity, forKey: "quantity")
            portfolioCoin.setValue(date, forKey: "date")
            portfolioCoin.setValue(price, forKey: "price")
            portfolioCoin.setValue(fee, forKey: "fee")
            portfolioCoin.setValue(note, forKey: "note")
            portfolioCoin.setValue(type, forKey: "type")
            do
            {
                try context.save()
                print("Coin is saved to portfolio.")
                completionBlock(true)
                
            }
            catch{print("Coin is not saved to portfolio.");completionBlock(false)}
        }
    }
    
    ///gets operations from portfolio
    static func getPortfolio(completionBlock: @escaping ([PortfolioOperation]) -> Void) -> Void
    {
        var portfolioOperations = [PortfolioOperation]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PortfolioCoin")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    let coinId = result.value(forKey: "coinId") as! String
                    let quantity = result.value(forKey: "quantity") as! Double
                    let date = result.value(forKey: "date") as! Double
                    let price = result.value(forKey: "price") as! Double
                    let fee = result.value(forKey: "fee") as! Double
                    let note = result.value(forKey: "note") as! String
                    let type = result.value(forKey: "type") as! Bool
                    let newOperation = PortfolioOperation(coinId: coinId, quantity: quantity, date: date, price: price, fee: fee, note: note, type: type)
                    portfolioOperations.append(newOperation)
                }
                completionBlock(portfolioOperations)
            }
            else
            {
                print("Error : There is no currency type in portfolio.")
                completionBlock(portfolioOperations)
            }
        }
        catch{print("Error: Core Data Currency")}
    }
    
    ///calculates total coin according to categories... example return ["bitcoin":1.2, "ripple": 2.1]
    static func calculateTotalCoin(completionBlock: @escaping ([String : Double]) -> Void) -> Void
    {
        var portfolioTotalDict = [String:Double]()
        getPortfolio { (result) in
           for operation in result
           {
               if (portfolioTotalDict[operation.getCoinId()] != nil)
               {
                    let temp = portfolioTotalDict[operation.getCoinId()]
                    if operation.getType()//BUY OPERATION
                    {
                        portfolioTotalDict[operation.getCoinId()] = temp! + operation.getQuantity()
                    }
                    else  // SELL OPERATION
                    {
                        portfolioTotalDict[operation.getCoinId()] = temp! - operation.getQuantity()
                    }
               }
               else
               {
                    portfolioTotalDict[operation.getCoinId()] = operation.getQuantity()
               }
             
           }
           completionBlock(portfolioTotalDict)
        }
    }
    
    
    ///calculates principal money. principal money = operation.price + operation.quantity + operation.fee
    static func calculatePrincipalMoney(completionBlock: @escaping (Double) -> Void) -> Void
    {
        var principalMoney : Double = 0
        getPortfolio { (result) in
           for operation in result
           {
               principalMoney += operation.getPrice() * operation.getQuantity() + operation.getFee()
           }
           completionBlock(principalMoney)
        }
    }
    
    /// deletes coins from core data
    static func deleteCoinFromPortfolio(ids: [String],completionBlock: @escaping (Bool) -> Void) -> Void
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PortfolioCoin")
        fetchRequest.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(fetchRequest)
            if results.count > 0
            {
                for result in results as! [NSManagedObject]
                {
                    if let coinId = result.value(forKey: "coinId") as? String
                    {
                        if ids.contains(coinId)
                        {
                            context.delete(result)
                            do
                            {
                                try context.save()
                                print("\(coinId) is deleted from portfolio.")
                            }
                            catch
                            {
                                // Handle Error
                            }
                            
                        }
                    }
                }
                completionBlock(true)
            }
            else
            {
                print("Error : There is no currency type in portfolio.")
                completionBlock(false)
            }
        }
        catch{print("Error: Core Data Currency")}
    }
}
