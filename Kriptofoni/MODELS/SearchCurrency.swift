//
//  SearchCurrency.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import Foundation

class SearchCurrency
{
    private var id : String
    private var imageUrl : String
    private var name : String
    private var symbol : String
    private var number : String
    
    init(id: String, imageUrl: String, name: String, symbol: String, number: String)
    {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.symbol = symbol
        self.number = number
    }
    
    func getId() -> String {return id}
    func getImageUrl() -> String {return imageUrl}
    func getName() -> String {return name}
    func getSymbol() -> String {return symbol}
    func getNumber() -> String{return number}
}
