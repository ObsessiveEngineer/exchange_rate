//
//  ExchangeRate.swift
//  Exchange Rate
//
//  Created by Trakya18 on 12.05.2025.
//
import Alamofire
import Foundation
class ExchangeRate {
    private static var key = ""
    private static var baseUrl = "https://api.currencyapi.com/v3/latest"
    
    static func getExchangeRates(completion: @escaping (ExhangeRateResponse?) -> Void) {
        let headers: HTTPHeaders = [
            "apikey": key
        ]
        
        
        AF.request(
            baseUrl,
            method: .get,
            headers: headers
        ).validate()
            .responseDecodable(of: ExhangeRateResponse.self) { response in
                switch response.result {
                case .success(let exchangeRates):
                    completion(exchangeRates)
                case .failure(let error):
                    completion(nil)
                }
            }
    }
    
}
