//
//  CurrencyCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    var selectedCurrencyId = String()
    @IBOutlet weak var shortening: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buyButtonClicked(_ sender: Any)
    {
        
    }
    
}
