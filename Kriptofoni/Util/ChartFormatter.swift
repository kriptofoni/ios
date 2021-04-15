//
//  ChartFormatter.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 14.04.2021.
//

import Foundation
import Charts
class ChartFormatter
{
    static func formatXAxis(xAxis: XAxis, for: String)
    {
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["x","y"])
    }
}
