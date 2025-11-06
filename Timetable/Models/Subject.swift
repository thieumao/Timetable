//
//  Subject.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI

struct Subject: Identifiable, Codable {
    let id: UUID
    var name: String
    var dayOfWeek: Int // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
    var period: Int? // Optional: period number (1, 2, 3...)
    var customTime: String? // Optional: custom time (e.g., "7:00-8:30")
    var color: SubjectColor
    
    init(id: UUID = UUID(), name: String, dayOfWeek: Int, period: Int? = nil, customTime: String? = nil, color: SubjectColor = .blue) {
        self.id = id
        self.name = name
        self.dayOfWeek = dayOfWeek
        self.period = period
        self.customTime = customTime
        self.color = color
    }
    
    var timeDisplay: String {
        if let customTime = customTime, !customTime.isEmpty {
            return customTime
        } else if let period = period {
            return "period_format".localized.replacingOccurrences(of: "%d", with: "\(period)")
        } else {
            return ""
        }
    }
}

enum SubjectColor: String, Codable, CaseIterable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case red = "red"
    case pink = "pink"
    case teal = "teal"
    case indigo = "indigo"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        case .pink: return .pink
        case .teal: return .teal
        case .indigo: return .indigo
        }
    }
    
    var displayName: String {
        switch self {
        case .blue: return "blue".localized
        case .green: return "green".localized
        case .orange: return "orange".localized
        case .purple: return "purple".localized
        case .red: return "red".localized
        case .pink: return "pink".localized
        case .teal: return "teal".localized
        case .indigo: return "indigo".localized
        }
    }
}
