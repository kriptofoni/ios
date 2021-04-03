//
//  Currency.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 29.03.2021.
//

import Foundation

class Coin
{
    private var id : String
    private var count : Int
    private var iconViewUrl : String
    private var name : String
    private var percent : NSNumber
    private var change : NSNumber
    private var price : NSNumber
    private var shortening : String
    private var percent7d : NSNumber
    
    init(id: String, count: Int, iconViewUrl : String, name: String, percent: NSNumber, change : NSNumber, price : NSNumber, shortening : String, percent7d : NSNumber)
    {
        self.id = id
        self.count = count
        self.iconViewUrl = iconViewUrl
        self.name = name
        self.percent = percent
        self.change = change
        self.price = price
        self.shortening = shortening
        self.percent7d = percent7d
    }
    
    
    init() {
        self.id = ""
        self.count = 0
        self.iconViewUrl = ""
        self.name = ""
        self.percent = 0
        self.change = 0
        self.price = 0
        self.shortening = ""
        percent7d = 0
    }
    func getId() -> String{return id}
    func getCount() -> Int{return count}
    func getIconViewUrl() -> String{return iconViewUrl}
    func getName() -> String{return name}
    func getPercent() -> NSNumber{return percent}
    func getChange() -> NSNumber{return change}
    func getPrice() -> NSNumber{return price}
    func getShortening() -> String{return shortening}
    func getPercent7d() -> NSNumber{return percent7d}
}
