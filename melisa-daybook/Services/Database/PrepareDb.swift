//
//  DbConnection.swift
//  melisa-daybook
//
//  Created by Kirill Ushkov on 06.05.2025.
//

import Foundation
import OSLog
import Dependencies
import GRDB

func appDatabase() throws -> any DatabaseWriter {
    var config = Configuration()
    config.foreignKeysEnabled = true
    @Dependency(\.context) var context

    #if DEBUG
    config.prepareDatabase { db in
        db.trace {
            if context == .preview {
                print($0.expandedDescription)
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
    }
    #endif
    
    let database: any DatabaseWriter
    
    switch context {
    case .live:
        let path = URL.documentsDirectory.appendingPathComponent("daybook.sqlite").path()
        logger.debug("open \(path)")
        database = try DatabasePool(path: path, configuration: config)

    case .preview, .test:
        database = try DatabaseQueue(configuration: config)
    }
    
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    
    migrator.registerMigration("Create Baby Activities Table") { db in
        try db.create(table: "baby_activities", options: [.strict]) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("activityType", .text).notNull()
            t.column("startDate", .text).notNull()
            t.column("endDate", .text)
        }        
    }
    
    migrator.registerMigration("Seed database") { db in
        struct SeedData: Decodable {
            let startMillis: Date
            let endMillis: Date
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let url = Bundle.main.url(forResource: "out", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let dtos = try decoder.decode([SeedData].self, from: data)
        
        try db.seed {
            for dto in dtos {
                BabyActivity(activityType: .sleep, startDate: dto.startMillis, endDate: dto.endMillis)
            }
        }
    }
    
    try migrator.migrate(database)
    
    return database
}

private let logger = Logger(subsystem: "MelissaDayBook", category: "Database")
