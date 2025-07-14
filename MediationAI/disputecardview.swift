//
//  DisputeCardView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct DisputeCardView: View {
    let dispute: Dispute
    
    private var statusColor: Color {
        switch dispute.status {
        case .inviteSent: return AppTheme.warning
        case .inProgress: return AppTheme.info
        case .resolved: return AppTheme.success
        }
    }
    
    private var statusIcon: String {
        switch dispute.status {
        case .inviteSent: return "paperplane.fill"
        case .inProgress: return "clock.fill"
        case .resolved: return "checkmark.seal.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
            // Header with status
            HStack {
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: statusIcon)
                        .font(.caption)
                        .foregroundColor(statusColor)
                    
                    Text(dispute.status.rawValue)
                        .font(AppTheme.caption())
                        .fontWeight(.medium)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingSM)
                .background(statusColor.opacity(0.1))
                .cornerRadius(AppTheme.radiusSM)
                
                Spacer()
                
                Text(dispute.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.caption2())
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text(dispute.title)
                    .font(AppTheme.title3())
                    .foregroundColor(AppTheme.textPrimary)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(dispute.description)
                    .font(AppTheme.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            // Footer
            HStack {
                HStack(spacing: AppTheme.spacingSM) {
                    Image(systemName: "person.2.fill")
                        .font(.caption2)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text(dispute.partyB != nil ? "Both parties joined" : "Waiting for other party")
                        .font(AppTheme.caption2())
                        .foregroundColor(AppTheme.textTertiary)
                }
                
                Spacer()
                
                if dispute.isResolved {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption2)
                            .foregroundColor(AppTheme.success)
                        
                        Text("AI Resolved")
                            .font(AppTheme.caption2())
                            .foregroundColor(AppTheme.success)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .glassCard()
    }
}
