//
//  PeriodStore.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI

class PeriodStore: ObservableObject {
    @Published var periods: [Period] = []
    
    private let userDefaultsKey = "timetable_periods"
    private let hasSetDefaultsKey = "timetable_periods_has_set_defaults"
    
    init() {
        loadPeriods()
    }
    
    // MARK: - CRUD Operations
    
    func addPeriod(_ period: Period) {
        periods.append(period)
        periods.sort { $0.number < $1.number }
        savePeriods()
    }
    
    func updatePeriod(_ period: Period) {
        if let index = periods.firstIndex(where: { $0.id == period.id }) {
            periods[index] = period
            periods.sort { $0.number < $1.number }
            savePeriods()
        }
    }
    
    func deletePeriod(_ period: Period) {
        periods.removeAll { $0.id == period.id }
        savePeriods()
    }
    
    func deletePeriod(at indexSet: IndexSet) {
        periods.remove(atOffsets: indexSet)
        savePeriods()
    }
    
    func getPeriod(number: Int) -> Period? {
        periods.first { $0.number == number }
    }
    
    func getNextPeriodNumber() -> Int {
        if periods.isEmpty {
            return 1
        }
        return (periods.map { $0.number }.max() ?? 0) + 1
    }
    
    // MARK: - Persistence
    
    private func savePeriods() {
        if let encoded = try? JSONEncoder().encode(periods) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadPeriods() {
        let hasSetDefaults = UserDefaults.standard.bool(forKey: hasSetDefaultsKey)
        
        if !hasSetDefaults {
            // First time - set default 5 periods
            setDefaultPeriods()
            UserDefaults.standard.set(true, forKey: hasSetDefaultsKey)
        } else {
            // Load saved periods
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
               let decoded = try? JSONDecoder().decode([Period].self, from: data) {
                periods = decoded.sorted { $0.number < $1.number }
            }
        }
    }
    
    private func setDefaultPeriods() {
        periods = [
            Period(number: 1, startTime: "7:00", endTime: "7:45"),
            Period(number: 2, startTime: "7:50", endTime: "8:35"),
            Period(number: 3, startTime: "8:40", endTime: "9:25"),
            Period(number: 4, startTime: "9:30", endTime: "10:15"),
            Period(number: 5, startTime: "10:20", endTime: "11:05")
        ]
        savePeriods()
    }
}

