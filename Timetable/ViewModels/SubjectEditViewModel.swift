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
    @Published var customTime: String
    @Published var selectedColor: SubjectColor
    @Published var useCustomTime: Bool
    
    private let scheduleStore: ScheduleStore
    let subjectToEdit: Subject?
    let initialDay: Int?
    let initialPeriod: Int?
    
    var isSaveEnabled: Bool {
        !name.isEmpty
    }
    
    var isEditMode: Bool {
        subjectToEdit != nil
    }
    
    var navigationTitle: String {
        isEditMode ? "edit_subject".localized : "add_subject".localized
    }
    
    init(scheduleStore: ScheduleStore, subject: Subject? = nil, initialDay: Int? = nil, initialPeriod: Int? = nil) {
        self.scheduleStore = scheduleStore
        self.subjectToEdit = subject
        self.initialDay = initialDay
        self.initialPeriod = initialPeriod
        
        self.name = subject?.name ?? ""
        self.dayOfWeek = subject?.dayOfWeek ?? initialDay ?? 1
        self.period = subject?.period ?? initialPeriod
        self.customTime = subject?.customTime ?? ""
        self.selectedColor = subject?.color ?? .blue
        self.useCustomTime = subject?.customTime != nil && !subject!.customTime!.isEmpty
    }
    
    func saveSubject() {
        let subject = Subject(
            id: subjectToEdit?.id ?? UUID(),
            name: name,
            dayOfWeek: dayOfWeek,
            period: useCustomTime ? nil : period,
            customTime: useCustomTime && !customTime.isEmpty ? customTime : nil,
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
