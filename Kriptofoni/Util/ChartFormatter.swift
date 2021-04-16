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
    
    init(type: String) {
        self.type = type
    }
    
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
        let set1 = LineChartDataSet(entries: values ,label: "Prices")
        set1.drawCirclesEnabled = false
        set1.lineWidth = 1.5
        set1.drawFilledEnabled = true
        if (dict["price_change_percentage_24h"]! as! NSNumber).intValue > 0 // Color of chart
        {
            set1.fill = Fill(color: UIColor.green);set1.fillAlpha = 0.6; set1.setColor(UIColor.green)
        }
        else
        {
            set1.fill = Fill(color: UIColor.red);set1.fillAlpha = 0.6; set1.setColor(UIColor.red)
        }
        let data = LineChartData(dataSet: set1)
        let chartDataFormatter = LineChartFormatter(type: chartType)
        let xAxis = XAxis()
        for variable in values {_ = chartDataFormatter.stringForValue(variable.y, axis: xAxis)}
        xAxis.valueFormatter = chartDataFormatter
        xAxis.labelPosition = .bottom
        chartView.xAxis.valueFormatter = xAxis.valueFormatter
        data.setDrawValues(false)
        chartView.data = data
    }
}

