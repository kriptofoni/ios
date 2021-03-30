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
    private var priceChange24H : NSNumber
    private var priceChangePercentage24H : NSNumber
    private var priceChangePercentage7D : NSNumber
    
    
    init(id: String, imageUrl: String, name: String, symbol: String, marketCapRank : NSNumber, priceChange24H: NSNumber, priceChangePercentage24H : NSNumber, priceChangePercentage7D : NSNumber)
    {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
        self.symbol = symbol
        self.marketCapRank = marketCapRank
        self.priceChange24H = priceChange24H
        self.priceChangePercentage24H = priceChangePercentage24H
        self.priceChangePercentage7D = priceChangePercentage7D
    }
    
    func getId() -> String {return id}
    func getImageUrl() -> String {return imageUrl}
    func getName() -> String {return name}
    func getSymbol() -> String {return symbol}
    func getMarketCapRank() -> NSNumber {return marketCapRank}
    func getPriceChange24() -> NSNumber {return priceChange24H}
    func getPriceChangePercantage24H() -> NSNumber {return priceChangePercentage24H}
    func getPriceChangePercantage7D() -> NSNumber {return priceChangePercentage7D}
}
