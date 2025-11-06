//
//  PeriodSettingsView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct PeriodSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var periodStore: PeriodStore
    @State private var showingAddPeriod = false
    @State private var editingPeriod: Period?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("period_settings".localized)) {
                    if periodStore.periods.isEmpty {
                        Text("no_periods".localized)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(periodStore.periods) { period in
                            PeriodRow(period: period) {
                                editingPeriod = period
                            }
                        }
                        .onDelete { indexSet in
                            periodStore.deletePeriod(at: indexSet)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddPeriod = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add_period".localized)
                        }
                    }
                }
            }
            .navigationTitle("period_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPeriod) {
                PeriodEditView(periodStore: periodStore)
            }
            .sheet(item: $editingPeriod) { period in
                PeriodEditView(periodStore: periodStore, period: period)
            }
        }
    }
}

struct PeriodRow: View {
    let period: Period
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("period_format".localized.replacingOccurrences(of: "%d", with: "\(period.number)"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(period.timeDisplay)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PeriodEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var periodStore: PeriodStore
    
    @State private var periodNumber: Int
    @State private var startTime: String
    @State private var endTime: String
    
    let isEditing: Bool
    let periodId: UUID?
    
    init(periodStore: PeriodStore, period: Period? = nil) {
        self.periodStore = periodStore
        
        if let period = period {
            self.isEditing = true
            self.periodId = period.id
            self._periodNumber = State(initialValue: period.number)
            self._startTime = State(initialValue: period.startTime)
            self._endTime = State(initialValue: period.endTime)
        } else {
            self.isEditing = false
            self.periodId = nil
            self._periodNumber = State(initialValue: periodStore.getNextPeriodNumber())
            self._startTime = State(initialValue: "7:00")
            self._endTime = State(initialValue: "7:45")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("period_info".localized)) {
                    Stepper(value: $periodNumber, in: 1...20) {
                        HStack {
                            Text("period_number".localized)
                            Spacer()
                            Text("\(periodNumber)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("start_time".localized)
                        Spacer()
                        TextField("7:00", text: $startTime)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("end_time".localized)
                        Spacer()
                        TextField("7:45", text: $endTime)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive, action: {
                            if let periodId = periodId,
                               let period = periodStore.periods.first(where: { $0.id == periodId }) {
                                periodStore.deletePeriod(period)
                            }
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text("delete_period".localized)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "edit_period".localized : "add_period".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        savePeriod()
                    }
                    .disabled(startTime.isEmpty || endTime.isEmpty)
                }
            }
        }
    }
    
    private func savePeriod() {
        if isEditing, let periodId = periodId {
            if let existingPeriod = periodStore.periods.first(where: { $0.id == periodId }) {
                let updatedPeriod = Period(
                    id: periodId,
                    number: periodNumber,
                    startTime: startTime,
                    endTime: endTime
                )
                periodStore.updatePeriod(updatedPeriod)
            }
        } else {
            let newPeriod = Period(
                number: periodNumber,
                startTime: startTime,
                endTime: endTime
            )
            periodStore.addPeriod(newPeriod)
        }
        dismiss()
    }
}

