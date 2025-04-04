//
//  File.swift
//  
//
//  Created by Kirill Ushkov on 11.11.2024.
//

import Foundation

public struct URLProvider: Sendable {
    public let url: @Sendable () -> URL
}

extension URLProvider {
    public static var dev: Self {
        Self(
            url: { URL(staticString: "http://127.0.0.1:8080") }
        )
    }
    
    
    public static var live: Self {
        Self(
            url: { fatalError() }
         )
    }
}

extension URL {
    public init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}
