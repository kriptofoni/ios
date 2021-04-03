//
//  SearchCurrency.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 28.03.2021.
//

import Foundation

class SearchCoin
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
    
    init()
    {
        self.id = ""
        self.imageUrl = ""
        self.name = ""
        self.symbol = ""
        self.marketCapRank = 0
        self.priceChange24H = 0
        self.priceChangePercentage24H = 0
        self.priceChangePercentage7D = 0
    }
    
    func getId() -> String {return id}
    func getImageUrl() -> String {return imageUrl}
    func getName() -> String {return name}
    func getSymbol() -> String {return symbol}
    func getMarketCapRank() -> NSNumber {return marketCapRank}
    func getPriceChange24() -> NSNumber {return priceChange24H}
    func getPriceChangePercantage24H() -> NSNumber {return priceChangePercentage24H}
    func getPriceChangePercantage7D() -> NSNumber {return priceChangePercentage7D}
    
    func setId(id : String){self.id = id}
    func setImageUrl(imageUrl : String){self.imageUrl = imageUrl}
    func setName(name : String){self.name = name}
    func setSymbol(symbol : String){self.symbol = symbol}
    func setMarketCapRank(marketCapRank : NSNumber){self.marketCapRank = marketCapRank}
    func setPriceChange24H(priceChange24H : NSNumber) {self.priceChange24H = priceChange24H}
    func setPriceChangePercentage24H(priceChangePercentage24H : NSNumber) {self.priceChangePercentage24H = priceChangePercentage24H}
    func setPriceChangePercentage7D(priceChangePercentage7D : NSNumber) {self.priceChangePercentage7D = priceChangePercentage7D}
}
