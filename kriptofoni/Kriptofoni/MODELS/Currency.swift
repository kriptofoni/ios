//
//  Currency.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 29.03.2021.
//

import Foundation

class Currency
{
    private var id : String
    private var count : Int
    private var iconViewUrl : String
    private var name : String
    private var percent : NSNumber
    private var change : NSNumber
    private var price : NSNumber
    private var shortening : String
    
    init(id: String, count: Int, iconViewUrl : String, name: String, percent: NSNumber, change : NSNumber, price : NSNumber, shortening : String)
    {
        self.id = id
        self.count = count
        self.iconViewUrl = iconViewUrl
        self.name = name
        self.percent = percent
        self.change = change
        self.price = price
        self.shortening = shortening
    }
    
    func getId() -> String{return id}
    func getCount() -> Int{return count}
    func getIconViewUrl() -> String{return iconViewUrl}
    func getName() -> String{return name}
    func getPercent() -> NSNumber{return percent}
    func getChange() -> NSNumber{return change}
    func getPrice() -> NSNumber{return price}
    func getShortening() -> String{return shortening}
}
