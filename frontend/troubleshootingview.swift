//
//  TroubleshootingView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct TroubleshootingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Troubleshooting")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.bottom, 10)
                        
                        Text("Common Issues & Solutions")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            TroubleshootingSection(
                                icon: "exclamationmark.triangle.fill",
                                title: "Dispute Not Progressing",
                                problem: "Your dispute seems stuck or the other party isn't responding.",
                                solution: """
                                • Check if the other party has been properly notified via email
                                • Resend the dispute invitation through the app
                                • Ensure all required information has been provided
                                • Contact support if no response after 48 hours
                                • Consider escalating to traditional mediation if needed
                                """
                            )
                            
                            TroubleshootingSection(
                                icon: "doc.badge.exclamationmark",
                                title: "Evidence Upload Issues",
                                problem: "Unable to upload documents or evidence files.",
                                solution: """
                                • Check file size limits (max 10MB per file)
                                • Ensure files are in supported formats (PDF, JPG, PNG, DOC)
                                • Verify stable internet connection
                                • Try uploading one file at a time
                                • Clear app cache and restart if problems persist
                                """
                            )
                            
                            TroubleshootingSection(
                                icon: "signature",
                                title: "Digital Signature Problems",
                                problem: "Digital signature not working or being rejected.",
                                solution: """
                                • Ensure you're using the correct signing method
                                • Check that all required fields are completed
                                • Verify your identity information matches your account
                                • Try signing in a different browser or device
                                • Contact support for signature verification issues
                                """
                            )
                            
                            TroubleshootingSection(
                                icon: "creditcard.trianglebadge.exclamationmark",
                                title: "Payment & Escrow Issues",
                                problem: "Problems with escrow payments or fund releases.",
                                solution: """
                                • Verify your payment method is valid and has sufficient funds
                                • Check that all dispute conditions have been met
                                • Ensure both parties have agreed to resolution terms
                                • Review escrow release conditions in your contract
                                • Contact financial support for payment processing issues
                                """
                            )
                            
                            TroubleshootingSection(
                                icon: "brain.head.profile.fill",
                                title: "AI Recommendation Issues",
                                problem: "AI recommendations seem unfair or incomplete.",
                                solution: """
                                • Provide additional evidence or clarification
                                • Ensure all relevant information has been submitted
                                • Review the AI's reasoning and explanation
                                • Request a review through the appeals process
                                • Consider human mediation for complex cases
                                """
                            )
                            
                            TroubleshootingSection(
                                icon: "bell.slash.fill",
                                title: "Missing Notifications",
                                problem: "Not receiving important dispute notifications.",
                                solution: """
                                • Check your notification settings in the app
                                • Verify your email address is correct and verified
                                • Check spam/junk folders for MediationAI emails
                                • Ensure push notifications are enabled in device settings
                                • Update your contact preferences in account settings
                                """
                            )
                        }
                        
                        // Emergency Contact
                        VStack(alignment: .center, spacing: 12) {
                            Text("Still Need Help?")
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                                .fontWeight(.semibold)
                            
                            Text("Contact our support team 24/7 for immediate assistance with urgent disputes or technical issues.")
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                // Open support contact
                            }) {
                                Text("Contact Support")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppTheme.primary)
                                    .cornerRadius(AppTheme.radiusLG)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardGradient)
                        .cornerRadius(AppTheme.radiusLG)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                                .stroke(AppTheme.glassPrimary, lineWidth: 1)
                        )
                        
                        // Footer
                        VStack(alignment: .center, spacing: 8) {
                            Text("Most issues can be resolved quickly with these solutions.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("MediationAI Troubleshooting Guide 2025")
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

struct TroubleshootingSection: View {
    let icon: String
    let title: String
    let problem: String
    let solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.warning)
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Problem:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(problem)
                    .font(.body)
                    .foregroundColor(AppTheme.textPrimary)
                    .italic()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Solution:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.success)
                
                Text(solution)
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

struct TroubleshootingView_Previews: PreviewProvider {
    static var previews: some View {
        TroubleshootingView()
    }
}