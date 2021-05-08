//
//  ToolsCell.swift
//  learning
//
//  Created by Deniz Eren Gençay on 19.04.2021.
//

import UIKit

class ToolsCell: UITableViewCell {

    
    @IBOutlet weak var toolsImageView: UIImageView!
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
