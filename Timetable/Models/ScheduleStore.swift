//
//  ScheduleStore.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import Foundation
import SwiftUI

class ScheduleStore: ObservableObject {
    @Published var subjects: [Subject] = []
    
    private let userDefaultsKey = "timetable_subjects"
    
    init() {
        loadSubjects()
    }
    
    // MARK: - CRUD Operations
    
    func addSubject(_ subject: Subject) {
        subjects.append(subject)
        saveSubjects()
    }
    
    func updateSubject(_ subject: Subject) {
        if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
            subjects[index] = subject
            saveSubjects()
        }
    }
    
    func deleteSubject(_ subject: Subject) {
        subjects.removeAll { $0.id == subject.id }
        saveSubjects()
    }
    
    func deleteSubject(at indexSet: IndexSet) {
        subjects.remove(atOffsets: indexSet)
        saveSubjects()
    }
    
    func getSubjects(for dayOfWeek: Int, period: Int? = nil) -> [Subject] {
        if let period = period {
            return subjects.filter { $0.dayOfWeek == dayOfWeek && $0.period == period }
        }
        return subjects.filter { $0.dayOfWeek == dayOfWeek }
    }
    
    // MARK: - Persistence
    
    private func saveSubjects() {
        if let encoded = try? JSONEncoder().encode(subjects) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSubjects() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Subject].self, from: data) {
            subjects = decoded
        }
    }
}
