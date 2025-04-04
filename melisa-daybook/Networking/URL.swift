//
//  File.swift
//  
//
//  Created by Kirill Ushkov on 11.11.2024.
//

import Foundation

public struct Endpoint {
    public let route: Route
    public var queryItems: [QueryItem] = []
    public init(route: Route, queryItems: [QueryItem] = []) {
        self.route = route
        self.queryItems = queryItems
    }
}

public struct UploadEndpoint {
    public struct Binary {
        public var uploadData: Data
        public var uploadName: String
        public var uploadFileName: String?
        public var mimeType: MimeType
        
        public init(uploadData: Data, uploadName: String, uploadFileName: String? = nil, mimeType: MimeType = .jpeg) {
            self.uploadData = uploadData
            self.uploadName = uploadName
            self.uploadFileName = uploadFileName
            self.mimeType = mimeType
        }
    }
    
    public enum MimeType: String {
        case png = "image/png"
        case jpeg = "image/jpeg"
    }
    
    public enum HTTPMethod: String {
        case post = "POST"
        case patch = "PATCH"
    }
    
    public let route: Route
    public let method: HTTPMethod
    public let binaryItems: [Binary]
    public var textContent: [String: String] = [:]
    
    public init(route: Route, method: HTTPMethod, binaryItems: [UploadEndpoint.Binary], textContent: [String : String] = [:]) {
        self.route = route
        self.method = method
        self.binaryItems = binaryItems
        self.textContent = textContent
    }
}

public enum Route {
    case allActivities
    case activities
    case activity(UUID)
    case finishActivity(UUID)
    
    var path: String {
        switch self {
        case .allActivities:
            "/activities/all"
        case .activities:
            "/activities"
        case .activity(let id):
            "/activities/\(id.uuidString)"
        case .finishActivity(let id):
            "/activities/\(id.uuidString)/finish"
        }
    }
}

public enum QueryItem {
    case date(String)
    public var urlQueryItem: URLQueryItem {
        switch self {
        case .date(let date):
            return URLQueryItem(name: "date", value: date)
        }
    }
}
