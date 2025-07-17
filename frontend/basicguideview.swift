//
//  BasicGuideView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct BasicGuideView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Getting Started")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.bottom, 10)
                        
                        Text("Your Guide to AI Dispute Resolution")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            GuideSection(
                                icon: "1.circle.fill",
                                title: "Create Your Account",
                                content: """
                                Start by creating your MediationAI account with a secure email and password. Your account keeps track of all your disputes and provides access to our AI mediation services.
                                
                                • Use a valid email address for important notifications
                                • Choose a strong password for account security
                                • Verify your email to activate full features
                                """
                            )
                            
                            GuideSection(
                                icon: "2.circle.fill",
                                title: "Understanding Disputes",
                                content: """
                                MediationAI helps resolve various types of disputes quickly and fairly:
                                
                                • Business contract disagreements
                                • Service delivery issues
                                • Payment and refund disputes
                                • Property and rental conflicts
                                • Partnership disagreements
                                
                                Our AI analyzes each situation and provides neutral recommendations.
                                """
                            )
                            
                            GuideSection(
                                icon: "3.circle.fill",
                                title: "Creating a Dispute",
                                content: """
                                To start a new dispute resolution:
                                
                                • Tap "Create Dispute" from the home screen
                                • Provide clear details about the issue
                                • Upload relevant documents or evidence
                                • Set the dispute amount (if applicable)
                                • Invite the other party to participate
                                
                                The more details you provide, the better our AI can help.
                                """
                            )
                            
                            GuideSection(
                                icon: "4.circle.fill",
                                title: "The AI Resolution Process",
                                content: """
                                Our AI analyzes your dispute using advanced algorithms:
                                
                                • Reviews all submitted evidence and documentation
                                • Considers legal precedents and mediation principles
                                • Evaluates both parties' positions objectively
                                • Generates fair and balanced recommendations
                                • Provides clear reasoning for all decisions
                                
                                The process typically takes 24-48 hours for completion.
                                """
                            )
                        }
                        
                        // Footer
                        VStack(alignment: .center, spacing: 8) {
                            Text("Need more help? Contact our support team anytime.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("MediationAI User Guide 2025")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                                .padding(.top, AppTheme.spacingXL)
                                .padding(.bottom, 100)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { 
                        dismiss() 
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
            .onAppear {
                // Configure navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.clear
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct GuideSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.primary)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppTheme.cardGradient)
        .cornerRadius(AppTheme.radiusLG)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                .stroke(AppTheme.glassPrimary, lineWidth: 1)
        )
    }
}

struct BasicGuideView_Previews: PreviewProvider {
    static var previews: some View {
        BasicGuideView()
    }
}