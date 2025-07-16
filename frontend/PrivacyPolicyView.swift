import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Privacy Policy")
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
                    privacySection(
                        title: "Introduction",
                        content: """
                        MediationAI ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.
                        
                        By using MediationAI, you agree to the collection and use of information in accordance with this policy.
                        """
                    )
                    
                    // Information We Collect
                    privacySection(
                        title: "Information We Collect",
                        content: """
                        We collect the following types of information:
                        
                        • Account Information: Email address, password (encrypted), and profile details
                        • Dispute Information: Dispute details, evidence files, and truth statements
                        • Usage Data: App usage patterns and feature interactions
                        • Device Information: Device type, operating system, and app version
                        • Communication Data: Messages and interactions within disputes
                        """
                    )
                    
                    // How We Use Your Information
                    privacySection(
                        title: "How We Use Your Information",
                        content: """
                        We use your information to:
                        
                        • Provide and maintain our dispute resolution services
                        • Process and facilitate dispute mediation
                        • Improve our AI mediation algorithms
                        • Communicate with you about your disputes
                        • Ensure platform security and prevent fraud
                        • Comply with legal obligations
                        """
                    )
                    
                    // Data Storage and Security
                    privacySection(
                        title: "Data Storage and Security",
                        content: """
                        • Your data is stored securely using industry-standard encryption
                        • Passwords are hashed using bcrypt encryption
                        • All data transmission uses HTTPS encryption
                        • We implement appropriate security measures to protect your information
                        • Data is stored on secure servers with regular backups
                        """
                    )
                    
                    // Data Sharing
                    privacySection(
                        title: "Data Sharing",
                        content: """
                        We do not sell, trade, or rent your personal information to third parties.
                        
                        We may share your information only in the following circumstances:
                        
                        • With other parties in your dispute (dispute details and evidence)
                        • With legal authorities when required by law
                        • With service providers who assist in app functionality
                        • In case of business transfer or merger (with notice)
                        """
                    )
                    
                    // Your Rights
                    privacySection(
                        title: "Your Rights",
                        content: """
                        You have the right to:
                        
                        • Access your personal information
                        • Correct inaccurate information
                        • Delete your account and associated data
                        • Withdraw consent for data processing
                        • Export your data in a readable format
                        • File complaints with data protection authorities
                        """
                    )
                    
                    // Data Retention
                    privacySection(
                        title: "Data Retention",
                        content: """
                        • Account data: Retained until account deletion
                        • Dispute data: Retained for legal compliance (7 years)
                        • Usage data: Retained for 2 years for analytics
                        • Authentication tokens: 30-day expiration
                        • Backup data: Retained for 90 days
                        """
                    )
                    
                    // Children's Privacy
                    privacySection(
                        title: "Children's Privacy",
                        content: """
                        MediationAI is not intended for use by children under 13 years of age. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us immediately.
                        """
                    )
                    
                    // Changes to Privacy Policy
                    privacySection(
                        title: "Changes to This Privacy Policy",
                        content: """
                        We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the app and updating the "Last Updated" date.
                        
                        Your continued use of the app after changes constitutes acceptance of the updated policy.
                        """
                    )
                    
                    // Contact Information
                    privacySection(
                        title: "Contact Us",
                        content: """
                        If you have questions about this Privacy Policy, please contact us:
                        
                        Email: privacy@mediationai.com
                        Address: [Your Business Address]
                        Phone: [Your Phone Number]
                        
                        We will respond to your inquiries within 30 days.
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
    private func privacySection(title: String, content: String) -> some View {
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
    PrivacyPolicyView()
}