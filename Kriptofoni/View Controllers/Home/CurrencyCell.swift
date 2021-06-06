//
//  CurrencyCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import UIKit

class CurrencyCell: UITableViewCell
{
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    var selectedCurrencyId = String()
    @IBOutlet weak var shortening: UILabel!
    var selectButton = UIButton()
    
    override func awakeFromNib() {super.awakeFromNib()}

    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
    
    @IBAction func buyButtonClicked(_ sender: Any)
    {
        
    }
    
}
