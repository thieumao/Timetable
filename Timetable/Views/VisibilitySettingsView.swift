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
                    ForEach(1...viewModel.maxPeriods, id: \.self) { period in
                        Toggle(isOn: Binding(
                            get: { !viewModel.isPeriodHidden(period) },
                            set: { _ in
                                withAnimation {
                                    viewModel.togglePeriodVisibility(period)
                                }
                            }
                        )) {
                            Text("period_format".localized.replacingOccurrences(of: "%d", with: "\(period)"))
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
        }
    }
}
