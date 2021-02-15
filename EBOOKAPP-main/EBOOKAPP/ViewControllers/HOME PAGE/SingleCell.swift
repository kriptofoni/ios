//
//  SingleCell.swift
//  EBOOKAPP
//
//  Created by Cem Sertkaya on 13.02.2021.
//

import UIKit
import Firebase

class SingleCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    var buttonType = Int() // 0 --> HOME 1 -- LOG OUT
    weak var yourController : FirstController?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        makeWhiteBorder(button: button)
        // Configure the view for the selected state
    }
    @IBAction func buttonClicked(_ sender: Any)
    {
        if buttonType == 0
        {
            
        }
        else if buttonType == 1
        {
            do
            {
               try Auth.auth().signOut()
               CoreDataUtil.removeUserFromCoreData()
               yourController!.performSegue(withIdentifier: "toZero", sender: yourController!)
            }
            catch
            {
                print("error")
            }
        }
        else
        {
            print("Button Type Error")
        }
    }
    
    func makeWhiteBorder(button: UIButton)
    {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
    }
}
