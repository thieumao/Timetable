//
//  ContentView.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = ScheduleStore()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showingAddSubject = false
    @State private var selectedSubject: Subject?
    @State private var initialDayForNewSubject: Int?
    @State private var initialPeriodForNewSubject: Int?
    
    let maxPeriods = 12
    
    var daysOfWeek: [String] {
        [
            "monday_short".localized,
            "tuesday_short".localized,
            "wednesday_short".localized,
            "thursday_short".localized,
            "friday_short".localized,
            "saturday_short".localized,
            "sunday_short".localized
        ]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header row with day names
                    HStack(spacing: 0) {
                        // Empty cell for period column
                        Text("period".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                            .padding(.vertical, 8)
                        
                        ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }
                    .background(Color.gray.opacity(0.1))
                    
                    // Grid rows for each period
                    ForEach(1...maxPeriods, id: \.self) { period in
                        HStack(spacing: 0) {
                            // Period indicator
                            Text("\(period)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60)
                                .padding(.vertical, 4)
                            
                            // Day cells
                            ForEach(1...7, id: \.self) { day in
                                let subjectsForCell = store.getSubjects(for: day, period: period)
                                
                                if subjectsForCell.isEmpty {
                                    TimetableCell()
                                        .frame(height: 60)
                                        .padding(.horizontal, 2)
                                        .padding(.vertical, 1)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                addSubjectForDay(day, period: period)
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
                                                        selectedSubject = subject
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
                    let subjectsWithoutPeriod = store.subjects.filter { $0.period == nil }
                    if !subjectsWithoutPeriod.isEmpty {
                        HStack(spacing: 0) {
                            Text("other".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60)
                                .padding(.vertical, 4)
                            
                            ForEach(1...7, id: \.self) { day in
                                let subjectsForDay = subjectsWithoutPeriod.filter { $0.dayOfWeek == day }
                                
                                VStack(spacing: 2) {
                                    ForEach(subjectsForDay) { subject in
                                        TimetableCell(subject: subject)
                                            .frame(height: 60)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedSubject = subject
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSubject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                SubjectEditView(
                    store: store,
                    initialDay: initialDayForNewSubject,
                    initialPeriod: initialPeriodForNewSubject
                )
                .onDisappear {
                    initialDayForNewSubject = nil
                    initialPeriodForNewSubject = nil
                }
            }
            .sheet(item: $selectedSubject) { subject in
                SubjectEditView(store: store, subject: subject)
            }
        }
    }
    
    private func addSubjectForDay(_ day: Int, period: Int) {
        initialDayForNewSubject = day
        initialPeriodForNewSubject = period
        showingAddSubject = true
    }
}

#Preview {
    ContentView()
}
