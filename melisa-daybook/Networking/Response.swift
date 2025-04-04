//
//  Response.swift
//  PackingAppConcept
//
//  Created by Kirill Ushkov on 06.12.2024.
//
import Foundation

public protocol CursorPaginatedResponse: Decodable {
    associatedtype Result: Decodable
    var results: [Result] { get }
    var next: URL? { get }
}
