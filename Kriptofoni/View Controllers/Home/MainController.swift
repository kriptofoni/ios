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
    var searchCoinArray = [Coin](); var searchActiveArray = [Coin](); var currencyTypes = [String]()
    let coinGecko = CoinGecko()
    var tableViewPosition = 0;
    static var coinsPage = 1
    static var mostIncIn24Page = 1
    static var mostDecIn24Page = 1
    static var mostIncIn7dPage = 1
    static var mostDecIn7dPage  = 1
    static var isCoreDataUpdated = false
    var selectedCoin = Coin(); var selectedSearchCoin = Coin()
    var searchActive = false
    var timer: Timer?
    var isFirstTime = true
    var sSize: CGRect = UIScreen.main.bounds
    var scrollingFetchProcess = false
    
   
    //Locks the screen before view is appeared and realease this locking before view is disappeared
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
        timer?.invalidate();timer = nil
    }
    
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
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(updateMain), userInfo: nil, repeats: true)
        
    }
    
    //Did this over there becuase i do not want to add segments to segmented view every time i open this controller
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setSegmentSettings()
    }
    
    func appStartingControls()
    {
            if !MainController.isCoreDataUpdated //App just update one time its core data for every time app has been launched
            {
                MainController.isCoreDataUpdated = true
                self.navigationItem.title = LaunchScreenController.totalMarketValue
                self.currencyTypes = LaunchScreenController.currencyTypes
                self.coinArray = LaunchScreenController.coinArray ; print(coinArray.count); print("Coin Array")
                self.searchCoinArray = LaunchScreenController.searchCoinArray
                self.mostIncIn24H = LaunchScreenController.mostIncIn24H
                self.mostDecIn24H = LaunchScreenController.mostDecIn24H
                self.mostIncIn7D = LaunchScreenController.mostIncIn7D
                self.mostDecIn7D = LaunchScreenController.mostDecIn7D
                if !WelcomeController.isWelcomeOpened
                {
                    DispatchQueue.global(qos: .background).async
                    {
                        self.updateAllCoins()
                        self.updateCurrencies()
                        
                    }
                }
               
            }
            else //controller opening 
            {
                updateMain()
            }
    }
   
    
    @objc func updateMain()
    {
        CoinGecko.getTotalMarketValue(currency: Currency.currencyKey, symbol: Currency.currencySymbol) { (navigationTitle) in
            DispatchQueue.main.async{self.navigationItem.title = navigationTitle}
        }
        getCoins(page: 1, update: true, scroll: false)
    }
    
    func updateAllCoins()
    {
        let myGroup = DispatchGroup()
        var tempAllCoins = [Coin]()
        for n in 1...27
        {
            myGroup.enter()
            CoinGecko.getCoins(vs_currency: "usd", ids: "", order: "id_asc", per_page: 250, page: n, sparkline: false, hashMap: [String : Int](), priceChangePercentage: "24h,7d") { result in
                tempAllCoins.append(contentsOf: result)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main)
        {
            self.searchCoinArray = tempAllCoins
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StringCurrency")
            fetchRequest.returnsObjectsAsFaults = false
            do
            {
                let results = try managedObjectContext.fetch(fetchRequest)
                for managedObject in results
                {
                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedObjectContext.delete(managedObjectData)
                }
                try managedObjectContext.save()
                print("Core data deleted.")
            }
            catch
            {
                print("Core data cannot be deleted")
            }
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
                let newCurrency = NSEntityDescription.insertNewObject(forEntityName: "StringCurrency", into: managedObjectContext)
                newCurrency.setValue(jsonString, forKey: "string")
                do
                {
                    try managedObjectContext.save()
                    print("COINS ARE UPDATED.")
                    WelcomeController.isWelcomeOpened = true
                    WelcomeController.coinsCompleted = true
                }
                catch{print("error")}
            }
            catch{print("ERROR")}
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
            DispatchQueue.main.async
            {
                if scroll {self.hideActivityIndicator(); self.scrollingFetchProcess = false}
                self.tableView.reloadData()
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
                        return
                       
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
            if segmentedView.selectedSegmentIndex == 0
            {
                coins = self.coinArray;
                if indexPath.row == coins.count-1 && !scrollingFetchProcess
                {
                    MainController.coinsPage += 1;
                    getCoins(page: MainController.coinsPage, update: false, scroll: true);
                    scrollingFetchProcess = true
                
                }
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
            var sevenDay = false
            switch tableViewPosition
            {
                case 0: if !coinArray.isEmpty {cellArrayGetIndex = self.coinArray[indexPath.row]}
                case 1: if !mostIncIn24H.isEmpty{cellArrayGetIndex = self.mostIncIn24H[indexPath.row]}
                case 2: if !mostDecIn24H.isEmpty{cellArrayGetIndex = self.mostDecIn24H[indexPath.row]}
                case 3: if !mostIncIn7D.isEmpty {cellArrayGetIndex = self.mostIncIn7D[indexPath.row]; sevenDay = true}
                case 4: if !mostDecIn7D.isEmpty {cellArrayGetIndex = self.mostDecIn7D[indexPath.row]; sevenDay = true}
                default:print("HATA")
            }
            Util.setCurrencyCell(cell: cell, coin: cellArrayGetIndex, index: indexPath.row, mainPage: true,sevenDay: sevenDay)
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
            let cellSearchArrayGetIndex = self.searchActiveArray[indexPath.row]
            cell.label.text = cellSearchArrayGetIndex.getName()
            let url = URL(string: cellSearchArrayGetIndex.getIconViewUrl() )
            cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            return cell
        }
        
    }
 
    /// Table view func that is called when user press any cell, we are getting index of the selected cell and we are getting id of this currency
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if searchActive {self.selectedSearchCoin = self.searchActiveArray[indexPath.row]}
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
                destinationVC.selectedCoin = self.selectedSearchCoin
            }
            else
            {
                destinationVC.selectedCoin = self.selectedCoin
            }
            destinationVC.currencyTypes = self.currencyTypes
            self.navigationItem.title = ""
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
    
    func setSegmentSettings()
    {
        segmentedView.segmentStyle = .textOnly; segmentedView.insertSegment(withTitle: "Kripto Paralar",  at: 0)
        segmentedView.insertSegment(withTitle: "24 Saatin Yükselenleri", at: 1); segmentedView.insertSegment(withTitle: "24 Saatin Düşenleri", at: 2)
        segmentedView.insertSegment(withTitle: "7 Günün Yükselenleri", at: 3); segmentedView.insertSegment(withTitle: " 7 Günün Düşenleri", at: 4)
        segmentedView.underlineSelected = true; segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(MainController.segmentSelected(sender:)), for: .valueChanged)
        self.segmentedView.backgroundColor = UIColor(named: "Header Color")
        self.segmentedView.selectedSegmentContentColor = Util.defaultFont
        
    }
}


