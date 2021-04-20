//
//  AddToWatchingListController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 20.04.2021.
//

import UIKit

class AddToWatchingListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchCoinArray = [SearchCoin]()
    var searchActiveCoinArray = [SearchCoin]()
    var searchActive = false
    var buttons = [UIBarButtonItem]()
    
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
        if searchActive{
            return searchActiveCoinArray.count
        }
        return searchCoinArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var searchCoin = SearchCoin()
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
        let url = URL(string: searchCoin.getImageUrl() )
        cell.icon.sd_setImage(with: url) { (_, _, _, _) in}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var searchCoin = SearchCoin()
        if searchActive
        {
            searchCoin = self.searchActiveCoinArray[indexPath.row]
        }
        else
        {
            searchCoin = self.searchCoinArray[indexPath.row]
        }
        if CoreData.addWatchingList(id: searchCoin.getId())
        {
            self.view.makeToast("Coin has been added successfully.", duration: 2.0, position: .center)
        }
        else
        {
            self.view.makeToast("Coin is already in your watching list.", duration: 2.0, position: .center)
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
