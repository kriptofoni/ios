//
//  ChartFormatter.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 14.04.2021.
//

import Foundation
import Charts

@objc(LineChartFormatter)

class LineChartFormatter: NSObject, IAxisValueFormatter
{
    var type : String
    init(type: String) {self.type = type}
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        var returnString = ""
        let date = Date(timeIntervalSince1970: value)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        if type == "twentyFour_hours"
        {
            dateFormatter.setLocalizedDateFormatFromTemplate("hh")
            let localDate = dateFormatter.string(from: date)
            returnString = localDate
        }
        else if type == "one_week_before"
        {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            let localDateMonth = dateFormatter.string(from: date)
            dateFormatter.setLocalizedDateFormatFromTemplate("dd")
            let localDateDay = dateFormatter.string(from: date)
            returnString = localDateDay + "" + localDateMonth
        }
        else if type == "one_month_before"
        {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            let localDateMonth = dateFormatter.string(from: date)
            dateFormatter.setLocalizedDateFormatFromTemplate("dd")
            let localDateDay = dateFormatter.string(from: date)
            returnString = localDateDay + "" + localDateMonth
        }
        else if type ==  "three_months_before"
        {
            dateFormatter.dateFormat = "MM"
            let localDate = Double(dateFormatter.string(from: date))!
            returnString = Util.toMonth(monthCount: Int(localDate))
        }
        else if type == "six_months_before"
        {
            dateFormatter.dateFormat = "MM"
            let localDate = Double(dateFormatter.string(from: date))!
            returnString = Util.toMonth(monthCount: Int(localDate))
        }
        else if type == "one_year_before"
        {
            dateFormatter.dateFormat = "MM"
            let localDate = Double(dateFormatter.string(from: date))!
            returnString = Util.toMonth(monthCount: Int(localDate))
        }
        else if type == "all"
        {
            dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
            let localDate = dateFormatter.string(from: date)
            returnString = localDate
        }
        return returnString
    }
}


class ChartUtil
{
    static func setLineChartSettings(chartView : LineChartView, xAxisLabelCount : Int, values: [ChartDataEntry], dict : [String:Any], chartType: String)
    {
        chartView.chartDescription!.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.setLabelCount(xAxisLabelCount, force: true) // Sets the x axis label count according to time scale
        let set1 = LineChartDataSet(entries: values ,label: "Fiyatlar")
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1.5
        set1.drawFilledEnabled = true
        if !values.isEmpty
        {
            if values.last!.y - values.first!.y > 0 // Color of chart
            {
                set1.fill = Fill(color: UIColor.green);set1.fillAlpha = 0.6; set1.setColor(Util.newGreen!)
            }
            else
            {
                set1.fill = Fill(color: UIColor.red);set1.fillAlpha = 0.6; set1.setColor(Util.newRed!)
            }
        }
        let data = LineChartData(dataSet: set1)
        let chartDataFormatter = LineChartFormatter(type: chartType)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartDataFormatter
        xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = xAxis.valueFormatter
        data.setDrawValues(false)
        chartView.data = data
    }
    
    static func setCandleChartSettings(candleView: CandleStickChartView, xAxisLabelCount: Int, values : [CandleChartDataEntry], chartType: String, xAxisArray : [Double])
    {
        candleView.chartDescription!.enabled = false
        candleView.dragEnabled = true
        candleView.setScaleEnabled(true)
        candleView.pinchZoomEnabled = true
        candleView.rightAxis.enabled = false
        candleView.xAxis.labelPosition = .bottom
        candleView.maxVisibleCount = 200
        candleView.xAxis.setLabelCount(xAxisLabelCount, force: true) // Sets the x axis label count according to time scale
        let set1 = CandleChartDataSet(entries: values ,label: "Fiyatlar")
        set1.axisDependency = .left
        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColor = .darkGray
        set1.shadowWidth = 0.7
        set1.decreasingColor = Util.newRed
        set1.decreasingFilled = true
        set1.increasingColor = Util.newGreen
        set1.increasingFilled = true
        set1.neutralColor = .blue
        let data = CandleChartData(dataSet: set1)
        let chartDataFormatter = LineChartFormatter(type: chartType)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartDataFormatter
        xAxis.labelPosition = .bottom
        candleView.xAxis.valueFormatter = xAxis.valueFormatter
        var count = 0.0
        for item in values
        {
            item.x = count
            count = count + 1//UĞRaş
        }
        data.setDrawValues(false)
        candleView.data = data
    }
}

