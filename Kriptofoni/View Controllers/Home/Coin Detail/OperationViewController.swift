//
//  OperationViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit

class OperationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self; tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        var height = 0
        if indexPath.row == 0 {height =  50}
        else if indexPath.row == 1 {height =  50}
        else if indexPath.row == 2 {height = 90}
        else if indexPath.row == 3 {height = 50}
        else if indexPath.row == 4 {height = 50}
        else if indexPath.row == 5{height = 90}
        else if indexPath.row == 6 {height = 120}
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
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationCell", for: indexPath) as! OperationCell
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationInputCell", for: indexPath) as! OperationInputCell
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "operationCell", for: indexPath) as! OperationCell
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addOperationButtonCell", for: indexPath) as! AddOperationButtonCell
            return cell
        default:
            print("Hata")
        }
        return cell
    }
    
    

}
