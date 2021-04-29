//
//  WatchingListCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 18.04.2021.
//

import UIKit

class WatchingListCell: UITableViewCell {

    @IBOutlet weak var symbolView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var isChecked = false
    
    override func awakeFromNib() {super.awakeFromNib()}

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        
        
    }
    

    @IBAction func checkButtonClicked(_ sender: Any)
    {
        
    }
}
