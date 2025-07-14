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
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(isMe ? "You" : user.email)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                if let truth = truth {
                    Text(truth.text)
                        .font(AppTheme.chatFont())
                        .foregroundColor(.primary)
                        .padding()
                        .background(isMe ? AppTheme.mainGradient : AppTheme.card)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    if !truth.attachments.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(truth.attachments) { att in
                                    AttachmentPreview(attachment: att)
                                }
                            }
                        }
                    }
                } else {
                    Text("No truth submitted yet.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: 260, alignment: .leading)
            if !isMe { Spacer() }
        }
        .padding(.vertical, 4)
    }
}
