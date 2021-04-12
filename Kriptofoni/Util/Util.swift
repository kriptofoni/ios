//
//  Util.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 11.04.2021.
//

import Foundation
import UIKit

class Util
{
    ///Changes double to string as price 100000.90 -->  100,000.90
    static func toPrice(_ price: Double, isCoinDetailPrice : Bool) -> String
    {
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            if isCoinDetailPrice {numberFormatter.maximumFractionDigits = 10}
            print("Formated Price is" + String(price))
            return numberFormatter.string(from: price as NSNumber)!
    }
    
    ///Makes all buttons gray except "except button". Makes "except button" yellow. If background is true, func only changes the background color of button.
    static func setButtonColors(except: UIButton, buttons : [UIButton], background : Bool)
    {
        for button in buttons
        {
            if background
            {
                
                if button == except{button.backgroundColor = hexStringToUIColor(hex: "F2A900")}
                else{button.backgroundColor = hexStringToUIColor(hex: "797676")}
               
            }
            else
            {
                if button == except{button.setTitleColor(hexStringToUIColor(hex: "F2A900"), for: .normal)}
                else{button.setTitleColor(hexStringToUIColor(hex: "797676"), for: .normal)}
            }
            
        }
    }
    
    static func setButtonColorsBackGround(except: UIButton, buttons: [UIButton], normalBackground: UIColor)
    {
        for button in buttons
        {
            if button == except{button.backgroundColor = hexStringToUIColor(hex: "F2A900")}
            else{button.backgroundColor = normalBackground}
        }
      
    }
    
    ///Converts hex string to UI Color
    static func hexStringToUIColor (hex:String) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {cString.remove(at: cString.startIndex)}
        if ((cString.count) != 6) {return UIColor.gray}
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
