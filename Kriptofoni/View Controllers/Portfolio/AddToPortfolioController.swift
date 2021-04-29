//
//  OperationViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit

class AddToPortfolioController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
   
    @IBOutlet weak var currencyTypeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var currencyTypes = [String]()
    var selectedCoinShorthening = ""
    var searchCoinArray = [SearchCoin]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);AppUtility.lockOrientation(.portrait)
        currencyTypeButton.title = Currency.currencyKey.uppercased()
        self.tableView.delegate = self;self.tableView.dataSource = self;
        self.tableView.reloadData()
        
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CoreData.getCoins { [self] (result) in
            searchCoinArray = result
            print("Count" + String(searchCoinArray.count))
                
        } onFailure: {
            print("CORE DATA GETTING COINS ERROR")
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 7}
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 0 {height =  71}
        else if indexPath.row == 1 {height =  78}
        else if indexPath.row == 2 {height = 109}
        else if indexPath.row == 3 {height = 78}
        else if indexPath.row == 4 {height = 78}
        else if indexPath.row == 5{height = 112}
        else if indexPath.row == 6 {height = 50}
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoButtonOperationCell", for: indexPath) as! TwoButtonOperationCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Total " + Currency.coinShortening.uppercased()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.changeCoin))
            cell.label.isUserInteractionEnabled = true
            cell.label.addGestureRecognizer(tap)
            cell.textField.placeholder = "Amount of coin"
            cell.view = view
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            cell.view = view
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Price"
            cell.textField.placeholder = "Price"
            cell.view = view
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Cost"
            cell.textField.placeholder = "Tap to Edit"
            cell.view = view
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            cell.label.text = "Notes"
            cell.textField.placeholder = "Tap to Edit"
            cell.view = view
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addOperationButtonCell", for: indexPath) as! AddOperationButtonCell
            return cell
        default:
            print("Hata")
        }
        return cell
    }
    
    
    @objc func changeCoin(sender: UITapGestureRecognizer)
    {
        self.performSegue(withIdentifier: "toCoinSelector", sender: self)
    }
    
    @IBAction func currencyTypeButtonClicked(_ sender: Any)
    {
        self.performSegue(withIdentifier: "toCurrencySelectorFromOperation", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
         if segue.identifier == "toCurrencySelectorFromOperation"
         {
            let destinationVC = segue.destination as! CurrencySelectorController
            destinationVC.currencyArray = currencyTypes
         }
         else if segue.identifier == "toCoinSelector"
         {
             let destinationVC = segue.destination as! CoinSelector
             destinationVC.searchCoinArray = self.searchCoinArray.sorted(by: {
                 $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
             })
             destinationVC.parentController = "portfolio"
         }
        
    }

}
