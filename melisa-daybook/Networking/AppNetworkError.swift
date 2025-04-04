//
//  File.swift
//  
//
//  Created by Kirill Ushkov on 11.11.2024.
//

import Foundation

public struct ClientError: Decodable, Equatable, Error {
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case code
        case nonFieldErrors
        case securityToken
        case password1
        case nickname
    }
        
    public var fieldErrors: [FieldError]
    public var securityToken: String?

    public struct FieldError: Equatable, Sendable {
        public let kind: FieldErrorKind
        public let message: String
        
        public init(kind: ClientError.FieldErrorKind, message: String) {
            self.kind = kind
            self.message = message
        }
    }
        
    public enum FieldErrorKind: String, CodingKey, CaseIterable {
        case username
        case email
        case password
        case nonFieldErrors
        case invalidCredentials
        case detail
        case incorrectAvatarSize
        case phone
        case referralCode
        case code
        case fullName
        case birthdate
        case streetAddress
        case unitNumber
        case postalCode
        case vouchers
    }
    
    public init(from decoder: Decoder) throws {
        let fieldContainer = try decoder.container(keyedBy: FieldErrorKind.self)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.fieldErrors = []
        self.securityToken = try container.decodeIfPresent(String.self, forKey: .securityToken)
        
        for kind in FieldErrorKind.allCases {
            if let detailError = try fieldContainer.decodeIfPresent(Either<String, [String]>.self, forKey: kind) {
                let detail = FieldError(kind: kind, message: detailError.message)
                fieldErrors.append(detail)
            }
        }
    }
    
    public init(fieldErrors: [ClientError.FieldError], securityToken: String? = nil) {
        self.fieldErrors = fieldErrors
        self.securityToken = securityToken
    }
    
    public var message: String {
        fieldErrors.map { $0.message }.joined(separator: "\n")
    }
    
    public var nonFieldConsolidatedError: String? {
        let nonFieldErrors = fieldErrors.filter({ $0.kind == .nonFieldErrors })
        return nonFieldErrors.isEmpty ? nil : nonFieldErrors.map { $0.message }.joined(separator: "\n")
    }
}

extension ClientError {
    public func fieldError(with kind: FieldErrorKind) -> FieldError? {
        fieldErrors.first(where: { $0.kind == kind })
    }
    public var emailError: FieldError? {
        fieldErrors.first(where: { $0.kind == .email })
    }
    
    public var usernameError: FieldError? {
        fieldErrors.first(where: { $0.kind == .username })
    }
    
    public var passwordError: FieldError? {
        fieldErrors.first(where: { $0.kind == .password })
    }
    
    public var invalidCredentialsError: FieldError? {
        fieldErrors.first(where: { $0.kind == .invalidCredentials })
    }
    
    public var phoneError: FieldError? {
        fieldErrors.first(where: { $0.kind == .phone })
    }
    
    public var referralCodeError: FieldError? {
        fieldErrors.first(where: { $0.kind == .referralCode })
    }
    
    public var verifyCodeError: FieldError? {
        fieldErrors.first(where: { $0.kind == .code })
    }
}

extension ClientError: LocalizedError {
    public var errorDescription: String? { message }
}

public enum AppNetworkError: Error, Equatable {
    case client(ClientError)
    case generic
    case unauthorized
    case noInternetConnection
    case canceled
    case unacceptableStatusCode(Int)
}

extension AppNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .client(clientError):
            return clientError.errorDescription
            
        case .generic:
            return "Error occured. Please try again later"
            
        case .noInternetConnection:
            return "Please check your internet connection"
            
        default: return nil
        }
    }
}

enum Either<T, U> {
    case left(T)
    case right(U)
}

extension Either: Decodable where T: Decodable, U: Decodable {
    init(from decoder: Decoder) throws {
        if let value = try? T(from: decoder) {
            self = .left(value)
        } else if let value = try? U(from: decoder) {
            self = .right(value)
        } else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription:
                    "Cannot decode \(T.self) or \(U.self)"
            )
            throw DecodingError.dataCorrupted(context)
        }
    }
}

extension Either where T == String, U == [String] {
    var message: String {
        switch self {
        case .left(let string):
            return string
        case .right(let array):
            return array.joined(separator: "\n")
        }
    }
}
