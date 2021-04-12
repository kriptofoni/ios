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
    var coinId : String = "";var currencyKey : String = ""
    var charType = true; //true for line chart, false for candle
    let coingecko = CoinGecko.init()
    var buttons = [UIButton]()
        
    
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
            chartView.chartDescription!.enabled = false;
            chartView.dragEnabled = true;
            chartView.setScaleEnabled(true)
            chartView.pinchZoomEnabled = true
            chartView.rightAxis.enabled = false
            chartView.xAxis.labelPosition = .bottom
            let set1 = LineChartDataSet(entries: values ,label: "Prices")
            set1.drawCirclesEnabled = false
            set1.lineWidth = 1.5
            let data = LineChartData(dataSet: set1)
            data.setDrawValues(false)
            chartView.data = data
        }
        else
        {
            candleView.isHidden = false; chartView.isHidden = true
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) { self.dismiss(animated: true, completion: nil)}
    
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
    
    @IBAction func twentyFourButtonClicked(_ sender: Any) {Util.setButtonColors(except: twentyFour, buttons: buttons, background: false); getChartData(type: "twentyFour_hours")}
    
    @IBAction func oneWeekButtonClicked(_ sender: Any) {Util.setButtonColors(except: oneweek, buttons: buttons,background: false);getChartData(type: "one_week_before")}
    
    @IBAction func oneMonthButtonClicked(_ sender: Any) {Util.setButtonColors(except: oneMonth, buttons: buttons,background: false); getChartData(type: "one_month_before")}
    
    @IBAction func threeMonthButtonClicked(_ sender: Any) {Util.setButtonColors(except: threeMonth, buttons: buttons,background: false); getChartData(type: "three_months_before")}
    
    @IBAction func sixMonthButtonClicked(_ sender: Any) {Util.setButtonColors(except: sixMonth, buttons: buttons,background: false); getChartData(type: "six_months_before")}
    
    @IBAction func oneYearButtonClicked(_ sender: Any) {Util.setButtonColors(except: oneYear, buttons: buttons,background: false) ;getChartData(type: "one_year_before")}
    
    @IBAction func allButtonClicked(_ sender: Any) {Util.setButtonColors(except: all, buttons: buttons,background: false) ;getChartData(type: "all")}
    
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
    
   
    
    
    
    /// Gets chart data according to given timescale
    func getChartData(type : String)
    {
        DispatchQueue.main.async{self.showActivityIndicator()}
        self.coingecko.getDataForCharts(id: self.coinId, currency: self.currencyKey, type: type) { (chartdata) in
                self.values = chartdata
                DispatchQueue.main.async{
                    self.hideActivityIndicator()
                    self.updateChart()
                }
            }onFailure: {print("Error")}
    }
    
    //Locks the screen
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       print("Disappear")
       AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
   }

}
