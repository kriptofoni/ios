//
//  SearchCurrencyCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 30.03.2021.
//

import UIKit

// We use also this table view cell in CurrencySelector.
class SearchCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}

}
