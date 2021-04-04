//
//  CurrencySelectorViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit

class CurrencySelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    var selectedCurrency = String()
    var currencyArray =  [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        currencyArray.remove(at: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{return currencyArray.count}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.label.text = currencyArray[indexPath.row].uppercased()
        print("cem")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.selectedCurrency = currencyArray[indexPath.row]
        performSegue(withIdentifier: "toBackFromSelector", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let nav = segue.destination as? UINavigationController, segue.identifier == "toBackFromSelector"
        {
            if let vc = nav.visibleViewController as? MainViewController
            {
                vc.currentCurrencyKey =  self.selectedCurrency
            }
        }
    }
    
}
