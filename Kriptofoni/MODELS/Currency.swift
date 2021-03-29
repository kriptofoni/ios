//
//  Currency.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 29.03.2021.
//

import Foundation

class Currency {
    private var id : String
    private var count : Int
    private var iconViewUrl : String
    private var name : String
    private var percent : Int
    private var change : Int
    private var price : Int
    
    
    init(id: String, count: Int, iconViewUrl : String, name: String, percent: Int, change : Int, price : Int)
    {
        self.id = id
        self.count = count
        self.iconViewUrl = iconViewUrl
        self.name = name
        self.percent = percent
        self.change = change
        self.price = price
    }
    
    func getId() -> String{return id}
    func getCount() -> Int{return count}
    func getIconViewUrl() -> String{return iconViewUrl}
    func getName() -> String{return name}
    func getPercent() -> Int{return percent}
    func getChange() -> Int{return change}
    func getPrice() -> Int{return price}
}
