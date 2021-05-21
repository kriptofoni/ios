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
        self.tableView.backgroundColor = UIColor(named: "Body Color")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCellTableViewCell
        if indexPath.row == 0 {
            
            cell.settingsLabel!.text = "Bizi Takibe Alın"
            cell.settingsImageView.image = UIImage(named: "followUs")
            
        }else if indexPath.row == 1{
            cell.settingsLabel!.text = "Kripto Para Araçları"
            cell.settingsImageView.image = UIImage(named: "tools")
            
        }else if indexPath.row == 2{
            
            cell.settingsLabel!.text = "Reklam ve İşbirliği"
            cell.settingsImageView.image = UIImage(named: "agreement")
            
        }else if indexPath.row == 3 {
            
            cell.settingsLabel!.text = "Yardım"
            cell.settingsImageView.image = UIImage(named: "help")
            
        }else if indexPath.row == 4{
            
            cell.settingsLabel!.text = "Hakkımızda"
            cell.settingsImageView.image = UIImage(named: "aboutUs")
        }else{
            cell.settingsLabel!.text = "Kullanım Sözleşmesi"
            cell.settingsImageView.image = UIImage(named: "agreement")
            
            
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {return 6}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if indexPath.row == 1 {
            
            performSegue(withIdentifier: "toTools", sender: self)
            
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
            performSegue(withIdentifier: "toContractAndAbout", sender: self)
           
            
        }
    
    }
    
}

