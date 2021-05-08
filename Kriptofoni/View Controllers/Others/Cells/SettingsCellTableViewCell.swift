//
//  SettingsCellTableViewCell.swift
//  learning
//
//  Created by Deniz Eren Gençay on 15.04.2021.
//

import UIKit

class SettingsCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
