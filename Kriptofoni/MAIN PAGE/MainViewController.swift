//
//  MainViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 27.03.2021.
//

import UIKit
import ScrollableSegmentedControl
import SDWebImage


class MainViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    @IBOutlet var arrowButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    var buttons = [UIBarButtonItem]()
    var mostIncIn24H = [Currency]();var mostDecIn24H = [Currency]();var mostIncIn7D = [Currency]();var mostDecIn7D = [Currency]();var currencyArray = [Currency]()
    var searchCurrencyArray = [SearchCurrency](); var searchActiveArray = [SearchCurrency]()
    let coinGecko = CoinGecko()
    var tableViewPosition = 0
    var tableViewPage = 1
    let currentCurrencySymbol = "$"
    var searchActive = false
    var timer: Timer?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //appStartingControls()
        addSwipeGesture()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
        buttons.append(searchButton)
        buttons.append(currencyButton)
        segmentedView.segmentStyle = .textOnly
        segmentedView.insertSegment(withTitle: "COINS",  at: 0)
        segmentedView.insertSegment(withTitle: "MOST INC IN 24H", at: 1)
        segmentedView.insertSegment(withTitle: "MOS DEC IN 24H", at: 2)
        segmentedView.insertSegment(withTitle: "MOST INC IN 7D", at: 3)
        segmentedView.insertSegment(withTitle: "MOST DEC IN 7D", at: 4)
        segmentedView.underlineSelected = true
        segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(MainViewController.segmentSelected(sender:)), for: .valueChanged)
        appStartingControls()
    }
    
   
    @objc func update()
    {
        getCoins(page: tableViewPage)
        getCoinsFor24(page: 1, type: "INC")
        getCoinsFor24(page: 1, type: "DEC")
        getCoinsFor7(page: 1, type: "INC")
        getCoinsFor7(page: 1, type: "DEC")
    }
    
    func appStartingControls()
    {
        getCoins(page: tableViewPage)
        if CoreData.isEmpty()
        {
            print("CORE DATA EMPTY")
            getSearchArray()
            update()
            //timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
        else
        {
            print("CORE DATA IS NOT EMPTY")
            self.searchCurrencyArray = CoreData.getCurrencies()
            print(String(self.searchCurrencyArray.count) + "SEARCH CURRENCY COUNT1")
            update()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    func getSearchArray()
    {
        let myGroup = DispatchGroup()
        for n in 1...27
        {
            myGroup.enter()
            coinGecko.getCoinMarkets(vs_currency: "usd", order: "id_asc", per_page: 250, page: n, sparkline: false, priceChangePercentage: "24h,7d", index: n) {(result) in
                self.searchCurrencyArray.append(contentsOf: result)
                DispatchQueue.main.async{self.tableView.reloadData()}
                myGroup.leave()
            }
            onFailure: {print("Could not download from api")}
        }
        myGroup.notify(queue: .main)
        {
            if CoreData.isEmpty()
            {
                for curr in self.searchCurrencyArray
                {
                    CoreData.createCurrency(currency: curr)
                     
                }
            }
            else
            {
                CoreData.deleteAll()
                for curr in self.searchCurrencyArray
                {
                    CoreData.createCurrency(currency: curr)
                }
            }
            print(String(self.searchCurrencyArray.count) + "SEARCH CURRENCY COUNT2")
            self.getCoinsFor24(page: 1, type: "INC")
            self.getCoinsFor24(page: 1, type: "DEC")
            self.getCoinsFor7(page: 1, type: "INC")
            self.getCoinsFor24(page: 1, type: "DEC")
        }
    }
    
    
    //Gets coins from api
    func getCoins(page : Int)
    {
        let emptyHashMap = [String : Int]()
        coinGecko.getCoins(vs_currency: "usd",ids: "", order: "market_cap_desc", per_page: 100, page: page, sparkline: false, hashMap: emptyHashMap, priceChangePercentage: "24h_7d" ) { (result) in
            self.currencyArray.append(contentsOf: result)
            DispatchQueue.main.async{self.tableView.reloadData()}
        }
        onFailure: {print("Could not download from api")}
    }
    
    func getCoinsFor24(page: Int, type : String)
    {
        var copyArray = self.searchCurrencyArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"
            {
                self.mostIncIn24H.removeAll(keepingCapacity: false)
                copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue > $1.getPriceChangePercantage24H().doubleValue})
            }
            else if type == "DEC"
            {
                self.mostDecIn24H.removeAll(keepingCapacity: false)
                copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage24H().doubleValue < $1.getPriceChangePercantage24H().doubleValue})
                print(copyArray)
            }
            for m in 0...49
            {
                newString += copyArray[m].getId() + ","
                print(type + copyArray[m].getPriceChangePercantage24H().stringValue + "LOGLOGLOG" + copyArray[m].getName() + String(m))
                coinNumber[copyArray[m].getId()] = m + 1
            }
            coinGecko.getCoins(vs_currency: "usd",ids: newString, order: "market_cap_desc", per_page: 50, page: page , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    self.mostIncIn24H.append(contentsOf: result)
                    self.mostIncIn24H = self.mostIncIn24H.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                    print(String(self.mostIncIn24H.count) + "INCXXXX")
                }
                else if type == "DEC"
                {
                   
                    self.mostDecIn24H.append(contentsOf: result)
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn24H = self.mostDecIn24H.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                    print(String(self.mostDecIn24H.count) + "DECXXX")
                }
                DispatchQueue.main.async{self.tableView.reloadData()}
            }
            onFailure: {print("Could not download from api")}
        }
    }
    
    func getCoinsFor7(page: Int, type: String)
    {
        var copyArray = self.searchCurrencyArray
        var coinNumber = [String : Int]()
        if copyArray.count > 6000
        {
            var newString = ""
            if type == "INC"
            {
                self.mostIncIn7D.removeAll(keepingCapacity: false)
                copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue > $1.getPriceChangePercantage7D().doubleValue})
            }
            else if type == "DEC"
            {
                self.mostDecIn7D.removeAll(keepingCapacity: false)
                copyArray = copyArray.sorted(by: {$0.getPriceChangePercantage7D().doubleValue < $1.getPriceChangePercantage7D().doubleValue})
            }
            for m in 0...49
            {
                newString += copyArray[m].getId() + ","
                print(type + copyArray[m].getPriceChangePercantage24H().stringValue + "LOGLOGLOG" + copyArray[m].getName() + String(m))
                coinNumber[copyArray[m].getId()] = m + 1
            }
            coinGecko.getCoins(vs_currency: "usd",ids: newString, order: "market_cap_desc", per_page: 50, page: page , sparkline: false, hashMap: coinNumber, priceChangePercentage: "24h,7d") { (result) in
                if type == "INC"
                {
                    self.mostIncIn7D.append(contentsOf: result)
                    self.mostIncIn7D = self.mostIncIn7D.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostIncIn7D = self.mostIncIn7D.sorted(by: {$0.getPercent().doubleValue > $1.getPercent().doubleValue})
                }
                else if type == "DEC"
                {
                   
                    self.mostDecIn7D.append(contentsOf: result)
                    self.mostDecIn7D = self.mostDecIn7D.sorted(by: {$0.getCount() < $1.getCount()})
                    self.mostDecIn7D  = self.mostDecIn7D.sorted(by: {$0.getPercent().doubleValue < $1.getPercent().doubleValue})
                    print(self.mostIncIn7D)
                }
                DispatchQueue.main.async{self.tableView.reloadData()}
            }
            onFailure: {print("Could not download from api")}
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = 0
        switch tableViewPosition
        {
        case 0:
            if searchActive{count =  self.searchActiveArray.count}
            else{count =  self.currencyArray.count}
        case 1:
            if searchActive{count =  self.searchActiveArray.count}
            else{count =  self.mostIncIn24H.count}
        case 2:
            if searchActive{count = self.searchActiveArray.count}
            else{count = self.mostDecIn24H.count}
        case 3:
            if searchActive{count = self.searchActiveArray.count}
            else{count = self.mostIncIn7D.count}
        case 4:
            if searchActive{count =  self.searchActiveArray.count}
            else{ count = self.mostDecIn7D.count}
        default:
            print("error")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !searchActive
        {
            var cellArrayGetIndex =  Currency()
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyCell
            switch tableViewPosition {
            case 0:
                 cellArrayGetIndex = self.currencyArray[indexPath.row]
            case 1:
                 cellArrayGetIndex = self.mostIncIn24H[indexPath.row]
            case 2:
                 cellArrayGetIndex = self.mostDecIn24H[indexPath.row]
            case 3:
                 cellArrayGetIndex = self.mostIncIn7D[indexPath.row]
            case 4:
                 cellArrayGetIndex = self.mostDecIn7D[indexPath.row]
            default:
                print("HATA")
            }
            let url = URL(string: cellArrayGetIndex.getIconViewUrl())
            cell.iconView.sd_setImage(with: url) { (_, _, _, _) in}
            cell.name.text = cellArrayGetIndex.getName()
            let percent = cellArrayGetIndex.getPercent()
            if percent.intValue > 0{cell.percent.textColor = UIColor.green}
            else{cell.percent.textColor = UIColor.red}
            cell.percent.text = "%" + percent.stringValue
            let change = cellArrayGetIndex.getChange()
            if change.intValue > 0{cell.change.textColor = UIColor.green}
            else{cell.change.textColor = UIColor.red}
            cell.change.text = change.stringValue
            cell.price.text = "$" + cellArrayGetIndex.getPrice().stringValue
            cell.shortening.text = "#" + String(indexPath.row + 1) +  " - " + cellArrayGetIndex.getShortening().uppercased()
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCurrencyCell
            let cellSearchArrayGetIndex = self.searchActiveArray[indexPath.row]
            cell.label.text = cellSearchArrayGetIndex.getName()
            let url = URL(string: cellSearchArrayGetIndex.getImageUrl() )
            cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            return cell
        }
        
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
        case 0:
            tableViewPosition = 0
        case 1:
            tableViewPosition = 1
            
        case 2:
            tableViewPosition = 2
            
        case 3:
            tableViewPosition = 3
        case 4:
            tableViewPosition = 4
        default:
            break
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
    
    @IBAction func currencyButtonClicked(_ sender: Any){print("ARRAY" + String(self.searchCurrencyArray.count))}
    
    @IBAction func arrowButtonClicked(_ sender: Any)
    {
        self.navigationItem.titleView = nil
        self.navigationItem.title = "30000000000$"
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
            print(searchText)
            print(self.searchCurrencyArray.count)
            self.searchActiveArray = self.searchCurrencyArray.filter{currencies in return currencies.getName().lowercased().contains(searchText.lowercased())}.sorted(by: {
                $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
            })
            
            self.tableView.reloadData()
        }
    }
    
    
    
    //Adds swipe gestures for segmentedView
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
               case UISwipeGestureRecognizer.Direction.right:
                   if (tableViewPosition != 4)
                   {
                      segmentedView.selectedSegmentIndex += 1
                   }
               case UISwipeGestureRecognizer.Direction.left:
                   if (tableViewPosition != 0)
                   {
                      segmentedView.selectedSegmentIndex -= 1
                   }
                   default:
                       break
               }
           }
       }
    
    
   
    

}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}
