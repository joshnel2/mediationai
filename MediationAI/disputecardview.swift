//
//  DisputeCardView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct DisputeCardView: View {
    let dispute: Dispute
    
    var statusColor: Color {
        switch dispute.status {
        case .inviteSent:
            return .orange
        case .inProgress:
            return .blue
        case .resolved:
            return .green
        }
    }
    
    var statusIcon: String {
        switch dispute.status {
        case .inviteSent:
            return "paperplane"
        case .inProgress:
            return "clock"
        case .resolved:
            return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and status
            HStack {
                Text(dispute.title)
                    .font(AppTheme.subtitleFont())
                    .foregroundColor(AppTheme.primary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Text(dispute.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Description
            Text(dispute.description)
                .font(AppTheme.bodyFont())
                .foregroundColor(.gray)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Footer with additional info
            HStack {
                // Participants info
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if dispute.partyB != nil {
                        Text("Both parties joined")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        Text("Waiting for other party")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Date
                Text(dispute.createdAt.formatted(date: .abbreviated, time: .omitted))
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
