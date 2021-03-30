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
    private var marketCapRank : NSNumber
    
    init(id: String, imageUrl: String, name: String, symbol: String, marketCapRank : NSNumber)
    {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.symbol = symbol
        self.marketCapRank = marketCapRank
    }
    
    func getId() -> String {return id}
    func getImageUrl() -> String {return imageUrl}
    func getName() -> String {return name}
    func getSymbol() -> String {return symbol}
    func getMarketCapRank() -> NSNumber {return marketCapRank}
}
