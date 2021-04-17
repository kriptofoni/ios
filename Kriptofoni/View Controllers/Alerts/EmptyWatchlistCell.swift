//
//  EmptyWatchlistCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 17.04.2021.
//

import UIKit

class EmptyWatchlistCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonClicked(_ sender: Any) {
    }
    
}
