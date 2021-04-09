//
//  DetailedChartViewController.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 9.04.2021.
//

import UIKit
import Charts

class DetailedChartViewController: UIViewController, ChartViewDelegate
{

  
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var candleView: CandleStickChartView!
    var values = [ChartDataEntry]()
    var charType = true; //true for line chart, false for candle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(values)
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        chartView.delegate = self;candleView.delegate = self
        addChart()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.landscape //return the value as per the required orientation
    }

    override var shouldAutorotate: Bool {return false}
    
    func addChart()
    {
        
        switch traitCollection.userInterfaceStyle
        {
            case .light, .unspecified: chartView.backgroundColor = .white; candleView.backgroundColor = .white
            case .dark: chartView.backgroundColor = .black; candleView.backgroundColor = .white
            @unknown default: chartView.backgroundColor = .white;candleView.backgroundColor = .white
        }
        if charType
        {
            candleView.isHidden = true
            chartView.isHidden = false
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
            candleView.isHidden = false
            chartView.isHidden = true
        }
    }
    
}
