//
//  SubjectEditViewModel.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI

class SubjectEditViewModel: ObservableObject {
    @Published var name: String
    @Published var dayOfWeek: Int
    @Published var period: Int?
    @Published var selectedColor: SubjectColor
    
    private let scheduleStore: ScheduleStore
    let periodStore: PeriodStore
    let subjectToEdit: Subject?
    let initialDay: Int?
    let initialPeriod: Int?
    
    var availablePeriods: [Period] {
        periodStore.periods.sorted { $0.number < $1.number }
    }
    
    var isSaveEnabled: Bool {
        !name.isEmpty
    }
    
    var isEditMode: Bool {
        subjectToEdit != nil
    }
    
    var navigationTitle: String {
        isEditMode ? "edit_subject".localized : "add_subject".localized
    }
    
    init(scheduleStore: ScheduleStore, periodStore: PeriodStore, subject: Subject? = nil, initialDay: Int? = nil, initialPeriod: Int? = nil) {
        self.scheduleStore = scheduleStore
        self.periodStore = periodStore
        self.subjectToEdit = subject
        self.initialDay = initialDay
        self.initialPeriod = initialPeriod
        
        self.name = subject?.name ?? ""
        self.dayOfWeek = subject?.dayOfWeek ?? initialDay ?? 1
        
        // Set period: use subject's period if editing, otherwise use initialPeriod, 
        // or default to first available period if none specified
        if let subjectPeriod = subject?.period {
            self.period = subjectPeriod
        } else if let initialPeriod = initialPeriod {
            self.period = initialPeriod
        } else {
            // Default to first available period when adding new subject
            let availablePeriods = periodStore.periods.sorted { $0.number < $1.number }
            self.period = availablePeriods.first?.number
        }
        
        self.selectedColor = subject?.color ?? .blue
    }
    
    func saveSubject() {
        if let subjectToEdit = subjectToEdit {
            // Editing existing subject - update it
            let subject = Subject(
                id: subjectToEdit.id,
                name: name,
                dayOfWeek: dayOfWeek,
                period: period,
                customTime: nil,
                color: selectedColor
            )
            scheduleStore.updateSubject(subject)
        } else {
            // Creating new subject - check if there's an existing subject with same day and period
            if let period = period {
                // Check for existing subject with same day and period
                let existingSubjects = scheduleStore.getSubjects(for: dayOfWeek, period: period)
                if let existingSubject = existingSubjects.first {
                    // Replace existing subject
                    let updatedSubject = Subject(
                        id: existingSubject.id,
                        name: name,
                        dayOfWeek: dayOfWeek,
                        period: period,
                        customTime: nil,
                        color: selectedColor
                    )
                    scheduleStore.updateSubject(updatedSubject)
                } else {
                    // No existing subject - create new one
                    let newSubject = Subject(
                        id: UUID(),
                        name: name,
                        dayOfWeek: dayOfWeek,
                        period: period,
                        customTime: nil,
                        color: selectedColor
                    )
                    scheduleStore.addSubject(newSubject)
                }
            } else {
                // No period specified - create new subject
                let newSubject = Subject(
                    id: UUID(),
                    name: name,
                    dayOfWeek: dayOfWeek,
                    period: period,
                    customTime: nil,
                    color: selectedColor
                )
                scheduleStore.addSubject(newSubject)
            }
        }
    }
    
    func deleteSubject() {
        if let subjectToEdit = subjectToEdit {
            scheduleStore.deleteSubject(subjectToEdit)
        }
    }
}
