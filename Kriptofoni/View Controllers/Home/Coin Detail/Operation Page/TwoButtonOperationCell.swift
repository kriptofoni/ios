//
//  TwoButtonOperationCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit

class TwoButtonOperationCell: UITableViewCell {

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
        buyButton.borderColor = UIColor.green
        buyButton.setTitleColor(UIColor.green, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func buyButtonAction(_ sender: Any)
    {
        buyButton.borderColor = UIColor.green
        buyButton.setTitleColor(UIColor.green, for: .normal)
        sellButton.borderColor = UIColor.gray
        sellButton.setTitleColor(UIColor.gray, for: .normal)
    }
    
    @IBAction func sellButtonAction(_ sender: Any)
    {
        buyButton.borderColor = UIColor.gray
        buyButton.setTitleColor(UIColor.gray, for: .normal)
        sellButton.borderColor = UIColor.red
        sellButton.setTitleColor(UIColor.red, for: .normal)
    }
    
}


class OperationInputCell: UITableViewCell
{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class OperationDateCell: UITableViewCell
{

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class AddOperationButtonCell: UITableViewCell
{
    @IBOutlet weak var addOperationButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addOperationButtonClicked(_ sender: Any) {
    }
}


