//
//  FirstCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 5.04.2021.
//

import UIKit
import Charts


// I implemented all table view cells that are used in selectedCoin's table view.
class FirstCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rigthLabel: UILabel!
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

class SecondCell: UITableViewCell {

    
    @IBOutlet weak var chartView: LineChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class ThirdCell: UITableViewCell {

    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var button24H: UIButton!
    @IBOutlet weak var button1W: UIButton!
    @IBOutlet weak var button1M: UIButton!
    @IBOutlet weak var button3M: UIButton!
    @IBOutlet weak var button6M: UIButton!
    @IBOutlet weak var button1Y: UIButton!
    @IBOutlet weak var buttonAll: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func firstButtonClicked(_ sender: Any) {
    }
    @IBAction func secondButtonClicked(_ sender: Any) {
    }
    @IBAction func button24HClicked(_ sender: Any) {
    }
    @IBAction func button1WClicked(_ sender: Any) {
    }
    @IBAction func button1MClicked(_ sender: Any) {
    }
    @IBAction func button3MClicked(_ sender: Any) {
    }
    @IBAction func button6MClicked(_ sender: Any) {
    }
    @IBAction func button1YClicked(_ sender: Any) {
    }
    @IBAction func buttonAllClicked(_ sender: Any) {
        print("cem")
    }
    
}

class TwoButtonCell: UITableViewCell {

    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var addOperation: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
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


class OneButtonCell: UITableViewCell {

    @IBOutlet weak var buyButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buyButtonClicked(_ sender: Any) {
    }
}

class OneToOneCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SocialMediaCell: UITableViewCell {

    @IBOutlet weak var socialMediaIcon: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class OneToTwoCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabelUp: UILabel!
    @IBOutlet weak var rightLabelDown: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

