//
//  PortfolioChartCell.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 4.05.2021.
//

import UIKit
import Charts

class PortfolioChartCell: UITableViewCell {

    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var oneHour: UIButton!
    @IBOutlet weak var twentyFourHour: UIButton!
    @IBOutlet weak var sevenDay: UIButton!
    @IBOutlet weak var oneMonth: UIButton!
    @IBOutlet weak var threeMonth: UIButton!
    @IBOutlet weak var oneYear: UIButton!
    @IBOutlet weak var all: UIButton!
    var xAxisLabelCount = 12 // indicated the label count of x axis
    var buttons = [UIButton]()
    var backgroundColorOfButton : UIColor  = UIColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        buttons = [oneHour, twentyFourHour, sevenDay, oneMonth, threeMonth, oneYear, all]
        switch traitCollection.userInterfaceStyle
        {
            case .light, .unspecified: backgroundColorOfButton = .white; chartView.backgroundColor = .white;
            case .dark: backgroundColorOfButton = .black; chartView.backgroundColor = .black;
            @unknown default: backgroundColorOfButton = .white; chartView.backgroundColor = .white;
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func oneHourClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: oneHour, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func twentyFourHourClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: twentyFourHour, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func sevenDayClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: sevenDay, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func oneMonthClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: oneMonth, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func threeMonthClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: threeMonth, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func oneYearClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: oneYear, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func allClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: all, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
}
