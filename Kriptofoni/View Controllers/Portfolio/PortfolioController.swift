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
    var portfolioArray = [PortfolioCoin]()
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if portfolioArray.isEmpty {
            return 1
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // portfolioFirst // secondCell // portfolioThird // watchingListCell
        if portfolioArray.isEmpty
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
                return cell
            }
            else
            {
                if indexPath.row == 0
                {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioFirst", for: indexPath) as! PortfolioFirstCell
                    cell.label1.text = "My Portfolio"
                    cell.label2.text = "Total Value of My Coins"
                    cell.label3.text = "Change of My Coins"
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
                    cell.label1.text = "Total Principal Money: 24353252"
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
        if portfolioArray.isEmpty
        {
            height = 288
        }
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
    
    @IBAction func addButtonClicked(_ sender: Any)
    {
        
    }
    
    @IBAction func currencyButtonClicked(_ sender: Any) {self.performSegue(withIdentifier: "toCurrencySelector", sender: self)}
    
    @IBAction func editButtonClicked(_ sender: Any)
    {
        if !portfolioArray.isEmpty
        {
            
        }
    }
    
    @objc func openOperationPage(sender: Any) {self.performSegue(withIdentifier: "toOperationPortfolio", sender: self)}
    
    
}
