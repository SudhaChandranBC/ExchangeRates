//
//  Networking.swift
//  ExchangeRates
//
//  Created by Chandran, Sudha on 18/03/21.
//

import Foundation

var updatedTime = Double()

enum APIConstants: String {
    case host = "api.currencylayer.com"
    case baseUrl = "http://api.currencylayer.com/"
    case access_key = "access_key"
    case access_key_value = "ed77e0915315e85dfdb27ca2cf0bffaa"
}

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = []
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = APIConstants.host.rawValue
        components.path = "/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        return url
    }
}

extension Endpoint {
    static var list: Self {
        Endpoint(
            path: "list",
            queryItems: [URLQueryItem(
                name: APIConstants.access_key.rawValue,
                value: APIConstants.access_key_value.rawValue
            )]
        )
    }
    static var live: Self {
        Endpoint(
            path: "live",
            queryItems: [URLQueryItem(
                name: APIConstants.access_key.rawValue,
                value: APIConstants.access_key_value.rawValue
            )]
        )
    }
}

extension URL {
    static var live: URL {
        makeForEndpoint("live")
    }
    
    static var list: URL {
        makeForEndpoint("list")
    }

    static var convert: URL {
        makeForEndpoint("convert")
    }
}

private extension URL {
    static func makeForEndpoint(_ endpoint: String) -> URL {
        URL(string: APIConstants.baseUrl.rawValue+"\(endpoint)")!
    }
}

extension URLSession {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void
    
    @discardableResult
    func request(
        _ endpoint: Endpoint,
        then handler: @escaping Handler
    ) -> URLSessionDataTask {
        let task = dataTask(
            with: endpoint.url!,
            completionHandler: handler
        )
        
        task.resume()
        return task
    }
}

struct ErrorResponse: Codable {
    let code: Int
    let info: String
}
