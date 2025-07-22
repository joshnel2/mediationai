//
//  ContractGenerationView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import UIKit

struct ContractGenerationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Contract Generation")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.bottom, 10)
                        
                        Text("Legal Framework & Enforceability")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            LegalSection(
                                title: "AI-Generated Contract Validity",
                                content: """
                                Our AI-generated contracts are legally binding and enforceable under applicable contract law. Each contract is created using established legal principles and precedents, ensuring validity in court proceedings.
                                
                                • Contracts comply with the Uniform Commercial Code (UCC) where applicable
                                • Digital signatures meet Electronic Signatures in Global and National Commerce Act (ESIGN) requirements
                                • All essential contract elements are included: offer, acceptance, consideration, and mutual assent
                                """
                            )
                            
                            LegalSection(
                                title: "Enforceability Standards",
                                content: """
                                MediationAI contracts are designed to meet the highest standards of legal enforceability:
                                
                                • Clear and unambiguous terms drafted in plain language
                                • Proper identification of all parties and their obligations
                                • Specific performance criteria and dispute resolution mechanisms
                                • Compliance with applicable state and federal regulations
                                • Integration of industry-standard legal clauses and protections
                                """
                            )
                            
                            LegalSection(
                                title: "Legal Foundation",
                                content: """
                                Our contract generation system is built upon:
                                
                                • Comprehensive legal database of contract precedents
                                • Real-time updates to reflect current legal standards
                                • Jurisdiction-specific compliance requirements
                                • Professional legal review of AI algorithms and outputs
                                • Adherence to American Bar Association guidelines for legal technology
                                """
                            )
                            
                            LegalSection(
                                title: "Limitations & Disclaimers",
                                content: """
                                While our AI-generated contracts are legally sound, users should be aware:
                                
                                • Complex commercial transactions may require additional legal counsel
                                • Certain specialized industries may have unique regulatory requirements
                                • International contracts may require jurisdiction-specific modifications
                                • Users remain responsible for ensuring contract terms meet their specific needs
                                
                                For complex matters, we recommend consulting with a qualified attorney.
                                """
                            )
                        }
                        
                        // Footer
                        VStack(alignment: .center, spacing: 8) {
                            Text("This information is provided for educational purposes and does not constitute legal advice.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("MediationAI Legal Framework 2025")
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

struct LegalSection: View {
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
        .background(AppTheme.cardGradient)
        .cornerRadius(AppTheme.radiusLG)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                .stroke(AppTheme.glassPrimary, lineWidth: 1)
        )
    }
}

struct ContractGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ContractGenerationView()
    }
}