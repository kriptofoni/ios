//
//  PortfolioCurrencyCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 29.04.2021.
//

import UIKit

class PortfolioCoinCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var coinPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
