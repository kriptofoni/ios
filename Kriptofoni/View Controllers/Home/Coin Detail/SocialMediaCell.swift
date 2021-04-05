//
//  SocialMediaCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 5.04.2021.
//

import UIKit

class SocialMediaCell: UITableViewCell {

    @IBOutlet weak var socialMediaIcon: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
