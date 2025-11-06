//
//  SubjectEditView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct SubjectEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: SubjectEditViewModel
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(scheduleStore: ScheduleStore, subject: Subject? = nil, initialDay: Int? = nil, initialPeriod: Int? = nil) {
        _viewModel = StateObject(wrappedValue: SubjectEditViewModel(
            scheduleStore: scheduleStore,
            subject: subject,
            initialDay: initialDay,
            initialPeriod: initialPeriod
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("subject_info".localized)) {
                    TextField("subject_name".localized, text: $viewModel.name)
                    
                    Picker("day".localized, selection: $viewModel.dayOfWeek) {
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
                    Toggle("use_custom_time".localized, isOn: $viewModel.useCustomTime)
                    
                    if viewModel.useCustomTime {
                        TextField("custom_time_placeholder".localized, text: $viewModel.customTime)
                            .keyboardType(.default)
                    } else {
                        Stepper(value: Binding(
                            get: { viewModel.period ?? 1 },
                            set: { viewModel.period = $0 }
                        ), in: 1...12) {
                            Text("period_label".localized.replacingOccurrences(of: "%d", with: "\(viewModel.period ?? 1)"))
                        }
                    }
                }
                
                Section(header: Text("color".localized)) {
                    Picker("color".localized, selection: $viewModel.selectedColor) {
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
                
                if viewModel.isEditMode {
                    Section {
                        Button(role: .destructive) {
                            viewModel.deleteSubject()
                            dismiss()
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
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        viewModel.saveSubject()
                        dismiss()
                    }
                    .disabled(!viewModel.isSaveEnabled)
                    .fontWeight(.semibold)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.useCustomTime)
        }
    }
}
