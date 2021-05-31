//
//  AddToWatchingListController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 20.04.2021.
//

import UIKit

class CoinSelector: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchCoinArray = [Coin]()
    var searchActiveCoinArray = [Coin]()
    var searchActive = false
    var buttons = [UIBarButtonItem]()
    var parentController = "none"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.searchBar.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchActive
        {
            return searchActiveCoinArray.count
        }
        return searchCoinArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var searchCoin = Coin()
        if searchActive
        {
            searchCoin = self.searchActiveCoinArray[indexPath.row]
        }
        else
        {
            searchCoin = self.searchCoinArray[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.label.text = searchCoin.getName()
        let url = URL(string: searchCoin.getIconViewUrl() )
        cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //When user selects coin
        if parentController == "watchList" // if parent controller is watchlist, it adds this coin to watchlist
        {
            var searchCoin = Coin()
            if searchActive
            {
                searchCoin = self.searchActiveCoinArray[indexPath.row]
            }
            else
            {
                searchCoin = self.searchCoinArray[indexPath.row]
            }
            if CoreDataWatchingList.addWatchingList(id: searchCoin.getId())
            {
                self.view.makeToast("Coin has been added successfully.", duration: 2.0, position: .center)
            }
            else
            {
                self.view.makeToast("Coin is already in your watching list.", duration: 2.0, position: .center)
            }
        }
        else if parentController == "portfolio" // if parent controller is portfolio, it adds this coin to portfolio
        {
            if searchActive
            {
                Currency.coinKey = self.searchActiveCoinArray[indexPath.row].getId()
                Currency.coinShortening = self.searchActiveCoinArray[indexPath.row].getShortening()
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                Currency.coinKey = self.searchCoinArray[indexPath.row].getId()
                Currency.coinShortening = self.searchCoinArray[indexPath.row].getShortening()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
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
            self.searchActiveCoinArray = self.searchCoinArray.filter{currencies in return currencies.getName().lowercased().contains(searchText.lowercased())}.sorted(by: {
                $0.getMarketCapRank().intValue < $1.getMarketCapRank().intValue
            })
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
