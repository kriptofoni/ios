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
   
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var currencyChangeButton: UIBarButtonItem!
    @IBOutlet weak var segmentedView: ScrollableSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addAndDeleteButton: UIBarButtonItem!
    var activityView: UIActivityIndicatorView?
    var alarmsArray = [Alarm]()
    var watchingList = [Coin]()
    var searchCoinArray = [SearchCoin]()
    var watchingListId = [String]()
    var sSize: CGRect = UIScreen.main.bounds
    var selectedCoin = Coin()
    var timer: Timer?
    var currencyTypes = [String]()
    var deleteMode = false
    let plusButton = UIButton()
    var coinsForDeleting = [String]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        self.currencyChangeButton.title = Currency.currencyKey.uppercased()
        //timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(start), userInfo: nil, repeats: true)
        if segmentedView.selectedSegmentIndex == 1
        {
            self.navigationItem.title = "İzleme Listesi"
            refreshWatchingList()
        }
        else
        {
            self.navigationItem.title = "Alarmlar"
            
        }
    }
    
    //Locks the screen before view is appeared and realease this locking before view is disappeared
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
        timer?.invalidate();timer = nil
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addSwipeGesture()
        setSegmentedView()
        tableView.delegate = self; tableView.dataSource = self
        
    }
    
   
    
    
    func refreshWatchingList()
    {
        CoreDataWatchingList.getWatchingList { (result, string) in
            
            if string != ""
            {
                self.watchingListId = result
                self.watchingListId.remove(at: 0)
                self.getCoinsForWatchingList()
            }
            else
            {
                self.watchingList = [Coin]()
                self.tableView.reloadData()
            }
           
        }
    }
    
    func getCoinsForWatchingList()
    {
        var apiString = ""
        var watchingListTemp = [Coin]()
        for id in watchingListId
        {
            if apiString == "" {apiString = id}
            else { apiString = apiString + "," + id}
        }
        if apiString != ""
        {
            DispatchQueue.main.async{self.showActivityIndicator()}
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: apiString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: [String: Int](), priceChangePercentage: "24h,7d") { (result) in
                    watchingListTemp.append(contentsOf: result)
                    watchingListTemp = watchingListTemp.sorted(by: {$0.getCount() < $1.getCount()})
                    self.watchingList = watchingListTemp
                    DispatchQueue.main.async
                    {
                        self.tableView.reloadData()
                        self.hideActivityIndicator()
                    }
            }
        }
        
    }
    
    @objc func update()
    {
        if !deleteMode
        {
            if segmentedView.selectedSegmentIndex == 0
            {
               
            }
            else
            {
                refreshWatchingList()
            }
        }
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if segmentedView.selectedSegmentIndex == 0 // alarms
        {
            let cell = UITableViewCell()
            return cell
        }
        else // watching list
        {
            print(watchingList.count)
            if watchingList.count > 0
            {
                tableView.separatorStyle = .singleLine
                let cell = tableView.dequeueReusableCell(withIdentifier: "watchingListCell", for: indexPath) as! WatchingListCell
                let cellArrayIndex = watchingList[indexPath.row]
                let url = URL(string: cellArrayIndex.getIconViewUrl())
                cell.symbolView.sd_setImage(with: url) { (_, _, _, _) in}
                cell.name.text = cellArrayIndex.getName()
                Util.changeLabelColor(data: cellArrayIndex.getPercent().doubleValue, label: cell.percent)
                Util.changeLabelColor(data: cellArrayIndex.getPercent().doubleValue, label: cell.price)
                cell.percent.text = "%" + String(format: "%.2f", cellArrayIndex.getPercent().doubleValue)
                cell.price.text = Currency.currencySymbol + " " + Util.toPrice(cellArrayIndex.getPrice().doubleValue, isCoinDetailPrice: false)
                cell.count.text = String(indexPath.row + 1)
                cell.count.isHidden = deleteMode
                cell.checkButton.isHidden = !deleteMode
                if !deleteMode //when delete mode is turned off, erase the thick
                {
                    cell.checkButton.setImage(nil, for: .normal)
                }
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyWatchlistCell
                cell.label.text = "Watching list is empty."
                cell.button.addTarget(self, action: #selector(self.addCoin(sender:)), for: .touchUpInside)
                tableView.separatorStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if segmentedView.selectedSegmentIndex == 0 //alarms
        {
            
        }
        else //watching list
        {
            if !self.watchingList.isEmpty
            {
                let cell = tableView.cellForRow(at: indexPath) as! WatchingListCell
                if !deleteMode //if delete mode is closed
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
                else // else delete mode is open
                {
                    tableView.deselectRow(at: indexPath, animated: true)
                    cell.isChecked = !cell.isChecked
                    if cell.isChecked
                    {
                        self.coinsForDeleting.append(self.watchingList[indexPath.row].getId())
                        dump(self.coinsForDeleting)
                        cell.checkButton.setImage(UIImage(named: "arrow"), for: .normal)
                    }
                    else
                    {
                        self.coinsForDeleting.removeAll{$0 == self.watchingList[indexPath.row].getId()}
                        dump(self.coinsForDeleting)
                        cell.checkButton.setImage(nil, for: .normal)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if segmentedView.selectedSegmentIndex == 0 // alarms
        {
            if alarmsArray.count > 0 {return alarmsArray.count}
            else {return 0}
        }
        else // watching list
        {
            if watchingList.count > 0 {return watchingList.count}
            else {return 1}
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if segmentedView.selectedSegmentIndex == 0
        {
           height = 56 //alarms
        }
        else // watching list
        {
            if watchingList.count > 0  {height = 56}
            else {height = 288}
        }
        return CGFloat(height)
    }
    
    // MARK: - Button Clicks
    
    /// Pushs the necessary array to table view according to segmented control
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        if segmentedView.selectedSegmentIndex == 1
        {
            refreshWatchingList()
            self.navigationItem.title = "İzleme Listesi"
        }
        else
        {
            self.tableView.reloadData()
            self.navigationItem.title = "Alarmlar"
        }
        
    }
    
    @objc func addCoin(sender: Any)
    {
        CoreData.getCoins { [self] (result) in
            searchCoinArray = result
            print("Count" + String(searchCoinArray.count))
            performSegue(withIdentifier: "toAddWatchingList", sender: self)
        } 
    }
    
    @IBAction func currencySelectorButtonClicked(_ sender: Any) {self.performSegue(withIdentifier: "toCurrencySelector", sender: self)}
    
    @IBAction func editButtonAction(_ sender: Any)
    {
        if segmentedView.selectedSegmentIndex == 1
        {
            if !deleteMode
            {
                deleteMode = true
                self.tableView.allowsMultipleSelection = true
                self.tableView.allowsMultipleSelectionDuringEditing = true
                self.editButton.tintColor = UIColor.systemBlue
                self.addAndDeleteButton.title = "Delete"
            }
            else
            {
                deleteMode = false
                self.tableView.allowsMultipleSelection = false
                self.tableView.allowsMultipleSelectionDuringEditing = false
                self.editButton.tintColor = Util.hexStringToUIColor(hex: "797676")
                self.addAndDeleteButton.title = "Add"
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addAndDeleteButtonAction(_ sender: Any)
    {
        if deleteMode // deleting mode
        {
            if !self.coinsForDeleting.isEmpty
            {
                CoreDataWatchingList.deleteCoinFromWatchingList(ids: self.coinsForDeleting) { (bool) in
                    self.deleteMode = false
                    self.update()
                    self.tableView.allowsMultipleSelection = false
                    self.tableView.allowsMultipleSelectionDuringEditing = false
                    self.editButton.tintColor = Util.hexStringToUIColor(hex: "797676")
                    self.addAndDeleteButton.title = "Add"
                }
            }
            else
            {
                self.makeAlert(titleInput: "Oops!", messageInput: "Please select a coin to delete from watching list.")
            }
            
        }
        else // adding mode
        {
            CoreData.getCoins { [self] (result) in
                searchCoinArray = result
                print("Count" + String(searchCoinArray.count))
                performSegue(withIdentifier: "toAddWatchingList", sender: self)
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
            destinationVC.currencyTypes = self.currencyTypes
        }
        else if segue.identifier == "toAddWatchingList"
        {
            let destinationVC = segue.destination as! CoinSelector
            destinationVC.searchCoinArray = self.searchCoinArray.sorted(by: {
                $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
            })
            destinationVC.parentController = "watchList"
        }
        
    }
   
    //shows spinner
    func showActivityIndicator()
    {
        if #available(iOS 13.0, *) {activityView = UIActivityIndicatorView(style: .medium)}
        else {activityView = UIActivityIndicatorView(style: .gray)}
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    //hides spinner
    func hideActivityIndicator(){if (activityView != nil){activityView?.stopAnimating()}}
    
    func makeAlert(titleInput:String, messageInput:String)//Error method with parameters
    {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated:true, completion: nil)
    }
    
    func setSegmentedView()
    {
        self.segmentedView.backgroundColor = UIColor(named: "Header Color")
        self.segmentedView.selectedSegmentContentColor = Util.defaultFont
        let sWidth = sSize.width
        segmentedView.frame.size.width = sWidth
        segmentedView.segmentStyle = .textOnly
        segmentedView.insertSegment(withTitle: "Alarmlar",  at: 0)
        segmentedView.insertSegment(withTitle: "İzleme Listesi", at: 1);
        segmentedView.underlineSelected = true
        segmentedView.selectedSegmentIndex = 0
        segmentedView.addTarget(self, action: #selector(self.segmentSelected(sender:)), for: .valueChanged)
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
                   case UISwipeGestureRecognizer.Direction.right:
                        if segmentedView.selectedSegmentIndex == 0
                        {
                            segmentedView.selectedSegmentIndex = 1
                        }
                   case UISwipeGestureRecognizer.Direction.left:
                         if segmentedView.selectedSegmentIndex == 1
                         {
                            segmentedView.selectedSegmentIndex = 0
                         }
                   default:break
               }
           }
    }
}

    


