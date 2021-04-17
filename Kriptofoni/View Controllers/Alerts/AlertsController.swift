//
//  AlertsController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 17.04.2021.
//

import UIKit
import ScrollableSegmentedControl

class AlertsController: UIViewController,UITableViewDelegate, UITableViewDataSource
{
   
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var alarmsArray = [Alarm]()
    var watchingList = [Coin]()
    var watchingListId = [String]()
    var sSize: CGRect = UIScreen.main.bounds
    var selectedCoin = Coin()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        let sWidth = sSize.width
        segmentedView.frame.size.width = sWidth
        segmentedView.segmentStyle = .textOnly
        segmentedView.insertSegment(withTitle: "ALARMS",  at: 0)
        segmentedView.insertSegment(withTitle: "WATHCING LIST", at: 1);
        segmentedView.underlineSelected = true
        segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(self.segmentSelected(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        CoreData.getWatchingList { (result, string) in
            var newResult = result
            newResult.remove(at: 0)
            self.watchingListId = newResult
            self.getCoinsForWatchingList()
        }
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if segmentedView.selectedSegmentIndex == 0 // alarms
        {
            if alarmsArray.count > 0 {return alarmsArray.count}
            else {return 1}
        }
        else // watching list
        {
            if watchingList.count > 0 {return watchingList.count}
            else {return 1}
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if segmentedView.selectedSegmentIndex == 0 // alarms
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyCell
            return cell
        }
        else // watching list
        {
            if watchingList.count > 0
            {
                tableView.separatorStyle = .singleLine
                let cellArrayIndex = watchingList[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as! CurrencyCell
                Util.setCurrencyCell(cell: cell, coin: cellArrayIndex, index: indexPath.row, mainPage: false)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyWatchlistCell
                cell.label.text = "Kripto Para Eklenmedi"
                tableView.separatorStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if segmentedView.selectedSegmentIndex == 0 //alarms
        {
           height = 56
        }
        else // watching list
        {
            if watchingList.count > 0  {height = 56}
            else {height = 101}
        }
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedView.selectedSegmentIndex == 0 // alarms
        {
            
        }
        else // watching list
        {
            if watchingList.count > 0
            {
                self.selectedCoin = self.watchingList[indexPath.row]
                self.performSegue(withIdentifier: "toDetailsFromAlerts", sender: self)
            }
            else
            {
                
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "toDetailsFromAlerts"//We give our selected restaurant to next page
        {
            let destinationVC = segue.destination as! CoinDetailsController
            destinationVC.selectedCoin = self.selectedCoin
            destinationVC.type = 1 // Use coin model in coin details
            //destinationVC.currencyTypes = self.currencyTypes
        }
        
    }
    
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {self.tableView.reloadData()}
    
    
    func getCoinsForWatchingList()
    {
            var apiString = ""
            var watchingListTemp = [Coin]()
            for id in watchingListId {apiString = apiString + "," + id}
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: apiString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: [String: Int](), priceChangePercentage: "24h,7d") { (result) in
                    watchingListTemp.append(contentsOf: result)
                    watchingListTemp = watchingListTemp.sorted(by: {$0.getCount() < $1.getCount()})
                    self.watchingList = watchingListTemp
                    DispatchQueue.main.async{self.tableView.reloadData()}
            }
          
   }
}
    


