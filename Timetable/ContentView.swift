//
//  ContentView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimetableViewModel()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showingVisibilitySettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header row with day names
                    HStack(spacing: 0) {
                        // Empty cell for period column
                        if !viewModel.isPeriodColumnHidden {
                            Text("period".localized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 60)
                                .padding(.vertical, 8)
                        }
                        
                        ForEach(viewModel.visibleDays, id: \.self) { day in
                            Text(viewModel.getDayName(for: day))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                                .onLongPressGesture {
                                    withAnimation {
                                        viewModel.toggleDayVisibility(day)
                                    }
                                }
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    
                    // Grid rows for each period
                    ForEach(viewModel.visiblePeriods, id: \.self) { period in
                        HStack(spacing: 0) {
                            // Period indicator
                            if !viewModel.isPeriodColumnHidden {
                                Text("\(period)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .onLongPressGesture {
                                        withAnimation {
                                            viewModel.togglePeriodVisibility(period)
                                        }
                                    }
                            }
                            
                            // Day cells
                            ForEach(viewModel.visibleDays, id: \.self) { day in
                                let subjectsForCell = viewModel.getSubjects(for: day, period: period)
                                
                                if subjectsForCell.isEmpty {
                                    TimetableCell()
                                        .frame(height: 60)
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 1)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.addSubjectForDay(day, period: period)
                                            }
                                        }
                                } else {
                                    VStack(spacing: 2) {
                                        ForEach(subjectsForCell) { subject in
                                            TimetableCell(subject: subject)
                                                .frame(height: 60)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        viewModel.selectSubject(subject)
                                                    }
                                                }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 2)
                                    .padding(.vertical, 1)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: subjectsForCell.count)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Empty cells for subjects without period
                    let subjectsWithoutPeriod = viewModel.subjectsWithoutPeriod
                    if !subjectsWithoutPeriod.isEmpty {
                        HStack(spacing: 0) {
                            if !viewModel.isPeriodColumnHidden {
                                Text("other".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 60)
                                    .padding(.vertical, 4)
                            }
                            
                            ForEach(viewModel.visibleDays, id: \.self) { day in
                                let subjectsForDay = subjectsWithoutPeriod.filter { $0.dayOfWeek == day }
                                
                                VStack(spacing: 2) {
                                    ForEach(subjectsForDay) { subject in
                                        TimetableCell(subject: subject)
                                            .frame(height: 60)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    viewModel.selectSubject(subject)
                                                }
                                            }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 1)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: subjectsForDay.count)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("timetable".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingVisibilitySettings = true
                    } label: {
                        Image(systemName: "eye.slash")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showAddSubject()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingVisibilitySettings) {
                VisibilitySettingsView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingAddSubject) {
                SubjectEditView(
                    scheduleStore: viewModel.store,
                    initialDay: viewModel.initialDayForNewSubject,
                    initialPeriod: viewModel.initialPeriodForNewSubject
                )
                .onDisappear {
                    viewModel.dismissAddSubject()
                }
            }
            .sheet(item: $viewModel.selectedSubject) { subject in
                SubjectEditView(
                    scheduleStore: viewModel.store,
                    subject: subject
                )
                .onDisappear {
                    viewModel.dismissEditSubject()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
