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
    
    private let scheduleStore: ScheduleStore
    let maxPeriods = 12
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // Observe scheduleStore changes to trigger view updates
        scheduleStore.$subjects
            .sink { [weak self] _ in
                self?.objectWillChange.send()
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
}
