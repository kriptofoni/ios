//
//  ViewController.swift
//  learning
//
//  Created by Deniz Eren Gençay on 13.04.2021.
//

import UIKit

class MoreController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCellTableViewCell
        
        if indexPath.row == 0 {
            
            cell.settingsLabel!.text = "Join Community"
            
        }else if indexPath.row == 1{
            
            cell.settingsLabel!.text = "Usage agreement"
            
        }else if indexPath.row == 2{
            
            cell.settingsLabel!.text = "Add and Cooperation"
            
        }else if indexPath.row == 3 {
            
            cell.settingsLabel!.text = "Help"
            
        }else if indexPath.row == 4{
            
            cell.settingsLabel!.text = "About"
            
        }else{
            
            cell.settingsLabel!.text = "Tools"
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 6}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if indexPath.row == 1 {
            
            performSegue(withIdentifier: "toContractAndAbout", sender: self)
            
        }else if indexPath.row == 4 {
            
            performSegue(withIdentifier: "toContractAndAbout", sender: self)
            
        }else if indexPath.row == 2{
            
            performSegue(withIdentifier: "toCooperationAndHelp", sender: self)
            
        }else if indexPath.row == 3 {
            
            performSegue(withIdentifier: "toCooperationAndHelp", sender: self)
            
        }else if indexPath.row == 0 {
            
            let newLink = "https://twitter.com//(twitterLink)"
            guard let url = URL(string: newLink) else  { return }
            UIApplication.shared.open(url)
            
        }else{
            
            performSegue(withIdentifier: "toTools", sender: self)
            
        }
    
    }
    
}

