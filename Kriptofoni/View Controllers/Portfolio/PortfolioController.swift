//
//  PortfolioController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 27.04.2021.
//

import UIKit
import Charts

class PortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource, ChartViewDelegate
{
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var deleteMode = false
    var coinsForDeleting = [String]()
    var portfolioPrincipalMoney : Double = 0
    var portfolioTotalDict  = [String:Double]()
    var portfolioList = [Coin]()
    var values = [ChartDataEntry]();
    var portfolioCalculations = [Double]() // index 0 --> total value of coins, index 1 --> total loss or profit, index 2 --> percentage of loss or profit
    var activityView: UIActivityIndicatorView?
    let now = NSDate().timeIntervalSince1970
    var chartType = "twentyFour_hours"
    
 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        fetchData()
    }
    
    ///fetches all data, should be called in viewWillAppear and when user press delete button
    func fetchData()
    {
        CoreDataPortfolio.calculateTotalCoin { (result) in
            self.portfolioTotalDict = result
            self.getCoinsForPortfolio(isUpdate: false)
        }
    }
    
    ///update method for this controller,
    func updateWithTimer()
    {
        getCoinsForPortfolio(isUpdate: true)
    }
    
    ///gets coin attributes from api
    func getCoinsForPortfolio(isUpdate: Bool) //if this is an update time, make visible this spinner
    {
        var apiString = ""
        var portfolioListTemp = [Coin]()
        for (id,_) in self.portfolioTotalDict
        {
            if apiString == "" {apiString = id}
            else { apiString = apiString + "," + id}
        }
        if apiString != ""
        {
            if !isUpdate {DispatchQueue.main.async{self.showActivityIndicator()}}
            print(apiString)
            CoinGecko.getCoins(vs_currency: "usd",ids: apiString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: [String: Int](), priceChangePercentage: "24h,7d") { (result) in //gets coins from api
                    portfolioListTemp.append(contentsOf: result)
                    portfolioListTemp = portfolioListTemp.sorted(by: {$0.getCount() < $1.getCount()})
                    self.portfolioList = portfolioListTemp
                    DispatchQueue.main.async
                    {
                        CoreDataPortfolio.calculatePrincipalMoney { (principalMoney) in
                            self.portfolioPrincipalMoney = principalMoney
                            self.portfolioCalculations = self.calculateTotalValues(portfolio: self.portfolioList, portfolioTotalDict: self.portfolioTotalDict, principalMoney: principalMoney)
                            CoinGeckoCharts.getDataPortfolioChart(ids: self.portfolioTotalDict, currency: "usd", type: self.chartType) { (newValues) in
                                self.values = newValues
                                if !isUpdate
                                {
                                    self.hideActivityIndicator(); print("Fetched")
                                }
                                else
                                {
                                    print("Updated")
                                    
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
        }
        else
        {
            self.portfolioList = [Coin]()
            self.tableView.reloadData()
        }
        
    }
    
    
    /// calculates current total value of user's coins, loss or profit and percentage of loss or profit
    func calculateTotalValues(portfolio : [Coin], portfolioTotalDict : [String:Double], principalMoney : Double) -> [Double] //return array's size will be 3
    {
        var returnArray = [Double]()
        var currentTotalMoney : Double = 0 // current total value of user's coins
        for coin in portfolio
        {
            currentTotalMoney += coin.getPrice().doubleValue * portfolioTotalDict[coin.getId()]!
        }
        let lossOrProfit = currentTotalMoney - principalMoney // loss or profit
        let percentage = (currentTotalMoney - principalMoney) / 100 * principalMoney
        returnArray.append(currentTotalMoney); returnArray.append(lossOrProfit); returnArray.append(percentage)
        return returnArray
    }
    
    
    // MARK: - Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if portfolioList.isEmpty {
            return 1
        }
        return self.portfolioList.count + 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // portfolioFirst // secondCell // portfolioThird // watchingListCell
        if portfolioList.isEmpty
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptyWatchlistCell
            cell.label.text = "Your portfolio is empty"
            cell.button.setTitle("Add Operation Manually", for: .normal)
            cell.button.addTarget(self, action: #selector(self.openOperationPage(sender:)), for: .touchUpInside)
            return cell
        }
        else
        {
            if indexPath.row > 2
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCoinCell", for: indexPath) as! PortfolioCoinCell
                let listIndex = self.portfolioList[indexPath.row-3]
                let price = listIndex.getPrice().doubleValue
                let quantity = portfolioTotalDict[listIndex.getId()]!
                cell.name.text! = listIndex.getShortening().uppercased() + " " + String(quantity)
                if deleteMode //delete box
                {
                    cell.iconView.image = nil
                }
                else
                {
                    let url = URL(string: listIndex.getIconViewUrl())
                    cell.iconView.sd_setImage(with: url) { (_, _, _, _) in}
                }
                cell.coinPrice.text = Util.toPrice(price, isCoinDetailPrice: false)
                cell.totalPrice.text = "$" + Util.toPrice(price * quantity , isCoinDetailPrice: false)
                let percent = listIndex.getPercent().doubleValue
                let change = listIndex.getChange().doubleValue
                cell.change.text = "$" + " " + Util.toPrice(change * quantity, isCoinDetailPrice: false)
                cell.percent.text = String(format: "%.2f", percent)
                Util.changeLabelColor(data: change, label: cell.change)
                Util.changeLabelColor(data: change, label: cell.percent)
                return cell
            }
            else
            {
                if indexPath.row == 0
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioFirst", for: indexPath) as! PortfolioFirstCell
                    cell.label1.text = "Portföyüm"
                    cell.label2.text =  "$" + " " + Util.toPrice(self.portfolioCalculations[0], isCoinDetailPrice: true)
                    let totalChange = self.portfolioCalculations[1]
                    let totalChangePercent = self.portfolioCalculations[2]
                    cell.label3.text = "\("$") \(Util.toPrice(totalChange, isCoinDetailPrice: true)) (%\(String(totalChangePercent)))"
                    Util.changeLabelColor(data: totalChange, label: cell.label3)
                    return cell
                    
                }
                else if indexPath.row == 1 //chartCell
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "secondCell", for: indexPath) as! PortfolioChartCell
                    for (index,item) in cell.buttons.enumerated() {item.addTarget(self, action: #selector(self.chartTimerClicked(sender:)), for: .touchUpInside); item.tag = index}
                    cell.chartView.delegate = self
                    ChartUtil.setLineChartSettings(chartView: cell.chartView, xAxisLabelCount: cell.xAxisLabelCount, values: values, dict: [:], chartType: chartType)
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioThird", for: indexPath) as! PortfolioThirdCell
                    cell.label1.text = "Ana Para: \("$")\(Util.toPrice(self.portfolioPrincipalMoney, isCoinDetailPrice: false))"// You should change there according to currency type...
                    cell.label2.text = "Kripto Para/Miktar"
                    cell.label3.text = "24s Kâr/Zarar"
                    cell.label4.text = "Güncel Fiyat"
                    return cell
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if portfolioList.isEmpty {height = 288}
        else
        {
            if indexPath.row > 2 {height = 56}
            else
            {
                if indexPath.row == 0 {height = 108}
                else if indexPath.row == 1 {height = 235}
                else if indexPath.row == 2 {height = 81}
            }
        }
        return CGFloat(height)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if !self.portfolioList.isEmpty && indexPath.row > 2
            {
                let cell = tableView.cellForRow(at: indexPath) as! PortfolioCoinCell
                if deleteMode //if delete mode is closed
                {
                    tableView.deselectRow(at: indexPath, animated: true)
                    cell.isChecked = !cell.isChecked
                    if cell.isChecked
                    {
                        self.coinsForDeleting.append(self.portfolioList[indexPath.row-3].getId())
                        dump(self.coinsForDeleting)
                        cell.iconView.image = UIImage(named: "arrow")
                    }
                    else
                    {
                        self.coinsForDeleting.removeAll{$0 == self.portfolioList[indexPath.row-3].getId()}
                        dump(self.coinsForDeleting)
                        cell.iconView.image = nil
                    }
                }
               
            }
    }
    
    
    // MARK: - Button Clicks
    @objc func chartTimerClicked(sender: UIButton)
    {
        switch sender.tag
        {
            case 0: chartType = "twentyFour_hours"// 24 hour
            case 1: chartType = "one_week_before"// 1 week
            case 2: chartType = "one_month_before"// 1 month
            case 3: chartType = "three_months_before"// 3 month
            case 4: chartType = "one_year_before"// 1 year
            case 5: chartType = "all"// All
            default:
                print("error")
        }
        DispatchQueue.main.async{self.showActivityIndicator()}
        CoinGeckoCharts.getDataPortfolioChart(ids: portfolioTotalDict, currency: "usd", type: chartType) { (entries) in
            self.values = entries
            DispatchQueue.main.async{self.hideActivityIndicator()}
            self.tableView.reloadData()
        }
    }
    
    //except delete condition, it sends user to add to portfolio page
    @IBAction func addButtonClicked(_ sender: Any)
    {
        if !deleteMode {self.performSegue(withIdentifier: "toOperationPortfolio", sender: self)}
        else
        {
            if !self.coinsForDeleting.isEmpty
            {
                CoreDataPortfolio.deleteCoinFromPortfolio(ids: self.coinsForDeleting) { (check) in
                    if check {
                        self.deleteMode = false
                        self.fetchData()
                        self.tableView.allowsMultipleSelection = false
                        self.tableView.allowsMultipleSelectionDuringEditing = false
                        self.editButton.tintColor = Util.hexStringToUIColor(hex: "797676")
                        self.addButton.title = "Add"
                    }
                    
                }
            }
            else
            {
                self.makeAlert(titleInput: "Oops!", messageInput: "Please select a coin to delete from portfolio.")
            }
            
        }
    }
    
    @IBAction func currencyButtonClicked(_ sender: Any) {self.performSegue(withIdentifier: "toCurrencySelector", sender: self)}
    
    @IBAction func editButtonClicked(_ sender: Any)
    {
        if !deleteMode
        {
            deleteMode = true
            self.tableView.allowsMultipleSelection = true
            self.tableView.allowsMultipleSelectionDuringEditing = true
            self.editButton.tintColor = UIColor.systemBlue
            self.addButton.title = "Delete"
        }
        else
        {
            deleteMode = false
            self.tableView.allowsMultipleSelection = false
            self.tableView.allowsMultipleSelectionDuringEditing = false
            self.editButton.tintColor = Util.hexStringToUIColor(hex: "797676")
            self.addButton.title = "Add"
        }
        self.tableView.reloadData()
    }
    
    @objc func openOperationPage(sender: Any) {self.performSegue(withIdentifier: "toOperationPortfolio", sender: self)}
    
    //shows spinner
    func showActivityIndicator()
    {
        hideActivityIndicator()
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
}
