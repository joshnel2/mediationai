import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Terms of Service")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Effective Date: January 1, 2025")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Last Updated: January 1, 2025")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Introduction
                    termsSection(
                        title: "1. Acceptance of Terms",
                        content: """
                        By downloading, installing, or using MediationAI, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our application.
                        
                        These terms constitute a legally binding agreement between you and MediationAI.
                        """
                    )
                    
                    // Service Description
                    termsSection(
                        title: "2. Service Description",
                        content: """
                        MediationAI provides an AI-powered dispute resolution platform that:
                        
                        • Facilitates communication between disputing parties
                        • Provides AI-generated mediation suggestions
                        • Offers evidence collection and organization tools
                        • Generates dispute resolution recommendations
                        • Provides digital signature capabilities for agreements
                        
                        Our service is mediation assistance, not legal advice.
                        """
                    )
                    
                    // User Responsibilities
                    termsSection(
                        title: "3. User Responsibilities",
                        content: """
                        You agree to:
                        
                        • Provide accurate and truthful information
                        • Use the service in good faith for legitimate disputes
                        • Respect the rights and privacy of other users
                        • Comply with all applicable laws and regulations
                        • Not use the service for illegal or harmful purposes
                        • Maintain the confidentiality of your account credentials
                        """
                    )
                    
                    // Beta Service Notice
                    termsSection(
                        title: "4. Beta Service",
                        content: """
                        MediationAI is currently in beta testing. During this period:
                        
                        • All services are provided FREE of charge
                        • Features may be added, modified, or removed
                        • Service availability may be limited
                        • Data backup and recovery are not guaranteed
                        • We may reset or modify user data as needed for testing
                        """
                    )
                    
                    // Prohibited Uses
                    termsSection(
                        title: "5. Prohibited Uses",
                        content: """
                        You may not use MediationAI to:
                        
                        • Engage in illegal activities or fraud
                        • Harass, threaten, or abuse other users
                        • Upload malicious content or viruses
                        • Attempt to hack or compromise the service
                        • Violate intellectual property rights
                        • Impersonate others or create false accounts
                        • Spam or send unsolicited communications
                        """
                    )
                    
                    // AI and Legal Disclaimer
                    termsSection(
                        title: "6. AI and Legal Disclaimer",
                        content: """
                        IMPORTANT LEGAL NOTICE:
                        
                        • MediationAI provides mediation services, NOT legal advice
                        • AI responses are suggestions based on mediation principles
                        • Our AI does not replace qualified legal counsel
                        • For legal matters, consult a licensed attorney
                        • We are not responsible for legal outcomes of disputes
                        • AI suggestions should not be considered legal determinations
                        """
                    )
                    
                    // Intellectual Property
                    termsSection(
                        title: "7. Intellectual Property",
                        content: """
                        • MediationAI and its content are protected by copyright and trademark laws
                        • You retain ownership of content you submit to the platform
                        • By using our service, you grant us a license to use your content for service provision
                        • You may not copy, modify, or distribute our proprietary content
                        """
                    )
                    
                    // Limitation of Liability
                    termsSection(
                        title: "8. Limitation of Liability",
                        content: """
                        TO THE MAXIMUM EXTENT PERMITTED BY LAW:
                        
                        • MediationAI is provided "AS IS" without warranties
                        • We are not liable for any indirect, incidental, or consequential damages
                        • Our total liability is limited to the amount you paid for services
                        • We do not guarantee dispute resolution outcomes
                        • You use the service at your own risk
                        """
                    )
                    
                    // Privacy and Data
                    termsSection(
                        title: "9. Privacy and Data",
                        content: """
                        • Your privacy is important to us
                        • Data collection and use are governed by our Privacy Policy
                        • You consent to data processing as described in our Privacy Policy
                        • We implement security measures to protect your data
                        • You may request data deletion by contacting us
                        """
                    )
                    
                    // Termination
                    termsSection(
                        title: "10. Termination",
                        content: """
                        • You may terminate your account at any time
                        • We may terminate or suspend accounts that violate these terms
                        • Upon termination, your access to the service will cease
                        • Data retention after termination is governed by our Privacy Policy
                        • These terms survive termination where applicable
                        """
                    )
                    
                    // Changes to Terms
                    termsSection(
                        title: "11. Changes to Terms",
                        content: """
                        • We may update these terms from time to time
                        • Changes will be posted in the app with an updated date
                        • Continued use after changes constitutes acceptance
                        • Material changes will be communicated with 30 days notice
                        """
                    )
                    
                    // Contact Information
                    termsSection(
                        title: "12. Contact Information",
                        content: """
                        For questions about these Terms of Service:
                        
                        Email: legal@mediationai.com
                        Address: [Your Business Address]
                        Phone: [Your Phone Number]
                        
                        We will respond to inquiries within 30 days.
                        """
                    )
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    TermsOfServiceView()
}