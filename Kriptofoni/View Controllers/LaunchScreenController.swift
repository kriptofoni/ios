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
    static var searchCoinArray = [Coin]()
    static var timerCount = 0
    static var isFirstTime = true
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if CoreData.isEmpty() //If it is the first time after downloading app
        {
            print("cem")
            self.performSegue(withIdentifier: "welcomeController", sender: self)
        }
        else
        {
            fillTheArrays()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func update()
    {
        if !LaunchScreenController.totalMarketValue.isEmpty && !LaunchScreenController.coinArray.isEmpty 
        {
            DispatchQueue.main.async {self.hideActivityIndicator()}
            self.performSegue(withIdentifier:  "toAppFromLaunchScreen", sender: self)
        }
    
    }
    
    func fillTheArrays()
    {
        if LaunchScreenController.isFirstTime
        {
            LaunchScreenController.isFirstTime = false
            DispatchQueue.main.async
            {
                self.showActivityIndicator(scroll: true)
                CoreData.getCoins { (result) in
                    LaunchScreenController.searchCoinArray = result
                    CoreData.getSupportedCurrencies {(currencies) in LaunchScreenController.currencyTypes = currencies}
                    self.getTotalMarketValue()
                    self.getCoinsApi()
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
        print("MARKET1")
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
        if copyArray.count > 6000
        {
            if type == "INC"
            {
                copyArray = copyArray.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                LaunchScreenController.mostIncIn24H.append(contentsOf: copyArray)
            }
            else if type == "DEC"
            {
                copyArray = copyArray.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                LaunchScreenController.mostDecIn24H.append(contentsOf: copyArray)
            }
        }
    }
    
    /// Gets coins according to 7D changes, type is for selecting INC or DEC
    func getCoinsFor7(type: String)
    {
        var copyArray = LaunchScreenController.searchCoinArray
       
        if copyArray.count > 6000
        {
            if type == "INC"
            {
                copyArray = copyArray.sorted(by: {$0.getPercent7d().doubleValue > $1.getPercent7d().doubleValue})
                LaunchScreenController.mostIncIn7D.append(contentsOf: copyArray)
                
            }
            else if type == "DEC"
            {
                copyArray = copyArray.sorted(by: {$0.getPercent7d().doubleValue < $1.getPercent7d().doubleValue})
                LaunchScreenController.mostDecIn7D.append(contentsOf: copyArray)
                
            }
            
        }
    }
    
    ///Gets Coins from api. If update is true, func only update first 100 coin.
    func getCoinsApi()
    {
        CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: 1, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d" ) { (result) in
            if result.isEmpty
            {
                self.getCoinsApi()
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
