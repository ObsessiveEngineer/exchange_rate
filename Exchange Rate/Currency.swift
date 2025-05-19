//
//  Currency.swift
//  Exchange Rate
//
//  Created by Trakya7 on 10.05.2025.
//

import Foundation

class Currency {
    var code: String
    var amount: Double
    
    init(code: String, amount: Double) {
        self.code = code
        self.amount = amount
    }
    
    func convertTo(targetCode: String, exchangeRate: Double) -> Currency {
        let amount = self.amount * exchangeRate
        return Currency(code: targetCode, amount: amount)
    }
}
