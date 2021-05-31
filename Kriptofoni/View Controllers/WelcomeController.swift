//
//  WelcomeController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.05.2021.
//

import UIKit
import CoreData
// toAppFromWelcome
class WelcomeController: UIViewController {

    var searchCoinArray = [Coin]();var currencyTypes = [String]()
    static var isWelcomeOpened = false
    @IBOutlet weak var button: UIButton!
    static var firstTime = true
    static var currencyCompleted = false
    static var coinsCompleted = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if WelcomeController.firstTime
        {
            WelcomeController.firstTime = false
            saveCurrencies()
            getSearchArray()
        }
    }

    
    
    @IBAction func buttonClicked(_ sender: Any)
    {
        print(WelcomeController.currencyCompleted)
        print(WelcomeController.coinsCompleted)
        if WelcomeController.currencyCompleted && WelcomeController.coinsCompleted
        {
            self.performSegue(withIdentifier: "launcherBack", sender: self)
        }
        
    }
    
    ///Gets supported currencies from api and saves them to core data
    func saveCurrencies()
    {
        CoinGecko.getSupportedCurrencies() { (resultString) in
            DispatchQueue.main.async
            {
                let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                do
                {
                    let type = NSEntityDescription.insertNewObject(forEntityName: "CurrencyTypes", into: managedObjectContext)
                    type.setValue(resultString, forKey: "types")
                    do
                    {
                        try managedObjectContext.save()
                        print("CURRENCY TYPES ARE SAVED.")
                        self.currencyTypes = resultString.components(separatedBy: ",")//first index will be empty so be careful in table view
                        WelcomeController.currencyCompleted = true
                    }
                    catch{print("error")}
                }
            }
        }
    }
    
    ///Save to core data
    func getSearchArray()
    {
        let myGroup = DispatchGroup()
        self.searchCoinArray.removeAll(keepingCapacity: false)
        for n in 1...27
        {
            myGroup.enter()
            CoinGecko.getCoins(vs_currency: "usd", ids: "", order: "id_asc", per_page: 250, page: n, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d") { result in
                self.searchCoinArray.append(contentsOf: result)
                myGroup.leave()
                
            }
        }
        myGroup.notify(queue: .main)
        {
            print(String(self.searchCoinArray.count) + "SEARCH CURRENCY ARRAY COUNT")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.newBackgroundContext()
            let jsonCompatibleArray = self.searchCoinArray.map { model in
                    return [
                        "id":model.getId(),
                        "symbol":model.getShortening(),
                        "name":model.getName(),
                        "image":model.getIconViewUrl(),
                        "market_cap_rank":model.getMarketCapRank(),
                        "price_change_24h":model.getChange(),
                        "price_change_percentage_24h_in_currency":model.getPercent(),
                        "price_change_percentage_7d_in_currency":model.getPercent7d(),
                        "current_price":model.getPrice()
                    ]
            }
            do
            {
                let data = try JSONSerialization.data(withJSONObject: jsonCompatibleArray, options: .prettyPrinted)
                let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "StringCurrency", into: context)
                newCurrency.setValue(jsonString, forKey: "string")
                do
                {
                    try context.save()
                    print("COINS ARE SAVED.")
                    WelcomeController.isWelcomeOpened = true
                    WelcomeController.coinsCompleted = true
                }
                catch{print("error")}
            }
            catch{print("ERROR")}
            
            
        }
    }

}
