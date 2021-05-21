//
//  Util.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 11.04.2021.
//

import Foundation
import UIKit
import Charts

class Util
{
    static var bodyColor = UIColor(named: "Body Color")
    static var menuColor = UIColor(named: "Menu Color")
    static var newGreen = UIColor(named: "New Green")
    static var newRed = UIColor(named: "New Red")
    static var defaultFont = UIColor(named: "Default Font Color")
    
    
    static func changeLabelColor(data: Double, label: UILabel)
    {
        if data > 0
        {
            label.textColor = Util.newGreen
        }
        else if data < 0
        {
            label.textColor = Util.newRed
        }
        else
        {
            label.textColor = Util.defaultFont
        }
    }
    //Set cell attributes's value in CurrencyCell
    static func setCurrencyCell(cell: CurrencyCell, coin: Coin, index : Int, mainPage : Bool)
    {
        let url = URL(string: coin.getIconViewUrl())
        cell.iconView.sd_setImage(with: url) { (_, _, _, _) in}
        cell.name.text = coin.getName()
        let percent = coin.getPercent()
        let change = coin.getChange()
        cell.percent.text = "%" + String(format: "%.2f", percent.doubleValue)
        cell.change.text = String(format: "%.2f", change.doubleValue)
        if percent.doubleValue > 0
        {
            cell.change.textColor = UIColor(named: "New Green")
            cell.percent.textColor = UIColor(named: "New Green")
        }
        else if percent.doubleValue < 0
        {
            cell.change.textColor = UIColor(named: "New Red")
            cell.percent.textColor = UIColor(named: "New Red")
        }
        else
        {
            cell.change.textColor = UIColor(named: "Default Text Color")
            cell.percent.textColor = UIColor(named: "Default Text Color")
        }
    
        cell.price.text = Currency.currencySymbol + " " + Util.toPrice(coin.getPrice().doubleValue, isCoinDetailPrice: false)
        if mainPage
        {
            cell.shortening.text = "#" + String(index + 1) +  " - " + coin.getShortening().uppercased()
        }
        else
        {
            cell.shortening.text = coin.getShortening().uppercased()
        }
        
    }
    
    //Converts months counts to months strings
    static func toMonth(monthCount: Int) -> String
    {
        var month = ""
        switch monthCount
        {
                case 1: month = "Jan"
                case 2: month = "Feb"
                case 3: month = "Mar"
                case 4: month =  "Apr"
                case 5: month =  "May"
                case 6: month = "Jun"
                case 7: month = "Jul"
                case 8: month = "Aug"
                case 9: month = "Sep"
                case 10: month = "Oct"
                case 11: month = "Now"
                case 12: month = "Dec"
                default: month = "MM"
        }
        return month
    }
    
    
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
    
    static func createBottomLine(textField : UITextField)
        {
            let bottomLine = CALayer()
            bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height, width: textField.frame.width, height: 1.0)
            bottomLine.backgroundColor = UIColor.black.cgColor
            textField.borderStyle = UITextField.BorderStyle.none
            textField.layer.addSublayer(bottomLine)
        }
    
   
}
