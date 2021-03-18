//
//  CurrencyModel.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import Foundation

struct Currency: Codable {
    let code: String
    let name: String
}

struct ExchangeRate: Codable {
    let code: String
    let rate: Double
}

class CurrencyModel: ObservableObject {
    var currencyList: [Currency]?
    var exchangeRates: [ExchangeRate]?
    var convertedRates: [ExchangeRate]?

    var selectedCurrencyIndex: Int = 0
    private var conversionAmount: Double = 1
    private var defaultCurrencyCode: String = "USD"
    
    func loadCurrencyList(success: @escaping ([Currency]?) -> Void,
                          failure: @escaping (ErrorResponse?) -> Void) {
        APIManager.sharedInstance.loadCurrencies {
            [weak self](response, error) in
            if let weakSelf = self {
                if (error == nil) {
                    weakSelf.currencyList = response
                    success(response)
                } else {
                    failure(ErrorResponse(code: -1, info: "Something went wrong"))
                }
            }
        }
        
    }
    
    func loadLiveExchangeRates( success: @escaping ([ExchangeRate]?) -> Void,
                                failure: @escaping (ErrorResponse?) -> Void) {
        APIManager.sharedInstance.loadLiveConvertionRates {
            [weak self](rates, error) in
            if let weakSelf = self {
                if (error == nil) {
                    weakSelf.exchangeRates = rates
                    success(rates)
                } else {
                    failure(ErrorResponse(code: -1, info: "Something went wrong"))
                }
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { timer in
            self.loadLiveExchangeRates(success: {_ in }, failure: {_ in})
        }
        
    }
    
    func convertAmount(for currency: String?, amount: Double) {
        if let currency = currency {
            
            let usdToSelectedCurrencyRate = exchangeRates?.filter({
                $0.code == currency
            })
            convertedRates = exchangeRates?.map({
                var rate: Double
                
                if currency == defaultCurrencyCode {
                    rate = $0.rate * amount
                } else {
                    rate = ($0.rate / (usdToSelectedCurrencyRate?.first?.rate ?? 1))  * amount
                }
                return ExchangeRate(
                    code: $0.code,
                    rate: rate)
            })
        }
    }
 
}
