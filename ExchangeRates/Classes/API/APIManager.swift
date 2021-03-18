//
//  APIManager.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager: NSObject {
    
    static let sharedInstance: APIManager = APIManager()
    
    private override init() {}
    
    public typealias CurrencyListResponseHandler = ((_ data: [Currency], _ error: Error?) -> Void)
    public typealias CurrencyLiveDataResponseHandler = ((_ data: [ExchangeRate], _ error: Error?) -> Void)
    
}

extension APIManager {
    
    func loadCurrencies(completion: @escaping CurrencyListResponseHandler) {
        var currecncyListData: [Currency] = []
        var apiError: Error?
        let liveUrl = Endpoint.list.url
        AF.request(liveUrl!).responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    currecncyListData = APIManager.loadCurrencyFromData(data)
                }
            case let .failure(error):
                apiError = error
            }
            completion(currecncyListData, apiError)
        }
    }
    
    func loadLiveConvertionRates(completion: @escaping CurrencyLiveDataResponseHandler) {
        var liveConversionData: [ExchangeRate] = []
        var apiError: Error?
        let liveUrl = Endpoint.live.url
        
        AF.request(liveUrl!).responseData { response in
            switch response.result {
            case .success:
                if let data = response.data {
                    liveConversionData = APIManager.loadCurrencyLiveData(data)
                }
            case let .failure(error):
                apiError = error
            }
            completion(liveConversionData, apiError)
        }
    }
    
    class func loadCurrencyFromData(_ APIData: Data) -> [Currency]{
        var currencies = [Currency]()
        let json = try! JSON(data: APIData)
        if let list = json["currencies"].dictionary{
            let sortedList = list.sorted(by: <)
            for (key, value) in sortedList
            {
                let currency = Currency(code: "\(key)", name: "\(value)")
                currencies.append(currency)
            }
        }
        return currencies
    }
    
    class func loadCurrencyLiveData(_ APIData: Data) -> [ExchangeRate]{
        var exchangeRates = [ExchangeRate]()
        let json = try! JSON(data: APIData)
        updatedTime = json["timestamp"].doubleValue
        if let list = json["quotes"].dictionary{
            let sortedList = list.sorted(by: <)
            for (key, value) in sortedList
            {
                let rate = value.doubleValue
                let code = key.replacingOccurrences(of: "USD", with: "", options: String.CompareOptions.literal, range: key.range(of: "USD"))
                let currency = ExchangeRate(code: code, rate: rate)
                exchangeRates.append(currency)
            }
        }
        return exchangeRates
    }
    
}


