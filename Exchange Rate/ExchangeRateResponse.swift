//
//  ExchangeRateResponse.swift
//  Exchange Rate
//
//  Created by Trakya18 on 12.05.2025.
//

import Foundation
struct ExhangeRateResponse: Codable {
    let data: [String: Curr]
}

struct Curr: Codable {
    var code: String
    var value: Double
}
