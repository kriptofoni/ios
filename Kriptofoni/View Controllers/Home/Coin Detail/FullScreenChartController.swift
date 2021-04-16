//
//  DetailedChartViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 9.04.2021.
//

import UIKit
import Charts

class FullScreenChartController: UIViewController, ChartViewDelegate
{
    @IBOutlet weak var chartView: LineChartView!;@IBOutlet weak var candleView: CandleStickChartView!
    @IBOutlet weak var changeChartTypeButton: UIButton!;@IBOutlet weak var twentyFour: UIButton!
    @IBOutlet weak var oneweek: UIButton!;@IBOutlet weak var oneMonth: UIButton!
    @IBOutlet weak var threeMonth: UIButton!;@IBOutlet weak var sixMonth: UIButton!
    @IBOutlet weak var oneYear: UIButton!;@IBOutlet weak var all: UIButton!
    var activityView: UIActivityIndicatorView?
    var values = [ChartDataEntry]()
    var coinId : String = "";
    var charType = true; //true for line chart, false for candle
    let coingecko = CoinGecko.init()
    var buttons = [UIButton]()
    var dict = [String:Any]()
    var xAxisLabelCount = 12
    var chartType = "twentyFour_hours" // sets the time line
        
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buttons = [self.twentyFour, self.oneweek, self.oneMonth, self.threeMonth, self.sixMonth, self.oneYear, self.all]
        if !charType {changeChartTypeButton.setBackgroundImage(UIImage(named: "linechart"), for: .normal)}
        else {changeChartTypeButton.setBackgroundImage(UIImage(named: "candlestick"), for: .normal)}
        twentyFour.setTitleColor(Util.hexStringToUIColor(hex: "F2A900"), for: .normal) // OUR YELLOW
        switch traitCollection.userInterfaceStyle
        {
            case .light, .unspecified: chartView.backgroundColor = .white; candleView.backgroundColor = .white
            case .dark: chartView.backgroundColor = .black; candleView.backgroundColor = .white
            @unknown default: chartView.backgroundColor = .white;candleView.backgroundColor = .white
        }
        chartView.delegate = self;candleView.delegate = self
        updateChart()
        
    }
    
    func updateChart()
    {
        if charType
        {
            candleView.isHidden = true; chartView.isHidden = false
            ChartUtil.setLineChartSettings(chartView: chartView, xAxisLabelCount: xAxisLabelCount, values: values, dict: dict, chartType: chartType)

        }
        else
        {
            candleView.isHidden = false; chartView.isHidden = true
        }
    }
    
    @IBAction func changeChartTypeButtonClicked(_ sender: Any)
    {
        if charType // if lineChart is opened
        {
            charType = false; updateChart() //makes candle chart visible
            changeChartTypeButton.setBackgroundImage(UIImage(named: "candlestick"), for: .normal)
        }
        else
        {
            charType = true ; updateChart() //makes line chart visible
            changeChartTypeButton.setBackgroundImage(UIImage(named: "linechart"), for: .normal)
        }
        print("pressed")
    }
    
    @IBAction func twentyFourButtonClicked(_ sender: Any) {chartType = "twentyFour_hours"; Util.setButtonColors(except: twentyFour, buttons: buttons, background: false); getChartData(type: chartType); xAxisLabelCount = 12}
    
    @IBAction func oneWeekButtonClicked(_ sender: Any) {chartType = "one_week_before"; Util.setButtonColors(except: oneweek, buttons: buttons,background: false);getChartData(type: chartType); xAxisLabelCount =  7}
    
    @IBAction func oneMonthButtonClicked(_ sender: Any) {chartType = "one_month_before"; Util.setButtonColors(except: oneMonth, buttons: buttons,background: false); getChartData(type: chartType); xAxisLabelCount = 4}
    
    @IBAction func threeMonthButtonClicked(_ sender: Any) {chartType = "three_months_before";Util.setButtonColors(except: threeMonth, buttons: buttons,background: false); getChartData(type: chartType); xAxisLabelCount = 4}
    
    @IBAction func sixMonthButtonClicked(_ sender: Any) {chartType = "six_months_before"; Util.setButtonColors(except: sixMonth, buttons: buttons,background: false); getChartData(type: chartType); xAxisLabelCount = 7}
    
    @IBAction func oneYearButtonClicked(_ sender: Any) {chartType = "one_year_before"; Util.setButtonColors(except: oneYear, buttons: buttons,background: false) ;getChartData(type: chartType); xAxisLabelCount = 13}
    
    @IBAction func allButtonClicked(_ sender: Any) { chartType = "all"; Util.setButtonColors(except: all, buttons: buttons,background: false) ;getChartData(type: chartType); xAxisLabelCount = 12}
    
    
    /// Gets chart data according to given timescale
    func getChartData(type : String)
    {
        DispatchQueue.main.async{self.hideActivityIndicator();self.showActivityIndicator()}
        CoinGecko.getDataForCharts(id: self.coinId, currency: Currency.currencyKey, type: type) { (chartdata) in
                self.values = chartdata
                DispatchQueue.main.async{self.hideActivityIndicator();self.updateChart()}
            }
    }
    
    ///Shows spinner
    func showActivityIndicator()
    {
        if #available(iOS 13.0, *) {activityView = UIActivityIndicatorView(style: .medium)}
        else {activityView = UIActivityIndicatorView(style: .gray)}
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    ///Hides spinner
    func hideActivityIndicator(){if (activityView != nil){activityView?.stopAnimating()}}
    
    //Locks the screen
    override func viewWillAppear(_ animated: Bool) {super.viewWillAppear(animated);AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)}
    override func viewWillDisappear(_ animated: Bool) {super.viewWillDisappear(animated);print("Disappear")}

}
