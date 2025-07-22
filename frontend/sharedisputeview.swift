//
//  ShareDisputeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import UIKit

struct ShareDisputeView: View {
    @Environment(\.dismiss) var dismiss
    let dispute: Dispute
    @State private var showingShareSheet = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(AppTheme.mainGradient)
                .padding()
                .background(AppTheme.card)
                .clipShape(Circle())
                .shadow(radius: 8)
            
            VStack(spacing: 16) {
                Text("Dispute Created Successfully! 🎉")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                    .multilineTextAlignment(.center)
                
                Text("Share this link with the other party:")
                    .font(AppTheme.subtitleFont())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Text(dispute.shareLink)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.primary)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = dispute.shareLink
                        } label: {
                            Label("Copy Link", systemImage: "doc.on.doc")
                        }
                    }
                
                HStack(spacing: 16) {
                    Button(action: copyLink) {
                        Label("Copy Link", systemImage: "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: shareLink) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.mainGradient)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("The other party can join for FREE.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Text("You'll be notified when they join and can start submitting evidence.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
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
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: [dispute.shareLink])
        }
    }
    
    private func copyLink() {
        UIPasteboard.general.string = dispute.shareLink
        // You could add a toast notification here
    }
    
    private func shareLink() {
        showingShareSheet = true
    }
}

// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
