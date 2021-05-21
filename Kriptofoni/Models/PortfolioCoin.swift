//
//  PortfolioCoin.swift
//  Kriptofoni
//
//  Created by Cem Sertkaya on 29.04.2021.
//

import Foundation
class PortfolioOperation
{
    private let coinId : String
    private let quantity : Double
    private let date : Double
    private let price : Double
    private let fee : Double
    private let note : String
    private let type : Bool
    
    init(coinId: String, quantity : Double, date : Double, price : Double, fee : Double, note : String, type : Bool)
    {
        self.coinId = coinId
        self.quantity = quantity
        self.date = date
        self.price = price
        self.fee = fee
        self.note = note
        self.type = type
    }
    
    func getCoinId() -> String {return coinId}
    func getQuantity() -> Double {return quantity}
    func getDate() -> Double {return date}
    func getPrice() -> Double {return price}
    func getFee() -> Double {return fee}
    func getNote() -> String {return note}
    func getType() -> Bool {return type}
}
