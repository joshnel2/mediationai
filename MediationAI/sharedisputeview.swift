//
//  ShareDisputeView.swift
//  meidationaiapp
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct ShareDisputeView: View {
    @Environment(\.dismiss) var dismiss
    let dispute: Dispute
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "link")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(AppTheme.mainGradient)
                .padding()
                .background(AppTheme.card)
                .clipShape(Circle())
                .shadow(radius: 8)
            
            Text("Share this code with the other party:")
                .font(AppTheme.subtitleFont())
                .multilineTextAlignment(.center)
            
            Text(dispute.shareCode)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primary)
                .padding()
                .background(AppTheme.card)
                .cornerRadius(16)
                .shadow(radius: 4)
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = dispute.shareCode
                    } label: {
                        Label("Copy Code", systemImage: "doc.on.doc")
                    }
                }
            
            Text("They can join the dispute by entering this code after signing up.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            Button("Done") { dismiss() }
                .font(AppTheme.buttonFont())
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.mainGradient)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
    }
}
