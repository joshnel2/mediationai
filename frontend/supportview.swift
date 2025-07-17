//
//  SupportView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import MessageUI

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingMailComposer = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(AppTheme.mainGradient)
                        
                        Text("Support Center")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                        
                        Text("We're here to help with any questions or issues")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Contact Methods
                    VStack(spacing: 16) {
                        SupportContactCard(
                            icon: "envelope.fill",
                            title: "Email Support",
                            subtitle: "Get help within 24 hours",
                            contact: "support@mediationai.app",
                            action: { showingMailComposer = true }
                        )
                        
                        SupportContactCard(
                            icon: "phone.fill",
                            title: "Phone Support",
                            subtitle: "Mon-Fri, 9AM-5PM EST",
                            contact: "+1 (555) 123-4567",
                            action: { callSupport() }
                        )
                        
                        SupportContactCard(
                            icon: "message.fill",
                            title: "Live Chat",
                            subtitle: "Available during business hours",
                            contact: "Chat with us",
                            action: { openLiveChat() }
                        )
                    }
                    
                    // FAQ Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Frequently Asked Questions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.primary)
                        
                        FAQItem(
                            question: "How does MediationAI work?",
                            answer: "Create a dispute for FREE during beta, share the link with the other party who also joins for FREE, both submit evidence, and our AI provides a mediation recommendation."
                        )
                        
                        FAQItem(
                            question: "Are the fees refundable?",
                            answer: "Fees are generally non-refundable once a dispute is created or joined, except as required by applicable law. Contact support for specific cases."
                        )
                        
                        FAQItem(
                            question: "Is the AI recommendation legally binding?",
                            answer: "No, AI recommendations are suggestions only. Parties may choose to follow them or pursue other legal remedies."
                        )
                        
                        FAQItem(
                            question: "How long does resolution take?",
                            answer: "Once both parties submit their evidence, AI analysis typically completes within minutes."
                        )
                        
                        FAQItem(
                            question: "Is my data secure?",
                            answer: "Yes, all data is encrypted and only shared with parties involved in your dispute. See our Privacy Policy for details."
                        )
                        
                        FAQItem(
                            question: "Can I delete my account?",
                            answer: "Yes, contact support to delete your account. Completed dispute records may be retained for legal compliance."
                        )
                    }
                    
                    // Business Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Business Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MediationAI LLC")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("[Your Business Address]")
                                .font(.body)
                                .foregroundColor(.gray)
                            
                            Text("Business Hours: Monday - Friday, 9:00 AM - 5:00 PM EST")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    
                    // Additional Resources
                    VStack(spacing: 12) {
                        Text("Additional Resources")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.primary)
                        
                        Button(action: { /* Open user guide */ }) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("User Guide")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                        }
                        
                        Button(action: { /* Open video tutorials */ }) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text("Video Tutorials")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                        }
                        
                        Button(action: { /* Open community forum */ }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("Community Forum")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
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
            .sheet(isPresented: $showingMailComposer) {
                MailComposer(
                    recipient: "support@mediationai.app",
                    subject: "MediationAI Support Request"
                )
            }
            .alert("Action", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func callSupport() {
        if let phoneURL = URL(string: "tel://+15551234567") {
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            } else {
                alertMessage = "Phone calls are not available on this device"
                showingAlert = true
            }
        }
    }
    
    private func openLiveChat() {
        // In a real app, this would open your live chat service
        alertMessage = "Live chat is currently being set up. Please use email or phone support for now."
        showingAlert = true
    }
}

struct SupportContactCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let contact: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(contact)
                        .font(.body)
                        .foregroundColor(AppTheme.primary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(AppTheme.card)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(question)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppTheme.card)
        .cornerRadius(12)
        .shadow(radius: 2)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct MailComposer: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients([recipient])
        composer.setSubject(subject)
        composer.setMessageBody("Please describe your issue or question:", isHTML: false)
        composer.mailComposeDelegate = context.coordinator
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}