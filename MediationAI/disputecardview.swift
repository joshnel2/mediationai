//
//  DisputeCardView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct DisputeCardView: View {
    let dispute: Dispute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dispute.title)
                .font(AppTheme.subtitleFont())
                .foregroundColor(AppTheme.primary)
            Text(dispute.description)
                .font(AppTheme.bodyFont())
                .foregroundColor(.gray)
                .lineLimit(2)
            HStack {
                Text("Status: \(dispute.isResolved ? "Resolved" : "Open")")
                    .font(.caption)
                    .foregroundColor(dispute.isResolved ? .green : .orange)
                Spacer()
                Text("Code: \(dispute.shareCode)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(radius: 3)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
