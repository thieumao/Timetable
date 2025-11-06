//
//  Period.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation

struct Period: Identifiable, Codable {
    let id: UUID
    var number: Int // Period number (1, 2, 3...)
    var startTime: String // e.g., "7:00"
    var endTime: String // e.g., "8:30"
    
    init(id: UUID = UUID(), number: Int, startTime: String, endTime: String) {
        self.id = id
        self.number = number
        self.startTime = startTime
        self.endTime = endTime
    }
    
    var timeDisplay: String {
        "\(startTime) - \(endTime)"
    }
}

