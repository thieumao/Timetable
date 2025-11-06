//
//  VisibilitySettingsView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct VisibilitySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TimetableViewModel
    @State private var showingPeriodSettings = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("period".localized)) {
                    Toggle(isOn: Binding(
                        get: { !viewModel.isPeriodColumnHidden },
                        set: { _ in
                            withAnimation {
                                viewModel.isPeriodColumnHidden.toggle()
                            }
                        }
                    )) {
                        Text("period".localized)
                    }
                    
                    Toggle(isOn: Binding(
                        get: { viewModel.showPeriodLabel },
                        set: { _ in
                            withAnimation {
                                viewModel.showPeriodLabel.toggle()
                            }
                        }
                    )) {
                        Text("show_period_label".localized)
                    }
                    
                    Button(action: {
                        showingPeriodSettings = true
                    }) {
                        HStack {
                            Text("manage_periods".localized)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("visibility_settings".localized)) {
                    // Days visibility
                    ForEach(1...7, id: \.self) { day in
                        Toggle(isOn: Binding(
                            get: { !viewModel.isDayHidden(day) },
                            set: { _ in
                                withAnimation {
                                    viewModel.toggleDayVisibility(day)
                                }
                            }
                        )) {
                            Text(viewModel.getDayName(for: day))
                        }
                    }
                }
                
                Section(header: Text("period".localized)) {
                    // Periods visibility
                    ForEach(viewModel.periodStore.periods, id: \.id) { period in
                        Toggle(isOn: Binding(
                            get: { !viewModel.isPeriodHidden(period.number) },
                            set: { _ in
                                withAnimation {
                                    viewModel.togglePeriodVisibility(period.number)
                                }
                            }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("period_format".localized.replacingOccurrences(of: "%d", with: "\(period.number)"))
                                Text(period.timeDisplay)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("visibility_settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPeriodSettings) {
                PeriodSettingsView(periodStore: viewModel.periodStore)
            }
        }
    }
}
