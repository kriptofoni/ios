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
    static var mostIncIn24H = [Coin](); 
    static var mostDecIn24H = [Coin]();
    static var mostIncIn7D = [Coin]();
    static var mostDecIn7D = [Coin]()
    static var coinArray = [Coin]();
    static var currencyTypes = [String]()
    static var searchCoinArray = [SearchCoin]()
    static var timerCount = 0
    var timer: Timer?
    
    
     //Locks the screen before view is appeared and realease this locking before view is disappeared
     override func viewWillDisappear(_ animated: Bool)
     {
         super.viewWillDisappear(animated)
         AppUtility.lockOrientation(.all)
         timer?.invalidate();timer = nil
     }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        fillTheArrays()
        // Do any additional setup after loading the view.
    }
    
    @objc func update()
    {
        if !LaunchScreenController.totalMarketValue.isEmpty && !LaunchScreenController.coinArray.isEmpty && !LaunchScreenController.mostIncIn24H.isEmpty && !LaunchScreenController.mostDecIn24H.isEmpty
        {
            DispatchQueue.main.async {self.hideActivityIndicator()}
            self.performSegue(withIdentifier:  "toAppFromLaunchScreen", sender: self)
        }
    
    }
    
    func fillTheArrays()
    {
        DispatchQueue.main.async {self.showActivityIndicator(scroll: true)}
        DispatchQueue.main.async
        {
            CoreData.getCoins { (result) in
                CoreData.getSupportedCurrencies
                {
                    (currencies) in LaunchScreenController.currencyTypes = currencies
                    LaunchScreenController.searchCoinArray = result
                    self.getTotalMarketValue()
                    self.getCoins()
                    self.getCoinsFor24(type: "INC")
                    self.getCoinsFor24(type: "DEC")
                    self.getCoinsFor7(type: "INC")
                    self.getCoinsFor7(type: "DEC")
                    
                }
            }
        }
    
    }
    
    func getTotalMarketValue()
    {
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (marketValue) in
            if marketValue == ""
            {
                self.getTotalMarketValue()
            }
            else
            {
                LaunchScreenController.totalMarketValue = marketValue
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
                if result.isEmpty
                {
                    self.getCoinsFor24(type: type)
                }
                else
                {
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
                if result.isEmpty
                {
                    self.getCoinsFor7(type: type)
                }
                else
                {
                    if type == "INC"
                    {
                        
                            var first50Coin = result
                            first50Coin = first50Coin.sorted(by: {$0.getPercent7d().doubleValue > $1.getPercent7d().doubleValue})
                            LaunchScreenController.mostIncIn7D.append(contentsOf: first50Coin)
                            print("MostIncIn7D First Load.")
                    }
                    else if type == "DEC"
                    {
                        
                            var first50Coin = result
                            first50Coin = first50Coin.sorted(by: {$0.getPercent7d().doubleValue < $1.getPercent7d().doubleValue})
                            LaunchScreenController.mostDecIn7D.append(contentsOf: first50Coin)
                             print("MostDecIn7D First Load.")
                    }
                }
                
            }
            }
    }
    
    ///Gets Coins from api. If update is true, func only update first 100 coin.
    func getCoins()
    {
        CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: 1, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d" ) { (result) in
            if result.isEmpty
            {
                self.getCoins()
            }
            else
            {
                LaunchScreenController.coinArray = result

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
