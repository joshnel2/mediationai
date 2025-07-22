//
//  PrivacyPolicyView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import UIKit

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.primary)
                        .padding(.bottom, 10)
                    
                    Text("Last Updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PolicySection(
                            title: "1. Information We Collect",
                            content: """
                            • Email address for account creation and authentication
                            • Dispute information and submitted evidence
                            • Payment transaction data (processed securely through Apple)
                            • App usage analytics and crash reports
                            • Device information for app functionality and support
                            """
                        )
                        
                        PolicySection(
                            title: "2. How We Use Your Information",
                            content: """
                            • Provide AI-powered dispute mediation services
                            • Process payments for dispute creation and participation
                            • Send important updates about your disputes
                            • Improve our AI algorithms and app functionality
                            • Comply with legal obligations and resolve disputes
                            • Prevent fraud and ensure platform security
                            """
                        )
                        
                        PolicySection(
                            title: "3. Information Sharing",
                            content: """
                            We do not sell, trade, or rent your personal information. We may share information only:
                            
                            • With other parties in your dispute (dispute content only)
                            • With service providers who assist in app operations
                            • When required by law or legal process
                            • To protect our rights and prevent illegal activity
                            • In connection with a business transfer or acquisition
                            """
                        )
                        
                        PolicySection(
                            title: "4. Data Security",
                            content: """
                            • All data is encrypted in transit and at rest
                            • Payment processing is handled securely by Apple
                            • Regular security audits and monitoring
                            • Access controls and authentication required
                            • Data backup and recovery procedures in place
                            """
                        )
                        
                        PolicySection(
                            title: "5. AI Processing",
                            content: """
                            • Dispute content is processed by our AI system for mediation
                            • AI processing occurs on secure servers
                            • No human review of dispute content unless required for safety
                            • AI models are continuously improved while maintaining privacy
                            """
                        )
                        
                        PolicySection(
                            title: "6. Your Rights",
                            content: """
                            You have the right to:
                            • Access your personal information
                            • Correct inaccurate information
                            • Delete your account and associated data
                            • Export your dispute history
                            • Opt out of non-essential communications
                            • Withdraw consent where applicable
                            """
                        )
                        
                        PolicySection(
                            title: "7. Data Retention",
                            content: """
                            • Account information: Retained while account is active
                            • Dispute records: Retained for 7 years for legal compliance
                            • Payment records: Retained as required by financial regulations
                            • Analytics data: Anonymized and retained for app improvement
                            """
                        )
                        
                        PolicySection(
                            title: "8. Children's Privacy",
                            content: """
                            MediationAI is not intended for users under 18 years of age. We do not knowingly collect personal information from children under 18. If we become aware that we have collected such information, we will delete it immediately.
                            """
                        )
                        
                        PolicySection(
                            title: "9. International Users",
                            content: """
                            MediationAI is operated from the United States. By using our service, you consent to the transfer and processing of your information in the United States, which may have different privacy laws than your country of residence.
                            """
                        )
                        
                        PolicySection(
                            title: "10. Changes to This Policy",
                            content: """
                            We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the "Last Updated" date. Your continued use constitutes acceptance of the updated policy.
                            """
                        )
                        
                        PolicySection(
                            title: "11. Contact Us",
                            content: """
                            If you have questions about this Privacy Policy or our data practices, please contact us at:
                            
                            Email: privacy@mediationai.app
                            Address: [Your Business Address]
                            Phone: [Your Phone Number]
                            
                            We will respond to your inquiry within 30 days.
                            """
                        )
                    }
                    
                    // Footer
                    Text("Decentralized Technology Solutions 2025")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary.opacity(0.7))
                        .padding(.top, AppTheme.spacingXL)
                        .padding(.bottom, 100)
                }
                .padding()
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
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
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
        .padding()
        .background(AppTheme.card)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}