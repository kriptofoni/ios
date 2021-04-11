//
//  OperationViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit

class OperationController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
   
    @IBOutlet weak var currencyTypeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var currencyTypes = [String]()
    var currencyType  = "usd"
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
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
            cell.label.text = "Total " + currencyType.uppercased()
            cell.textField.placeholder = "Amount of currency"
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Price"
            cell.textField.placeholder = "Price"
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            cell.label.text = "Cost"
            cell.textField.placeholder = "Tap to Edit"
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationDateCell", for: indexPath) as! OperationDateCell
            cell.label.text = "Notes"
            cell.textField.placeholder = "Tap to Edit"
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addOperationButtonCell", for: indexPath) as! AddOperationButtonCell
            return cell
        default:
            print("Hata")
        }
        return cell
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
        
    }

}
