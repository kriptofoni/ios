//
//  Tools.swift
//  learning
//
//  Created by Deniz Eren Gençay on 19.04.2021.
//

import UIKit

class Tools: UIViewController, UITableViewDataSource, UITableViewDelegate{


    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(137)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToolsCell", for: indexPath) as! ToolsCell
        
        
        if indexPath.row == 0 {cell.label!.text = "Fiyat Dönüştürücü"}
        else if indexPath.row == 1
        {
            cell.label!.text = "Madencilik Hesaplayıcı (Yakında)"
        }
        else
        {
            cell.label!.text = "Blockchain Kaşif Aracı (Yakında)"
            
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            performSegue(withIdentifier: "toFiatConverter", sender: self)
            
        }else if indexPath.row == 1{
            
            print("Soon")
            // toast message Soon
            
        }else {
            
            print("Soon")
            // toast message Soon
        }
        
    
    }
    
    
}

