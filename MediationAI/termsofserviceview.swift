//
//  TermsOfServiceView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
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
                            title: "1. Acceptance of Terms",
                            content: """
                            By downloading, installing, or using MediationAI, you agree to be bound by these Terms of Service and our Privacy Policy. If you do not agree to these terms, do not use our service.
                            
                            These terms constitute a legally binding agreement between you and MediationAI.
                            """
                        )
                        
                        PolicySection(
                            title: "2. Service Description",
                            content: """
                            MediationAI is an AI-powered dispute resolution platform that:
                            • Facilitates communication between disputing parties
                            • Provides AI-generated mediation recommendations
                            • Processes secure payments for platform usage
                            • Maintains records of dispute proceedings
                            
                            Our service is not a replacement for legal counsel or formal arbitration.
                            """
                        )
                        
                        PolicySection(
                            title: "3. Eligibility and Account Registration",
                            content: """
                            • You must be at least 18 years old to use MediationAI
                            • You must provide accurate and complete registration information
                            • You are responsible for maintaining your account security
                            • One account per person; multiple accounts are prohibited
                            • You may not transfer your account to another person
                            """
                        )
                        
                        PolicySection(
                            title: "4. Payment Terms",
                            content: """
                            • $1.00 fee to create a dispute
                            • $1.00 fee to join a dispute
                            • All payments are processed through Apple's payment system
                            • Fees are non-refundable except as required by law
                            • You authorize us to charge your selected payment method
                            • Price changes will be communicated in advance
                            """
                        )
                        
                        PolicySection(
                            title: "5. Dispute Resolution Process",
                            content: """
                            • Disputes must be legitimate and submitted in good faith
                            • Both parties must submit their evidence and statements
                            • AI analysis is automated and final
                            • Resolution recommendations are non-binding suggestions
                            • MediationAI does not guarantee specific outcomes
                            • Parties may pursue other legal remedies if desired
                            """
                        )
                        
                        PolicySection(
                            title: "6. Prohibited Uses",
                            content: """
                            You may not use MediationAI to:
                            • Submit false, misleading, or fraudulent disputes
                            • Harass, threaten, or abuse other users
                            • Upload illegal, defamatory, or inappropriate content
                            • Attempt to manipulate or game the AI system
                            • Violate any applicable laws or regulations
                            • Interfere with the platform's operation
                            """
                        )
                        
                        PolicySection(
                            title: "7. Content and Intellectual Property",
                            content: """
                            • You retain ownership of content you submit
                            • You grant us license to process your content for dispute resolution
                            • MediationAI owns all intellectual property in the platform
                            • You may not copy, modify, or distribute our software
                            • Respect the intellectual property rights of others
                            """
                        )
                        
                        PolicySection(
                            title: "8. Privacy and Data",
                            content: """
                            • Your privacy is governed by our Privacy Policy
                            • Dispute content is shared only with involved parties
                            • We implement security measures to protect your data
                            • You may request data deletion upon account termination
                            • Data retention follows legal and business requirements
                            """
                        )
                        
                        PolicySection(
                            title: "9. Disclaimers and Limitations",
                            content: """
                            • MediationAI is provided "as is" without warranties
                            • We do not guarantee uninterrupted or error-free service
                            • AI recommendations are automated and may contain errors
                            • We are not liable for dispute outcomes or damages
                            • Maximum liability is limited to fees paid for the service
                            • Some jurisdictions do not allow liability limitations
                            """
                        )
                        
                        PolicySection(
                            title: "10. Indemnification",
                            content: """
                            You agree to indemnify and hold MediationAI harmless from any claims, damages, or expenses arising from:
                            • Your use of the service
                            • Your violation of these terms
                            • Your submitted content
                            • Your disputes with other users
                            """
                        )
                        
                        PolicySection(
                            title: "11. Termination",
                            content: """
                            • You may terminate your account at any time
                            • We may suspend or terminate accounts for violations
                            • Upon termination, your access to the service ends
                            • Ongoing disputes may continue to completion
                            • Data deletion requests will be honored per privacy policy
                            """
                        )
                        
                        PolicySection(
                            title: "12. Governing Law and Disputes",
                            content: """
                            • These terms are governed by [Your Jurisdiction] law
                            • Any disputes will be resolved through binding arbitration
                            • Arbitration will be conducted by [Arbitration Service]
                            • Class action lawsuits are waived
                            • Some jurisdictions may not allow arbitration requirements
                            """
                        )
                        
                        PolicySection(
                            title: "13. Changes to Terms",
                            content: """
                            We may modify these terms at any time. Material changes will be communicated through:
                            • In-app notifications
                            • Email notifications
                            • Updated terms posted in the app
                            
                            Continued use after changes constitutes acceptance.
                            """
                        )
                        
                        PolicySection(
                            title: "14. Contact Information",
                            content: """
                            For questions about these Terms of Service, contact us at:
                            
                            Email: legal@mediationai.app
                            Address: [Your Business Address]
                            Phone: [Your Phone Number]
                            
                            We will respond within 30 business days.
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            }
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}