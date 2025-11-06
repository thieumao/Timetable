//
//  TimetableCell.swift
//  Timetable
//
//  Created by Thieu on 11/6/25.
//

import SwiftUI

struct TimetableCell: View {
    let subject: Subject?
    let isEmpty: Bool
    let showPeriodLabel: Bool
    
    init(subject: Subject? = nil, showPeriodLabel: Bool = false) {
        self.subject = subject
        self.isEmpty = subject == nil
        self.showPeriodLabel = showPeriodLabel
    }
    
    var body: some View {
        if let subject = subject {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Show custom time if available, or period label if enabled
                if let customTime = subject.customTime, !customTime.isEmpty {
                    Text(customTime)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.9))
                } else if showPeriodLabel, let period = subject.period {
                    Text("period_format".localized.replacingOccurrences(of: "%d", with: "\(period)"))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(subject.color.color)
            )
            .shadow(color: subject.color.color.opacity(0.3), radius: 3, x: 0, y: 2)
            .transition(.scale.combined(with: .opacity))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.08))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray.opacity(0.4))
                )
        }
    }
}
