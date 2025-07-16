//
//  TruthBubble.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct TruthBubble: View {
    let user: User
    let truth: Truth?
    let isMe: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            if isMe { Spacer() }
            
            VStack(alignment: isMe ? .trailing : .leading, spacing: 8) {
                // User label
                HStack {
                    if !isMe {
                        Text(user.email.components(separatedBy: "@").first ?? user.email)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        Spacer()
                        Text("You")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    }
                }
                
                if let truth = truth {
                    VStack(alignment: isMe ? .trailing : .leading, spacing: 6) {
                        // Truth text
                        Text(truth.text)
                            .font(AppTheme.chatFont())
                            .foregroundColor(isMe ? .white : AppTheme.textPrimary)
                            .padding()
                            .background(isMe ? AppTheme.mainGradient : AppTheme.cardGradient)
                            .cornerRadius(16)
                            .shadow(radius: 2)
                        
                        // Attachments
                        if !truth.attachments.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(truth.attachments) { att in
                                        AttachmentPreview(attachment: att)
                                    }
                                }
                            }
                        }
                        
                        // Timestamp
                        Text("Submitted \(truth.submittedAt.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(alignment: isMe ? .trailing : .leading, spacing: 6) {
                        Text("Waiting for truth submission...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                            .padding()
                            .background(AppTheme.card.opacity(0.5))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    }
                }
            }
            .frame(maxWidth: 280, alignment: isMe ? .trailing : .leading)
            
            if !isMe { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
