//
//  CurrencySelectorViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 3.04.2021.
//

import UIKit

class CurrencySelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome")
        tableView.delegate = self; tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        cell.label.text = "CEM"
        print("Cem")
        return cell
    }
    
    
}
