//
//  FourthCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 5.04.2021.
//

import UIKit

class TwoButtonCell: UITableViewCell {

    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var addOperation: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func favoritesButtonClicked(_ sender: Any) {
    }
    
    @IBAction func addOperationButtonClicked(_ sender: Any) {
    }
}
