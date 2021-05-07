//
//  LaunchScreenController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 7.05.2021.
//

import UIKit
//toAppFromLaunchScreen
class LaunchScreenController: UIViewController
{
    var totalMarketValue = String()
    var activityView: UIActivityIndicatorView?
    var mostIncIn24H = [Coin]();var mostDecIn24H = [Coin]();var mostIncIn7D = [Coin]();var mostDecIn7D = [Coin]();var coinArray = [Coin](); var currencyTypes = [String]()
    var searchCoinArray = [SearchCoin]()
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        getCoins()
        // Do any additional setup after loading the view.
    }
    
    ///Gets Coins from api. If update is true, func only update first 100 coin.
    func getCoins()
    {
        DispatchQueue.main.async {self.showActivityIndicator(scroll: false)}
        showActivityIndicator(scroll: false)
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (marketValue) in
            self.totalMarketValue = marketValue
            DispatchQueue.main.async
            {
                CoreData.getCoins { (result) in
                    CoreData.getSupportedCurrencies
                    {
                        (currencies) in self.currencyTypes = currencies
                        self.searchCoinArray = result
                        self.getCoinsFor24(type: "INC")
                        self.getCoinsFor24(type: "DEC")
                        self.getCoinsFor7(type: "INC")
                        self.getCoinsFor7(type: "DEC")
                    }
                    
                }
            }
        }
    
    }
    /// Get coins according to 24H changes, type is for selecting INC or DEC
    func getCoinsFor24(type : String)
    {
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue > $1.getPriceChangePercantage24H().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue < $1.getPriceChangePercantage24H().doubleValue})}
            for m in (0...49)
            {
                    newString += copyArray[m].getId() + ","
                    coinNumber[copyArray[m].getId()] = m + 1
            }
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    
                    var first50Coin = result
                    first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                    self.mostIncIn24H.append(contentsOf: first50Coin)
                    print("MostIncIn24H First Load.")
                }
                else if type == "DEC"
                {
                    var first50Coin = result
                    first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                    self.mostDecIn24H.append(contentsOf: first50Coin)
                    print("MostDecIn24H First Load")
                }
            }
        }
    }
    
    /// Gets coins according to 7D changes, type is for selecting INC or DEC
    func getCoinsFor7(type: String)
    {
        
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue > $1.getPriceChangePercantage7D().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue < $1.getPriceChangePercantage7D().doubleValue})}
            for m in (0...49)
            {
                    newString += copyArray[m].getId() + ","
                    coinNumber[copyArray[m].getId()] = m + 1
            }
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        self.mostIncIn7D.append(contentsOf: first50Coin)
                }
                else if type == "DEC"
                {
                    
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        self.mostDecIn7D.append(contentsOf: first50Coin)
                        CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: 1, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d" ) { (result) in
                            DispatchQueue.main.async {self.showActivityIndicator(scroll: false)}
                            DispatchQueue.main.async {
                                self.hideActivityIndicator()
                                self.performSegue(withIdentifier: "toAppFromLaunchScreen", sender: self)
                            }
                            
                        }
                    }
                }
            }
            
        }
    
    //shows spinner
    func showActivityIndicator(scroll : Bool)
    {
        if #available(iOS 13.0, *) {activityView = UIActivityIndicatorView(style: .medium)}
        else {activityView = UIActivityIndicatorView(style: .gray)}
        if scroll {activityView?.center = CGPoint(x: self.view.center.x, y: UIScreen.main.bounds.size.height * 3/4)}
        else{activityView?.center = self.view.center}
        
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    //hides spinner
    func hideActivityIndicator() {if (activityView != nil){activityView?.stopAnimating()}}
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toAppFromLaunchScreen"
        {
            let destinationVC = segue.destination as! MainController
            destinationVC.coinArray = self.coinArray
            destinationVC.mostIncIn24H = self.mostIncIn24H
            destinationVC.mostDecIn24H = self.mostDecIn24H
            destinationVC.mostIncIn7D = self.mostIncIn7D
            destinationVC.mostDecIn7D = self.mostDecIn7D
            destinationVC.currencyTypes = self.currencyTypes
           
        }
    }
    


}
