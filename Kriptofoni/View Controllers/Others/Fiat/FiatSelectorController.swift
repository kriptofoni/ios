//
//  FiatSelectorController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 7.05.2021.
//

import UIKit

class FiatSelectorController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var currencyArray = [String]()
    var coinArray = [Coin]()
    var searchActiveCoinArray = [Coin]()
    var searchActiveCurrency = [String]()
    var pageType = ""
    var searchActive = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.searchBar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if pageType == "coin"
        {
            CoreData.getCoins { (coins) in
                self.coinArray = coins.sorted(by: {$0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue})
                
            }
        }
        else
        {
            CoreData.getSupportedCurrencies { (currencies) in
                var array = currencies
                array.remove(at: 0)
                self.currencyArray = array
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchActive
        {
            return searchActiveCoinArray.count
        }
        else
        {
            if pageType == "coin"
            {
                return coinArray.count
            }
            else
            {
                return currencyArray.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if searchActive
        {
            if pageType == "coin"
            {
                FiatConverter.selectedCoinId = searchActiveCoinArray[indexPath.row].getId()
                FiatConverter.selectedCoinName = searchActiveCoinArray[indexPath.row].getName()
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                FiatConverter.selectedCurrency = searchActiveCurrency[indexPath.row]
                self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            if pageType == "coin"
            {
                FiatConverter.selectedCoinId = coinArray[indexPath.row].getId()
                FiatConverter.selectedCoinName = coinArray[indexPath.row].getName()
                self.navigationController?.popViewController(animated: true)
                
            }
            else
            {
                FiatConverter.selectedCurrency = currencyArray[indexPath.row]
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        if searchActive
        {
            if pageType == "coin"
            {
                cell.label.text = searchActiveCoinArray[indexPath.row].getName()
                let url = URL(string: searchActiveCoinArray[indexPath.row].getIconViewUrl() )
                cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            }
            else
            {
                cell.label.text = searchActiveCurrency[indexPath.row]
            }
        }
        else
        {
            if pageType == "coin"
            {
                cell.label.text = coinArray[indexPath.row].getName()
                let url = URL(string: coinArray[indexPath.row].getIconViewUrl() )
                cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
            }
            else
            {
                cell.label.text = currencyArray[indexPath.row]
            }
        }
        return cell
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
            if pageType == "coin"
            {
                self.searchActiveCoinArray = self.coinArray.filter{currencies in return currencies.getName().lowercased().contains(searchText.lowercased())}.sorted(by: {
                    $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
                })
            }
            else
            {
                self.searchActiveCurrency = self.currencyArray.filter{currencies in return currencies.lowercased().contains(searchText.lowercased())}
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func searchButtonClicked(_ sender: Any)
    {
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItems?.removeAll()
        navigationItem.rightBarButtonItems?.removeAll()
    }
    
}
