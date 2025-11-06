//
//  TimetableViewModel.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI
import Combine

class TimetableViewModel: ObservableObject {
    @Published var showingAddSubject = false
    @Published var selectedSubject: Subject?
    @Published var initialDayForNewSubject: Int?
    @Published var initialPeriodForNewSubject: Int?
    @Published var hiddenDays: Set<Int> = []
    @Published var hiddenPeriods: Set<Int> = []
    @Published var isPeriodColumnHidden: Bool = false
    
    private let scheduleStore: ScheduleStore
    let maxPeriods = 12
    
    private var cancellables = Set<AnyCancellable>()
    private let hiddenDaysKey = "timetable_hidden_days"
    private let hiddenPeriodsKey = "timetable_hidden_periods"
    private let periodColumnHiddenKey = "timetable_period_column_hidden"
    
    // Expose store for dependency injection
    var store: ScheduleStore {
        scheduleStore
    }
    
    // Expose subjects for observation
    var subjects: [Subject] {
        scheduleStore.subjects
    }
    
    init(scheduleStore: ScheduleStore = ScheduleStore()) {
        self.scheduleStore = scheduleStore
        
        // Load hidden preferences
        loadHiddenPreferences()
        
        // Observe scheduleStore changes to trigger view updates
        scheduleStore.$subjects
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // Observe hidden state changes to save preferences
        $hiddenDays
            .sink { [weak self] _ in
                self?.saveHiddenPreferences()
            }
            .store(in: &cancellables)
        
        $hiddenPeriods
            .sink { [weak self] _ in
                self?.saveHiddenPreferences()
            }
            .store(in: &cancellables)
        
        $isPeriodColumnHidden
            .sink { [weak self] _ in
                self?.saveHiddenPreferences()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    var daysOfWeek: [String] {
        [
            "monday_short".localized,
            "tuesday_short".localized,
            "wednesday_short".localized,
            "thursday_short".localized,
            "friday_short".localized,
            "saturday_short".localized,
            "sunday_short".localized
        ]
    }
    
    var visibleDays: [Int] {
        (1...7).filter { !hiddenDays.contains($0) }
    }
    
    var visiblePeriods: [Int] {
        (1...maxPeriods).filter { !hiddenPeriods.contains($0) }
    }
    
    var dayNames: [String] {
        daysOfWeek
    }
    
    func getDayName(for day: Int) -> String {
        guard day >= 1 && day <= 7 else { return "" }
        return daysOfWeek[day - 1]
    }
    
    var subjectsWithoutPeriod: [Subject] {
        scheduleStore.subjects.filter { $0.period == nil }
    }
    
    // MARK: - Methods
    
    func getSubjects(for dayOfWeek: Int, period: Int? = nil) -> [Subject] {
        scheduleStore.getSubjects(for: dayOfWeek, period: period)
    }
    
    func addSubjectForDay(_ day: Int, period: Int) {
        initialDayForNewSubject = day
        initialPeriodForNewSubject = period
        showingAddSubject = true
    }
    
    func selectSubject(_ subject: Subject) {
        selectedSubject = subject
    }
    
    func showAddSubject() {
        showingAddSubject = true
    }
    
    func dismissAddSubject() {
        showingAddSubject = false
        initialDayForNewSubject = nil
        initialPeriodForNewSubject = nil
    }
    
    func dismissEditSubject() {
        selectedSubject = nil
    }
    
    // MARK: - Visibility Toggle Methods
    
    func toggleDayVisibility(_ day: Int) {
        if hiddenDays.contains(day) {
            hiddenDays.remove(day)
        } else {
            hiddenDays.insert(day)
        }
    }
    
    func togglePeriodVisibility(_ period: Int) {
        if hiddenPeriods.contains(period) {
            hiddenPeriods.remove(period)
        } else {
            hiddenPeriods.insert(period)
        }
    }
    
    func isDayHidden(_ day: Int) -> Bool {
        hiddenDays.contains(day)
    }
    
    func isPeriodHidden(_ period: Int) -> Bool {
        hiddenPeriods.contains(period)
    }
    
    // MARK: - Persistence
    
    private func loadHiddenPreferences() {
        if let daysData = UserDefaults.standard.data(forKey: hiddenDaysKey),
           let days = try? JSONDecoder().decode(Set<Int>.self, from: daysData) {
            hiddenDays = days
        }
        
        if let periodsData = UserDefaults.standard.data(forKey: hiddenPeriodsKey),
           let periods = try? JSONDecoder().decode(Set<Int>.self, from: periodsData) {
            hiddenPeriods = periods
        }
        
        isPeriodColumnHidden = UserDefaults.standard.bool(forKey: periodColumnHiddenKey)
    }
    
    private func saveHiddenPreferences() {
        if let daysData = try? JSONEncoder().encode(hiddenDays) {
            UserDefaults.standard.set(daysData, forKey: hiddenDaysKey)
        }
        
        if let periodsData = try? JSONEncoder().encode(hiddenPeriods) {
            UserDefaults.standard.set(periodsData, forKey: hiddenPeriodsKey)
        }
        
        UserDefaults.standard.set(isPeriodColumnHidden, forKey: periodColumnHiddenKey)
    }
}
