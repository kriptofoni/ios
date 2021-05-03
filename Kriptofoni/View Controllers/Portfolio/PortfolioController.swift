//
//  PortfolioController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 27.04.2021.
//

import UIKit

class PortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var currencyButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var deleteMode = false
    var coinsForDeleting = [String]()
    var portfolioPrincipalMoney : Double = 0
    var portfolioTotalDict  = [String:Double]()
    var portfolioList = [Coin]()
    var portfolioCalculations = [Double]() // index 0 --> total value of coins, index 1 --> total loss or profit, index 2 --> percentage of loss or profit
    var activityView: UIActivityIndicatorView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        self.currencyButton.title = Currency.currencyKey.uppercased()
        update()
    }
    
    ///update method for this controller, fetches all data, should be called in viewWillAppear and when user press delete button
    func update()
    {
        CoreDataPortfolio.calculateTotalCoin { (result) in
            self.portfolioTotalDict = result
            self.getCoinsForPortfolio()
        }
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
                cell.totalPrice.text = Currency.currencySymbol + Util.toPrice(price * quantity , isCoinDetailPrice: false)
                let percent = listIndex.getPercent()
                let change = listIndex.getChange()
                cell.change.text = Currency.currencySymbol + " " + Util.toPrice(change.doubleValue * quantity, isCoinDetailPrice: false)
                cell.percent.text = String(format: "%.2f", percent.doubleValue)
                if change.doubleValue > 0
                {
                    cell.change.textColor = UIColor.green
                    cell.percent.textColor = UIColor.green
                }
                else if change.doubleValue < 0
                {
                    cell.change.textColor = UIColor.red
                    cell.percent.textColor = UIColor.red
                }
                else
                {
                    cell.change.textColor = UIColor.black
                    cell.percent.textColor = UIColor.black
                }
                return cell
            }
            else
            {
                if indexPath.row == 0
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioFirst", for: indexPath) as! PortfolioFirstCell
                    cell.label1.text = "My Portfolio"
                    cell.label2.text =  Currency.currencySymbol + " " + Util.toPrice(self.portfolioCalculations[0], isCoinDetailPrice: true)
                    let totalChange = self.portfolioCalculations[1]
                    let totalChangePercent = self.portfolioCalculations[2]
                    cell.label3.text = "\(Currency.currencySymbol) \(Util.toPrice(totalChange, isCoinDetailPrice: true)) (%\(String(totalChangePercent)))"
                    if totalChange > 0
                    {
                        cell.label3.textColor = UIColor.green
                    }
                    else if totalChange < 0
                    {
                        cell.label3.textColor = UIColor.red
                    }
                    else
                    {
                        cell.label3.textColor = UIColor.black
                    }
                    return cell
                    
                }
                else if indexPath.row == 1 //chartCell
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "secondCell", for: indexPath) as! SecondCell
                    return cell
                }
                else
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioThird", for: indexPath) as! PortfolioThirdCell
                    cell.label1.text = "Total Principal Money: \(Currency.currencySymbol)\(Util.toPrice(self.portfolioPrincipalMoney, isCoinDetailPrice: false))"// You should change there according to currency type...
                    cell.label2.text = "Coin/Quantity"
                    cell.label3.text = "24h Profit/Loss"
                    cell.label4.text = "Price"
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
    
    //except delete condition, it sends user to add to portfolio page
    @IBAction func addButtonClicked(_ sender: Any)
    {
        if !deleteMode
        {
            self.performSegue(withIdentifier: "toOperationPortfolio", sender: self)
        }
        else
        {
            if !self.coinsForDeleting.isEmpty
            {
                CoreDataPortfolio.deleteCoinFromPortfolio(ids: self.coinsForDeleting) { (check) in
                    if check {
                        self.deleteMode = false
                        self.update()
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
    
    ///gets coin attributes from api
    func getCoinsForPortfolio()
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
            DispatchQueue.main.async{self.showActivityIndicator()}
            CoinGecko.getCoins(vs_currency: Currency.currencyKey,ids: apiString, order: "market_cap_desc", per_page: 50, page: 1 , sparkline: false, hashMap: [String: Int](), priceChangePercentage: "24h,7d") { (result) in //gets coins from api
                    portfolioListTemp.append(contentsOf: result)
                    portfolioListTemp = portfolioListTemp.sorted(by: {$0.getCount() < $1.getCount()})
                    self.portfolioList = portfolioListTemp
                    DispatchQueue.main.async
                    {
                        CoreDataPortfolio.calculatePrincipalMoney { (principalMoney) in
                            self.portfolioPrincipalMoney = principalMoney
                            self.portfolioCalculations = self.calculateTotalValues(portfolio: self.portfolioList, portfolioTotalDict: self.portfolioTotalDict, principalMoney: principalMoney)
                            self.hideActivityIndicator()
                            self.tableView.reloadData()
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
}
