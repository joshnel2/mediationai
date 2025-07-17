//
//  ResolutionView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct ResolutionView: View {
    let resolution: Resolution
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
                            .background(AppTheme.cardGradient)
                            .clipShape(Circle())
                            .shadow(radius: 8)
                        
                        VStack(spacing: 8) {
                            Text("🤖 AI Resolution")
                                .font(AppTheme.title())
                                .foregroundColor(AppTheme.primary)
                            
                            Text(resolution.summary)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.top)
                    
                    // Resolution content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(resolution.decision)
                            .font(AppTheme.body())
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(AppTheme.cardGradient)
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
            .onAppear {
                // Configure navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
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
    let resolution: Resolution
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
                        .foregroundColor(AppTheme.success)
                    
                    Text(resolution.summary)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            
            Text(resolution.decision.prefix(200) + (resolution.decision.count > 200 ? "..." : ""))
                .font(AppTheme.body())
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Button("View Full Resolution") {
                showFullResolution = true
            }
            .font(.caption)
            .foregroundColor(AppTheme.primary)
            .padding(.top, 4)
        }
        .padding()
        .background(AppTheme.cardGradient)
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.horizontal)
        .sheet(isPresented: $showFullResolution) {
            ResolutionView(resolution: resolution)
        }
    }
}
