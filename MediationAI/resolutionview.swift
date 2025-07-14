//
//  ResolutionView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct ResolutionView: View {
    let resolution: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "brain")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(AppTheme.mainGradient)
                            .padding()
                            .background(AppTheme.card)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                        
                        VStack(spacing: 8) {
                            Text("🤖 Grok AI Resolution")
                                .font(AppTheme.titleFont())
                                .foregroundColor(AppTheme.primary)
                            
                            Text("AI-powered mediation analysis complete")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top)
                    
                    // Resolution content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(resolution)
                            .font(AppTheme.bodyFont())
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button("Share Resolution") {
                            // Share functionality could be added here
                        }
                        .font(AppTheme.buttonFont())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.secondary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        
                        Button("Done") { dismiss() }
                            .font(AppTheme.buttonFont())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.mainGradient)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Resolution")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Resolution Card View for Dispute Room

struct ResolutionCardView: View {
    let resolution: String
    @State private var showFullResolution = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🤖 AI Resolution Complete")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Grok AI has analyzed both submissions")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Text(resolution.prefix(200) + (resolution.count > 200 ? "..." : ""))
                .font(AppTheme.bodyFont())
                .foregroundColor(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Button("View Full Resolution") {
                showFullResolution = true
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.top, 4)
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.horizontal)
        .sheet(isPresented: $showFullResolution) {
            ResolutionView(resolution: resolution)
        }
    }
}
