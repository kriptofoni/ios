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
    
    var activityView: UIActivityIndicatorView?
    static var totalMarketValue = String()
    static var mostIncIn24H = [Coin]()
    static var mostDecIn24H = [Coin]();
    static var mostIncIn7D = [Coin]();
    static var mostDecIn7D = [Coin]()
    static var coinArray = [Coin]();
    static var currencyTypes = [String]()
    static var searchCoinArray = [SearchCoin]()
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
        showActivityIndicator(scroll: true)
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (marketValue) in
            LaunchScreenController.totalMarketValue = marketValue
            DispatchQueue.main.async
            {
                CoreData.getCoins { (result) in
                    CoreData.getSupportedCurrencies
                    {
                        (currencies) in LaunchScreenController.currencyTypes = currencies
                        LaunchScreenController.searchCoinArray = result
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
        var copyArray = LaunchScreenController.searchCoinArray
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
                    LaunchScreenController.mostIncIn24H.append(contentsOf: first50Coin)
                    print("MostIncIn24H First Load.")
                }
                else if type == "DEC"
                {
                    var first50Coin = result
                    first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                    LaunchScreenController.mostDecIn24H.append(contentsOf: first50Coin)
                    print("MostDecIn24H First Load")
                }
            }
        }
    }
    
    /// Gets coins according to 7D changes, type is for selecting INC or DEC
    func getCoinsFor7(type: String)
    {
        
        var copyArray = LaunchScreenController.searchCoinArray
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
                        LaunchScreenController.mostIncIn7D.append(contentsOf: first50Coin)
                }
                else if type == "DEC"
                {
                    
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                       LaunchScreenController.mostDecIn7D.append(contentsOf: first50Coin)
                        CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: 1, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d" ) { (result) in
                            LaunchScreenController.coinArray = result
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
        
    


}
