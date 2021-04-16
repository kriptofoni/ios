//
//  CoinDetail.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 6.04.2021.
//

import Foundation

class CoinDetail
{
    private var percentFor24H : NSNumber
    private var change : NSNumber
    private var priceForCurrency : NSNumber
    private var percent7d : NSNumber
    private var coinStatsScore : NSNumber
    private var priceForBitcoin : NSNumber
    private var marketCap : NSNumber
    private var volumeFor24H : NSNumber
    
    
    init(percent: NSNumber, change : NSNumber, price : NSNumber, percent7d : NSNumber, coinStatsScore: NSNumber, priceForBitcoin : NSNumber, marketCap : NSNumber, volumeFor24: NSNumber)
    {
        self.percentFor24H = percent
        self.change = change
        self.priceForCurrency = price
        self.percent7d = percent7d
        self.coinStatsScore = coinStatsScore
        self.priceForBitcoin = priceForBitcoin
        self.marketCap = marketCap
        self.volumeFor24H = volumeFor24
    }
    
    
    init()
    {
        self.percentFor24H = 0
        self.change = 0
        self.priceForCurrency = 0
        self.percent7d = 0
        self.coinStatsScore = 0
        self.priceForBitcoin = 0
        self.marketCap = 0
        self.volumeFor24H = 0
    }
    
    func getPercent() -> NSNumber{return percentFor24H}
    func getChange() -> NSNumber{return change}
    func getPrice() -> NSNumber{return priceForCurrency}
    func getPercent7d() -> NSNumber{return percent7d}
    func getCoinStatsScore() -> NSNumber{return coinStatsScore}
    func getMarketCap() -> NSNumber{return marketCap}
    func getVolumeFor24H() -> NSNumber{return volumeFor24H}
}
