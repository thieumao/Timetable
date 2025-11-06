//
//  SubjectEditView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct SubjectEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: ScheduleStore
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var name: String
    @State private var dayOfWeek: Int
    @State private var period: Int?
    @State private var customTime: String
    @State private var selectedColor: SubjectColor
    @State private var useCustomTime: Bool
    
    let subjectToEdit: Subject?
    let initialDay: Int?
    let initialPeriod: Int?
    
    init(store: ScheduleStore, subject: Subject? = nil, initialDay: Int? = nil, initialPeriod: Int? = nil) {
        self.store = store
        self.subjectToEdit = subject
        self.initialDay = initialDay
        self.initialPeriod = initialPeriod
        
        _name = State(initialValue: subject?.name ?? "")
        _dayOfWeek = State(initialValue: subject?.dayOfWeek ?? initialDay ?? 1)
        _period = State(initialValue: subject?.period ?? initialPeriod)
        _customTime = State(initialValue: subject?.customTime ?? "")
        _selectedColor = State(initialValue: subject?.color ?? .blue)
        _useCustomTime = State(initialValue: subject?.customTime != nil && !subject!.customTime!.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("subject_info".localized)) {
                    TextField("subject_name".localized, text: $name)
                    
                    Picker("day".localized, selection: $dayOfWeek) {
                        Text("monday".localized).tag(1)
                        Text("tuesday".localized).tag(2)
                        Text("wednesday".localized).tag(3)
                        Text("thursday".localized).tag(4)
                        Text("friday".localized).tag(5)
                        Text("saturday".localized).tag(6)
                        Text("sunday".localized).tag(7)
                    }
                }
                
                Section(header: Text("time".localized)) {
                    Toggle("use_custom_time".localized, isOn: $useCustomTime)
                    
                    if useCustomTime {
                        TextField("custom_time_placeholder".localized, text: $customTime)
                            .keyboardType(.default)
                    } else {
                        Stepper(value: Binding(
                            get: { period ?? 1 },
                            set: { period = $0 }
                        ), in: 1...12) {
                            Text("period_label".localized.replacingOccurrences(of: "%d", with: "\(period ?? 1)"))
                        }
                    }
                }
                
                Section(header: Text("color".localized)) {
                    Picker("color".localized, selection: $selectedColor) {
                        ForEach(SubjectColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.displayName)
                            }
                            .tag(color)
                        }
                    }
                }
                
                if subjectToEdit != nil {
                    Section {
                        Button(role: .destructive) {
                            if let subject = subjectToEdit {
                                store.deleteSubject(subject)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("delete_subject".localized)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(subjectToEdit == nil ? "add_subject".localized : "edit_subject".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        saveSubject()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: useCustomTime)
        }
    }
    
    private func saveSubject() {
        let subject = Subject(
            id: subjectToEdit?.id ?? UUID(),
            name: name,
            dayOfWeek: dayOfWeek,
            period: useCustomTime ? nil : period,
            customTime: useCustomTime && !customTime.isEmpty ? customTime : nil,
            color: selectedColor
        )
        
        if subjectToEdit != nil {
            store.updateSubject(subject)
        } else {
            store.addSubject(subject)
        }
        
        dismiss()
    }
}
