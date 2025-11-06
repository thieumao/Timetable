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
        self.period = subject?.period ?? initialPeriod
        self.selectedColor = subject?.color ?? .blue
    }
    
    func saveSubject() {
        let subject = Subject(
            id: subjectToEdit?.id ?? UUID(),
            name: name,
            dayOfWeek: dayOfWeek,
            period: period,
            customTime: nil,
            color: selectedColor
        )
        
        if let subjectToEdit = subjectToEdit {
            scheduleStore.updateSubject(subject)
        } else {
            scheduleStore.addSubject(subject)
        }
    }
    
    func deleteSubject() {
        if let subjectToEdit = subjectToEdit {
            scheduleStore.deleteSubject(subjectToEdit)
        }
    }
}
