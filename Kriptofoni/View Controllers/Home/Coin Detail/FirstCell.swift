//
//  FirstCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 5.04.2021.
//

import UIKit
import Charts


// I implemented all table view cells that are used in Coin Details Controller.
class FirstCell: UITableViewCell
{
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rigthLabel: UILabel!
    override func awakeFromNib() {super.awakeFromNib();self.selectionStyle = .none}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
}

class SecondCell: UITableViewCell
{
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var button24H: UIButton!
    @IBOutlet weak var button1W: UIButton!
    @IBOutlet weak var button1M: UIButton!
    @IBOutlet weak var button3M: UIButton!
    @IBOutlet weak var button6M: UIButton!
    @IBOutlet weak var button1Y: UIButton!
    @IBOutlet weak var buttonAll: UIButton!
    var xAxisLabelCount = 12 // indicated the label count of x axis
    var buttons = [UIButton]()
    var backgroundColorOfButton : UIColor  = UIColor()
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
        buttons = [button24H, button1W, button1M, button3M, button6M, button1Y, buttonAll]
        switch traitCollection.userInterfaceStyle
        {
            case .light, .unspecified: backgroundColorOfButton = .white; chartView.backgroundColor = .white; candleStickChartView.backgroundColor = .white
            case .dark: backgroundColorOfButton = .black; chartView.backgroundColor = .black; candleStickChartView.backgroundColor = .black
            @unknown default: backgroundColorOfButton = .white; chartView.backgroundColor = .white; candleStickChartView.backgroundColor = .white
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
    @IBAction func firstButtonClicked(_ sender: Any){}
    @IBAction func secondButtonClicked(_ sender: Any){}
    @IBAction func button24HClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: button24H, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func button1WClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: button1W, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 7 }
    @IBAction func button1MClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: button1M, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 4}
    @IBAction func button3MClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: button3M, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 3}
    @IBAction func button6MClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: button6M, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 6}
    @IBAction func button1YClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: button1Y, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func buttonAllClicked(_ sender: Any)  {Util.setButtonColorsBackGround(except: buttonAll, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount  = 12}
    
}

class TwoButtonCell: UITableViewCell
{

    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var addOperation: UIButton!
    override func awakeFromNib() {super.awakeFromNib(); self.selectionStyle = .none}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
    @IBAction func favoritesButtonClicked(_ sender: Any) {}
    @IBAction func addOperationButtonClicked(_ sender: Any) {}
}

class OneButtonCell: UITableViewCell
{
    @IBOutlet weak var buyButton: UIButton!
    override func awakeFromNib() {super.awakeFromNib(); self.selectionStyle = .none}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
    @IBAction func buyButtonClicked(_ sender: Any) {}
}

class OneToOneCell: UITableViewCell
{
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {super.awakeFromNib();self.selectionStyle = .none}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
}

class SocialMediaCell: UITableViewCell
{
    @IBOutlet weak var socialMediaIcon: UIImageView!
    @IBOutlet weak var label: UILabel!
    var link : String = String()
    override func awakeFromNib() {super.awakeFromNib()}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
}

class OneToTwoCell: UITableViewCell
{
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabelUp: UILabel!
    @IBOutlet weak var rightLabelDown: UILabel!
    override func awakeFromNib() {super.awakeFromNib(); self.selectionStyle = .none}
    override func setSelected(_ selected: Bool, animated: Bool) {super.setSelected(selected, animated: animated)}
}

