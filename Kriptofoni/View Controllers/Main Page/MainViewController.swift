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


class MainViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    @IBOutlet var arrowButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    var selectedIndexPath = IndexPath(row: 0, section: 0);var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    var buttons = [UIBarButtonItem]()
    var mostIncIn24H = [Coin]();var mostDecIn24H = [Coin]();var mostIncIn7D = [Coin]();var mostDecIn7D = [Coin]();var coinArray = [Coin]()
    var searchCoinArray = [SearchCoin](); var searchActiveArray = [SearchCoin](); var currencyTypes = [String]()
    let coinGecko = CoinGecko()
    var tableViewPosition = 0;var tableViewPage = 1
    var currentCurrencySymbol = "$"; var currentCurrencyKey = "usd";var selectedCoin = ""
    var searchActive = false
    var timer: Timer?
    var isAfterCurrencyChanging = false
   

    override func viewDidLoad()
    {
        super.viewDidLoad()
        appStartingControls()
        addSwipeGesture()
        self.tableView.delegate = self;self.tableView.dataSource = self;self.searchBar.delegate = self
        buttons.append(searchButton); buttons.append(currencyButton)
        segmentedView.segmentStyle = .textOnly; segmentedView.insertSegment(withTitle: "COINS",  at: 0)
        segmentedView.insertSegment(withTitle: "MOST INC IN 24H", at: 1); segmentedView.insertSegment(withTitle: "MOS DEC IN 24H", at: 2)
        segmentedView.insertSegment(withTitle: "MOST INC IN 7D", at: 3); segmentedView.insertSegment(withTitle: "MOST DEC IN 7D", at: 4)
        segmentedView.underlineSelected = true; segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(MainViewController.segmentSelected(sender:)), for: .valueChanged)
    }
    
    func appStartingControls()
    {
        getCoins(page: tableViewPage)
        if CoreData.isEmpty()// First opening after downloading app, core data must be empty.
        {
            print("CORE DATA IS EMPTY.")
            coinGecko.getTotalMarketValue(currency: currentCurrencyKey, symbol: currentCurrencySymbol) { (navigationTitle) in
                DispatchQueue.main.async{self.navigationItem.title = navigationTitle}
            } onFailure: {print("Error: While trying to fetch total market cap")}
            saveCurrencies()
            getSearchArray()
            timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
        else//Core must not be empty, it should update itself
        {
            print("CORE DATA IS NOT EMPTY")
            CoreData.getSupportedCurrencies { (currencies) in
                self.currencyTypes = currencies
                print(String(self.currencyTypes.count) + "COUNT")
            } onFailure: {print("Error: Failed to load currencies.")}
            CoreData.getCoins { (result) in
                self.searchCoinArray = result
                self.update()
                if !self.isAfterCurrencyChanging // if it is coming from currency type selector page, do not update any data in core data
                {
                    self.getSearchArray()
                    self.updateCurrencies()
                }
                self.timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            } onFailure: {print("HATAAA")}

        }
    }
   
    @objc func update()
    {
        print("UPDATED")
        coinGecko.getTotalMarketValue(currency: currentCurrencyKey, symbol: currentCurrencySymbol) { (navigationTitle) in
            DispatchQueue.main.async{self.navigationItem.title = navigationTitle}
        } onFailure: {print("Error: While trying to fetch total market cap")}
        getCoins(page: tableViewPage)
        getCoinsFor24(page: 1, type: "INC");getCoinsFor24(page: 1, type: "DEC")
        getCoinsFor7(page: 1, type: "INC");getCoinsFor7(page: 1, type: "DEC")
    }
    
    func getSearchArray()
    {
        let myGroup = DispatchGroup()
        self.searchCoinArray.removeAll(keepingCapacity: false)
        for n in 1...27
        {
            myGroup.enter()
            coinGecko.getCoinMarkets(vs_currency: "usd", order: "id_asc", per_page: 250, page: n, sparkline: false, priceChangePercentage: "24h,7d", index: n) {(result) in
                self.searchCoinArray.append(contentsOf: result)
                DispatchQueue.main.async{self.tableView.reloadData()}
                myGroup.leave()
            }
            onFailure: {print("Could not download from api")}
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
                            self.getCoinsFor24(page: 1, type: "INC");self.getCoinsFor24(page: 1, type: "DEC")
                            self.getCoinsFor7(page: 1, type: "INC");self.getCoinsFor7(page: 1, type: "DEC")
                        } onFailure: {
                            print("CORE DATA GETTING COINS ERROR")
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
                    return
                    [
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
    
    ///Gets COINS from api
    func getCoins(page : Int)
    {
        let emptyHashMap = [String : Int]()
        coinGecko.getCoins(vs_currency: currentCurrencyKey,ids: "", order: "market_cap_desc", per_page: 100, page: page, sparkline: false, hashMap: emptyHashMap, priceChangePercentage: "24h,7d" ) { (result) in
            self.coinArray.removeAll(keepingCapacity: false)
            self.coinArray.append(contentsOf: result)
            DispatchQueue.main.async{self.tableView.reloadData()}
        }
        onFailure: {print("Could not download from api")}
    }
    
    /// Get coins according to 24H changes, type is for selecting INC or DEC
    func getCoinsFor24(page: Int, type : String)
    {
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue > $1.getPriceChangePercantage24H().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue < $1.getPriceChangePercantage24H().doubleValue})}
            for m in 0...49
            {
                newString += copyArray[m].getId() + ","
                coinNumber[copyArray[m].getId()] = m + 1
            }
            coinGecko.getCoins(vs_currency: currentCurrencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: page , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    self.mostIncIn24H.removeAll(keepingCapacity: false)
                    self.mostIncIn24H.append(contentsOf: result)
                    self.mostIncIn24H = self.mostIncIn24H.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                }
                else if type == "DEC"
                {
                    self.mostDecIn24H.removeAll(keepingCapacity: false)
                    self.mostDecIn24H.append(contentsOf: result)
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                }
                DispatchQueue.main.async{self.tableView.reloadData()}
            }
            onFailure: {print("Could not download from api")}
        }
    }
    
    /// Gets coins according to 7D changes, type is for selecting INC or DEC
    func getCoinsFor7(page: Int, type: String)
    {
        var copyArray = self.searchCoinArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue > $1.getPriceChangePercantage7D().doubleValue})}
            else if type == "DEC"{copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue < $1.getPriceChangePercantage7D().doubleValue})}
            for m in 0...49
            {
                newString += copyArray[m].getId() + ","
                coinNumber[copyArray[m].getId()] = m + 1
            }
            coinGecko.getCoins(vs_currency: currentCurrencyKey,ids: newString, order: "market_cap_desc", per_page: 50, page: page , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    self.mostIncIn7D.removeAll(keepingCapacity: false)
                    self.mostIncIn7D.append(contentsOf: result)
                    self.mostIncIn7D = self.mostIncIn7D.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostIncIn7D = self.mostIncIn7D.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                }
                else if type == "DEC"
                {
                    self.mostDecIn7D.removeAll(keepingCapacity: false)
                    self.mostDecIn7D.append(contentsOf: result)
                    self.mostDecIn7D = self.mostDecIn7D.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn7D  = self.mostDecIn7D.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                }
                DispatchQueue.main.async{self.tableView.reloadData()}
            }
            onFailure: {print("Could not download from api")}
        }
    }
    
    func saveCurrencies()
    {
        coinGecko.getSupportedCurrencies() { (resultString) in
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
        } onFailure: {print("HATA")}
    }
    
    func updateCurrencies()
    {
        coinGecko.getSupportedCurrencies() { (resultString) in
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
        } onFailure: {
            print("HATA")
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
            print(String(indexPath.row) + "INDEX")
            switch tableViewPosition
            {
                case 0:
                    if !coinArray.isEmpty {cellArrayGetIndex = self.coinArray[indexPath.row]}
                    if indexPath.row > 60
                    {
                        
                    }
                case 1:
                    if !mostIncIn24H.isEmpty{cellArrayGetIndex = self.mostIncIn24H[indexPath.row]}
                    if indexPath.row > 30
                    {
                        
                    }
                case 2:
                    if !mostDecIn24H.isEmpty{cellArrayGetIndex = self.mostDecIn24H[indexPath.row]}
                    if indexPath.row > 30
                    {
                        
                    }
                case 3:
                    if !mostIncIn7D.isEmpty {cellArrayGetIndex = self.mostIncIn7D[indexPath.row]}
                    if indexPath.row > 30
                    {
                        
                    }
                case 4:
                    if !mostDecIn7D.isEmpty {cellArrayGetIndex = self.mostDecIn7D[indexPath.row]}
                    if indexPath.row > 30
                    {
                        
                    }
                default:print("HATA")
            }
            let url = URL(string: cellArrayGetIndex.getIconViewUrl())
            cell.iconView.sd_setImage(with: url) { (_, _, _, _) in}
            cell.name.text = cellArrayGetIndex.getName()
            let percent = cellArrayGetIndex.getPercent()
            if percent.intValue > 0{cell.percent.textColor = UIColor.green}
            else{cell.percent.textColor = UIColor.red}
            cell.percent.text = "%" + String(format: "%.2f", percent.doubleValue)
            let change = cellArrayGetIndex.getChange()
            if change.intValue > 0{cell.change.textColor = UIColor.green}
            else{cell.change.textColor = UIColor.red}
            cell.change.text = String(format: "%.3f", change.doubleValue)
            cell.price.text = currentCurrencySymbol + " " + String(format: "%.3f", cellArrayGetIndex.getPrice().doubleValue)
            cell.shortening.text = "#" + String(indexPath.row + 1) +  " - " + cellArrayGetIndex.getShortening().uppercased()
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
        if searchActive{ selectedCoin = self.searchActiveArray[indexPath.row].getId()}
        else
        {
            switch tableViewPosition
            {
                case 0:selectedCoin = self.coinArray[indexPath.row].getId()
                case 1:selectedCoin = self.mostIncIn24H[indexPath.row].getId()
                case 2:selectedCoin = self.mostDecIn24H[indexPath.row].getId()
                case 3:selectedCoin = self.mostIncIn7D[indexPath.row].getId()
                case 4:selectedCoin = self.mostDecIn7D[indexPath.row].getId()
                default:print("HATA")
            }
        }
        performSegue(withIdentifier: "toCoinDetails", sender: self)
    }
    
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height
        {
            tableViewPage += 1
            getCoins(page: tableViewPage)
            print("scrolling" + String(self.currencyArray.count))
        }
    }
    */
 
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl)
    {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
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
    
    @IBAction func currencyButtonClicked(_ sender: Any)
    {
        print(String(self.currencyTypes.count) + "COUNT2")
        if self.currencyTypes.count > 0
        {
            performSegue(withIdentifier: "toCurrencySelector", sender: self)
        }
        
    }
    
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
        if segue.identifier == "toCoinDetails"//We give our selected restaurant to next page
        {
            let destinationVC = segue.destination as! SelectedCoinViewController
            destinationVC.coinId = self.selectedCoin
        }
        else if segue.identifier == "toCurrencySelector"
        {
            let destinationVC = segue.destination as! CurrencySelectorViewController
            destinationVC.currencyArray = self.currencyTypes
        }
    }
    
}




