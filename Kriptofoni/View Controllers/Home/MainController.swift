//
//  MainViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 27.03.2021.
//
import UIKit
import ScrollableSegmentedControl
import SDWebImage
import CoreData


class MainController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
   
    @IBOutlet weak var parentViewOfSegmented: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    @IBOutlet var arrowButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    var activityView: UIActivityIndicatorView?
    var selectedIndexPath = IndexPath(row: 0, section: 0);var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    var buttons = [UIBarButtonItem]()
    var mostIncIn24H = [Coin]();var mostDecIn24H = [Coin]();var mostIncIn7D = [Coin]();var mostDecIn7D = [Coin]();var coinArray = [Coin]()
    var searchCoinArray = [SearchCoin](); var searchActiveArray = [SearchCoin](); var currencyTypes = [String]()
    let coinGecko = CoinGecko()
    var tableViewPosition = 0;
    static var coinsPage = 1
    static var mostIncIn24Page = 1
    static var mostDecIn24Page = 1
    static var mostIncIn7dPage = 1
    static var mostDecIn7dPage  = 1
    static var isCoreDataUpdated = false
    var selectedCoin = Coin(); var selectedSearchCoin = SearchCoin()
    var searchActive = false
    var timer: Timer?
    var isFirstTime = true
    var sSize: CGRect = UIScreen.main.bounds
    var scrollingFetchProcess = false
    
   
    //Locks the screen before view is appeared and realease this locking before view is disappeared
    override func viewWillDisappear(_ animated: Bool) {super.viewWillDisappear(animated);AppUtility.lockOrientation(.all);timer?.invalidate();timer = nil}
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        let sWidth = sSize.width
        segmentedView.frame.size.width = sWidth
        self.currencyButton.title = Currency.currencyKey.uppercased()
        addSwipeGesture()
        self.tableView.delegate = self;self.tableView.dataSource = self;self.searchBar.delegate = self
        buttons.append(searchButton); buttons.append(currencyButton)
        appStartingControls()
        //timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
    }
    
    //Did this over there becuase i do not want to add segments to segmented view every time i open this controller
    override func viewDidLoad()
    {
        super.viewDidLoad()
        segmentedView.segmentStyle = .textOnly; segmentedView.insertSegment(withTitle: "COINS",  at: 0)
        segmentedView.insertSegment(withTitle: "MOST INC IN 24H", at: 1); segmentedView.insertSegment(withTitle: "MOS DEC IN 24H", at: 2)
        segmentedView.insertSegment(withTitle: "MOST INC IN 7D", at: 3); segmentedView.insertSegment(withTitle: "MOST DEC IN 7D", at: 4)
        segmentedView.underlineSelected = true; segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(MainController.segmentSelected(sender:)), for: .valueChanged)
    }
    
    func appStartingControls()
    {
        if CoreData.isEmpty()// First opening after downloading app, core data must be empty.
        {
            print("CORE DATA IS EMPTY.")
            showActivityIndicator(scroll: false)
            CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (navigationTitle) in
                DispatchQueue.main.async{
                    self.navigationItem.title = navigationTitle
                    self.saveCurrencies()
                    self.getSearchArray()
                    self.hideActivityIndicator()
                }
            }
        }
        else//Core must not be empty
        {
            print("CORE DATA IS NOT EMPTY")
            if !MainController.isCoreDataUpdated //App just update one time its core data for every time app has been launched
            {
                MainController.isCoreDataUpdated = true
                CoreData.getSupportedCurrencies { (currencies) in self.currencyTypes = currencies}
                CoreData.getCoins { (result) in
                    self.searchCoinArray = result
                    self.start()
                    DispatchQueue.global(qos: .background).async
                    {
                            self.getSearchArray()
                            self.updateCurrencies()
                            print("CORE DATA IS UPDATED.")
                            print("This is run on the background queue")
                    }
                    
                }
            }
        }
    }
   
    @objc func start()
    {
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (navigationTitle) in
            DispatchQueue.main.async{self.navigationItem.title = navigationTitle}
        }
        getCoins(page: 1, update: false, scroll: false)
        getCoinsFor24(page: 1, type: "INC",update: false, scroll: false);getCoinsFor24(page: 1, type: "DEC",update: false, scroll: false)
        getCoinsFor7(page: 1, type: "INC", update: false, scroll: false);getCoinsFor7(page: 1, type: "DEC", update: false, scroll: false)
    }
    
    @objc func update()
    {
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (navigationTitle) in
            DispatchQueue.main.async{self.navigationItem.title = navigationTitle}
        }
        getCoins(page: 1, update: true, scroll: false)
        getCoinsFor24(page: 1, type: "INC",update: true, scroll: false);getCoinsFor24(page: 1, type: "DEC",update: true, scroll: false)
        getCoinsFor7(page: 1, type: "INC", update: true,scroll: false);getCoinsFor7(page: 1, type: "DEC", update: true,scroll: false)
    }
    
    func getSearchArray()
    {
        let myGroup = DispatchGroup()
        self.searchCoinArray.removeAll(keepingCapacity: false)
        for n in 1...27
        {
            myGroup.enter()
            CoinGecko.getCoinMarkets(vs_currency: "usd", order: "id_asc", per_page: 250, page: n, sparkline: false, priceChangePercentage: "24h,7d", index: n) {(result) in
                self.searchCoinArray.append(contentsOf: result)
                DispatchQueue.main.async{self.tableView.reloadData()}
                myGroup.leave()
            }
           
        }
        myGroup.notify(queue: .main)
        {
            print(String(self.searchCoinArray.count) + "SEARCH CURRENCY ARRAY COUNT")
            if CoreData.isEmpty() //If it is the first time after downloading app
            {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.newBackgroundContext()
                let jsonCompatibleArray = self.searchCoinArray.map { model in
                        return [
                            "id":model.getId(),
                            "symbol":model.getSymbol(),
                            "name":model.getName(),
                            "image":model.getImageUrl(),
                            "market_cap_rank":model.getMarketCapRank(),
                            "price_change_24h":model.getPriceChange24(),
                            "price_change_percentage_24h_in_currency":model.getPriceChangePercantage24H(),
                            "price_change_percentage_7d_in_currency":model.getPriceChangePercantage7D()
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
                        print("CURRENCIES ARE SAVED.")
                        CoreData.getCoins { [self] (result) in
                            self.searchCoinArray = result
                            self.getCoinsFor24(page: 1, type: "INC",update: false,scroll: false);self.getCoinsFor24(page: 1, type: "DEC",update: false, scroll: false)
                            self.getCoinsFor7(page: 1, type: "INC",update: false, scroll: false);self.getCoinsFor7(page: 1, type: "DEC",update: false, scroll: false)
                        } 
                    }
                    catch{print("error")}
                }
                catch{print("ERROR")}
            }
            else//Updating session
            {
                print("Memory Coins Updated.")
                let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
                let result = try? managedObjectContext.fetch(fetchRequest)
                let resultData = result?[0] as! NSManagedObject
                let jsonCompatibleArray = self.searchCoinArray.map { model in
                    return [
                            "id":model.getId(),
                            "symbol":model.getSymbol(),
                            "name":model.getName(),
                            "image":model.getImageUrl(),
                            "market_cap_rank":model.getMarketCapRank(),
                            "price_change_24h":model.getPriceChange24(),
                            "price_change_percentage_24h_in_currency":model.getPriceChangePercantage24H(),
                            "price_change_percentage_7d_in_currency":model.getPriceChangePercantage7D()
                    ]
                }
                do
                {
                    let data = try JSONSerialization.data(withJSONObject: jsonCompatibleArray, options: .prettyPrinted)
                    let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    resultData.setValue(jsonString, forKey: "string")
                    do
                    {
                        try managedObjectContext.save()
                        print("CURRENCIES ARE UPDATED.")
                    }
                    catch{print("Error")}
                }
                catch{print("Error")}
            }
        }
    }
    
    ///Gets Coins from api. If update is true, func only update first 100 coin.
    func getCoins(page : Int, update: Bool, scroll: Bool)
    {
        if scroll {showActivityIndicator(scroll: true)}
        CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: page, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d" ) { (result) in
            if update
            {
                let first100Coin = result
                for (index,coin) in first100Coin.enumerated()
                {
                    self.coinArray[index] = coin
                }
                print("Page1 Updated.")
            }
            else if scroll
            {
                self.coinArray.append(contentsOf: result)
                print(String(self.coinArray.count) + "Count" + String(page) + "Page")
            }
            else if !update && !scroll
            {
                self.coinArray.append(contentsOf: result)
                print("Page1 First load.")
            }
            DispatchQueue.main.async {
                if scroll {self.hideActivityIndicator(); self.scrollingFetchProcess = false}
                self.tableView.reloadData()
            }
        }
    }
    
    /// Get coins according to 24H changes, type is for selecting INC or DEC
    func getCoinsFor24(page: Int, type : String, update: Bool, scroll: Bool)
    {
        if scroll {showActivityIndicator(scroll: true)}
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        print(String(copyArray.count) + "Cop6 sl")
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue > $1.getPriceChangePercantage24H().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue < $1.getPriceChangePercantage24H().doubleValue})}
            for m in ((page-1)*50)...((page*50)-1)
            {
                    newString += copyArray[m].getId() + ","
                    coinNumber[copyArray[m].getId()] = m + 1
            }
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    if update
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        for (index,coin) in first50Coin.enumerated()
                        {
                            self.mostIncIn24H[index] = coin
                        }
                        print("MostIncIn24H Updated.")
                    }
                    else if scroll
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        self.mostIncIn24H.append(contentsOf: first50Coin)
                        print(String(self.mostIncIn24H.count) + "Count" + String(page) + "Page")
                    }
                    else if !update && !scroll //First load
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        self.mostIncIn24H.append(contentsOf: first50Coin)
                        print("MostIncIn24H First Load.")
                    }
                }
                else if type == "DEC"
                {
                    if update
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        for (index,coin) in first50Coin.enumerated()
                        {
                            self.mostDecIn24H[index] = coin
                        }
                        print("MostDecIn24H Updated.")
                    }
                    else if scroll
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        self.mostDecIn24H.append(contentsOf: first50Coin)
                        print(String(self.mostDecIn24H.count) + "Count" + String(page) + "Page")
                    }
                    else if !update && !scroll //First load
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        self.mostDecIn24H.append(contentsOf: first50Coin)
                        print("MostIncIn24H Updated.")
                    }
                }
                DispatchQueue.main.async
                {
                    if scroll {self.hideActivityIndicator(); self.scrollingFetchProcess = false}
                    self.tableView.reloadData()
                }
            }
          
        }
    }
    
    /// Gets coins according to 7D changes, type is for selecting INC or DEC
    func getCoinsFor7(page: Int, type: String, update: Bool, scroll: Bool)
    {
        if scroll {showActivityIndicator(scroll: true)}
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue > $1.getPriceChangePercantage7D().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue < $1.getPriceChangePercantage7D().doubleValue})}
            for m in ((page-1)*50)...((page*50)-1)
            {
                    newString += copyArray[m].getId() + ","
                    coinNumber[copyArray[m].getId()] = m + 1
            }
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    if update
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        for (index,coin) in first50Coin.enumerated()
                        {
                            self.mostIncIn7D[index] = coin
                        }
                        print("MostIncIn7D Updated.")
                    }
                    else if scroll
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        self.mostIncIn7D.append(contentsOf: first50Coin)
                    }
                    else if !update && !scroll //First load
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                        self.mostIncIn7D.append(contentsOf: first50Coin)
                    }
                }
                else if type == "DEC"
                {
                    if update
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        for (index,coin) in first50Coin.enumerated()
                        {
                            self.mostDecIn7D[index] = coin
                        }
                        print("MostDecIn7D Updated.")
                    }
                    else if scroll
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        self.mostDecIn7D.append(contentsOf: first50Coin)
                    }
                    else if !update && !scroll //First load
                    {
                        var first50Coin = result
                        first50Coin = first50Coin.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                        self.mostDecIn7D.append(contentsOf: first50Coin)
                    }

                }
                DispatchQueue.main.async
                {
                    if scroll {self.hideActivityIndicator(); self.scrollingFetchProcess = false}
                    self.tableView.reloadData()
                }

            }
            
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
                    }
                    catch{print("error")}
                }
            }
        }
    }
    
    ///Gets supported currencies from api and updates into old data
    func updateCurrencies()
    {
        CoinGecko.getSupportedCurrencies() { (resultString) in
            DispatchQueue.main.async
            {
                
                let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CurrencyTypes")
                do
                {
                    let result = try? managedObjectContext.fetch(fetchRequest)
                    let resultData = result?[0] as! NSManagedObject
                    resultData.setValue(resultString, forKey: "types")
                    do
                    {
                        try managedObjectContext.save()
                        print("CURRENCY TYPES ARE UPDATED.")
                        self.currencyTypes = resultString.components(separatedBy: ",")//first index will be empty so be careful in table view
                    }
                    catch{print("Error")}
                }
            }
        } 
    }
    
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !searchActive
        {
            var coins = [Coin]()
            switch segmentedView.selectedSegmentIndex
            {
                case 0:
                        coins = self.coinArray;
                        if indexPath.row == coins.count-1 && !scrollingFetchProcess
                        {
                            MainController.coinsPage += 1;
                            getCoins(page: MainController.coinsPage, update: false, scroll: true);
                            scrollingFetchProcess = true
                        
                        }
                case 1:
                        coins = self.mostIncIn24H;
                        if indexPath.row == coins.count-1 && !scrollingFetchProcess
                        {
                            print("cem")
                            MainController.mostIncIn24Page += 1
                            getCoinsFor24(page: MainController.mostIncIn24Page, type: "INC",update: false,scroll: true);
                            scrollingFetchProcess = true
                        }
                    
                case 2:
                       coins = self.mostDecIn24H
                       if indexPath.row == coins.count-1 && !scrollingFetchProcess {MainController.mostDecIn24Page += 1;getCoinsFor24(page: MainController.mostDecIn24Page, type: "DEC",update: false,scroll: true);scrollingFetchProcess = true}
                    
                case 3:
                      coins = self.mostIncIn7D;
                      if indexPath.row == coins.count-1 && !scrollingFetchProcess { MainController.mostIncIn7dPage += 1;getCoinsFor7(page: MainController.mostIncIn7dPage, type: "INC", update: false, scroll: true);scrollingFetchProcess = true}
                    
                case 4:
                      coins = self.mostDecIn7D;
                      if indexPath.row == coins.count-1 && !scrollingFetchProcess {MainController.mostDecIn7dPage += 1;getCoinsFor7(page: MainController.mostDecIn7dPage, type: "DEC", update: false,scroll: true);scrollingFetchProcess = true}
                    
                default: print("Error")
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = 0
        if searchActive{count = self.searchActiveArray.count}
        else
        {
            switch tableViewPosition
            {
                case 0:count = self.coinArray.count
                case 1:count = self.mostIncIn24H.count
                case 2:count = self.mostDecIn24H.count
                case 3:count = self.mostIncIn7D.count
                case 4:count = self.mostDecIn7D.count
                default: return 0
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if !searchActive
        {
            var cellArrayGetIndex =  Coin()
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyCell
            switch tableViewPosition
            {
                case 0: if !coinArray.isEmpty {cellArrayGetIndex = self.coinArray[indexPath.row]}
                case 1: if !mostIncIn24H.isEmpty{cellArrayGetIndex = self.mostIncIn24H[indexPath.row]}
                case 2: if !mostDecIn24H.isEmpty{cellArrayGetIndex = self.mostDecIn24H[indexPath.row]}
                case 3: if !mostIncIn7D.isEmpty {cellArrayGetIndex = self.mostIncIn7D[indexPath.row]}
                case 4: if !mostDecIn7D.isEmpty {cellArrayGetIndex = self.mostDecIn7D[indexPath.row]}
                default:print("HATA")
            }
            Util.setCurrencyCell(cell: cell, coin: cellArrayGetIndex, index: indexPath.row, mainPage: true)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
            let cellSearchArrayGetIndex = self.searchActiveArray[indexPath.row]
            cell.label.text = cellSearchArrayGetIndex.getName()
            let url = URL(string: cellSearchArrayGetIndex.getImageUrl() )
            cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            return cell
        }
        
    }
 
    /// Table view func that is called when user press any cell, we are getting index of the selected cell and we are getting id of this currency
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if searchActive{ self.selectedSearchCoin = self.searchActiveArray[indexPath.row]}
        else
        {
            switch tableViewPosition
            {
                case 0: self.selectedCoin = self.coinArray[indexPath.row]
                case 1:self.selectedCoin = self.mostIncIn24H[indexPath.row]
                case 2:self.selectedCoin = self.mostDecIn24H[indexPath.row]
                case 3:self.selectedCoin = self.mostIncIn7D[indexPath.row]
                case 4:self.selectedCoin = self.mostDecIn7D[indexPath.row]
                default:print("HATA")
            }
        }
        performSegue(withIdentifier: "toCoinDetails", sender: self)
    }
    
    
    // MARK: - Button, segmented view, search bar triggering functions
    
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl)
    {
        switch sender.selectedSegmentIndex
        {
            case 0:tableViewPosition = 0
            case 1:tableViewPosition = 1
            case 2:tableViewPosition = 2
            case 3:tableViewPosition = 3
            case 4:tableViewPosition = 4
            default:break
        }
        self.tableView.reloadData()
    }
    
    @IBAction func searchButtonClicked(_ sender: Any)
    {
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItems?.removeAll()
        navigationItem.rightBarButtonItems?.removeAll()
        navigationItem.leftBarButtonItems?.append(arrowButton)
    }
    
    @IBAction func currencyButtonClicked(_ sender: Any){if self.currencyTypes.count > 0{performSegue(withIdentifier: "toCurrencySelector", sender: self)}}
    
    @IBAction func arrowButtonClicked(_ sender: Any)
    {
        self.navigationItem.titleView = nil
        navigationItem.leftBarButtonItems?.removeAll()
        navigationItem.leftBarButtonItems?.append(self.buttons[0])
        navigationItem.rightBarButtonItems?.append(self.buttons[1])
        self.searchActive = false
    }
    
    /// Search Bar Function
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        if searchText.isEmpty
        {
            self.tableView.reloadData()
            searchActive = false
        }
        else
        {
            searchActive = true
            self.searchActiveArray = self.searchCoinArray.filter{currencies in return currencies.getName().lowercased().contains(searchText.lowercased())}.sorted(by: {
                $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
            })
            self.tableView.reloadData()
        }
    }
    
    ///Adds swipe gestures for segmentedView
    func addSwipeGesture()
    {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer)
    {
           if let swipeGesture = gesture as? UISwipeGestureRecognizer
           {
               switch swipeGesture.direction
               {
                   case UISwipeGestureRecognizer.Direction.right: if (tableViewPosition != 4) {segmentedView.selectedSegmentIndex += 1}
                   case UISwipeGestureRecognizer.Direction.left:  if (tableViewPosition != 0) {segmentedView.selectedSegmentIndex -= 1}
                   default:break
               }
           }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        currencyTypes.remove(at: 0)
        if segue.identifier == "toCoinDetails"//We give our selected restaurant to next page
        {
            let destinationVC = segue.destination as! CoinDetailsController
            
            if searchActive
            {
                destinationVC.selectedSearchCoin = self.selectedSearchCoin
                destinationVC.type = 0 //it means we will come this page from a search operation
                destinationVC.currencyTypes = self.currencyTypes
                
            }
            else
            {
                destinationVC.selectedCoin = self.selectedCoin
                destinationVC.type = 1 // it means we will come this page from a normal selection operation
                destinationVC.currencyTypes = self.currencyTypes
                self.navigationItem.title = ""
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


