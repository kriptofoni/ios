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
    @IBOutlet weak var twentyFourHour: UIButton!
    @IBOutlet weak var sevenDay: UIButton!
    @IBOutlet weak var oneMonth: UIButton!
    @IBOutlet weak var threeMonth: UIButton!
    @IBOutlet weak var oneYear: UIButton!
    @IBOutlet weak var all: UIButton!
    var xAxisLabelCount = 12 // indicated the label count of x axis
    var buttons = [UIButton]()
    var backgroundColorOfButton : UIColor  = UIColor()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.selectionStyle = .none
        buttons = [twentyFourHour, sevenDay, oneMonth, threeMonth, oneYear, all]
        twentyFourHour.setTitle("24S", for: .normal)
        sevenDay.setTitle("7G", for: .normal)
        oneMonth.setTitle("1A", for: .normal)
        threeMonth.setTitle("3A", for: .normal)
        oneYear.setTitle("1Y", for: .normal)
        all.setTitle("TÜM", for: .normal)
        backgroundColorOfButton = UIColor(named: "Body Color")!; chartView.backgroundColor = UIColor(named: "Body Color")!;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func twentyFourHourClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: twentyFourHour, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func sevenDayClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: sevenDay, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func oneMonthClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: oneMonth, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func threeMonthClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: threeMonth, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func oneYearClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: oneYear, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
    @IBAction func allClicked(_ sender: Any) {Util.setButtonColorsBackGround(except: all, buttons: buttons, normalBackground: backgroundColorOfButton); xAxisLabelCount = 12}
}
