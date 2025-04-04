//
//  AlamofireLogger.swift
//  bestextender
//
//  Created by Kirill Ushkov on 06.02.2024.
//

import Foundation
import Alamofire

final class AlamofireLogger: EventMonitor {
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        response.logResponse()
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        response.logResponse()
    }    
}

extension DataResponse {
    
    func logResponse() {
        let requestMethod = self.request?.httpMethod ?? "ERROR"
        let requestUrl = self.request?.url?.absoluteString ?? "UNKNOWN"
        let requestHeader = self.request?.headers ?? [:]
        let requestBody = String(data: (self.request?.httpBody ?? "NONE".data(using: .utf8)!), encoding: .utf8)!
        var responseError: String
        
        switch self.result {
            case .failure(let error):
                responseError = error.localizedDescription
            default:
                responseError = "NONE"
        }
        
        let responseBody: String
        
        if let data = self.data,
           let bodyString = String(data: data, encoding: .utf8) {
            responseBody = bodyString
        } else {
            responseBody = "NONE"
        }
        
        print("""
        ℹ️ \(Date())
        Request: [\(requestMethod)] \(requestUrl)
        Headers: \(requestHeader.dictionary)
        Body: \(requestBody)
        Error: \(responseError)
        Response: \(responseBody)
        """)
    }
    
}
