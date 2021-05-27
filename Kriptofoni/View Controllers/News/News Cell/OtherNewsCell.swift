//
//  OtherNewsCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 25.05.2021.
//

import UIKit

class OtherNewsCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var time: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
