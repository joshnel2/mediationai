//
//  EscrowMediationView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct EscrowMediationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Escrow Mediation")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.bottom, 10)
                        
                        Text("Legal Framework & Protection")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            LegalSection(
                                title: "Escrow Legal Authority",
                                content: """
                                MediationAI's escrow service operates under established legal frameworks governing third-party intermediary services:
                                
                                • Compliance with state escrow regulations and licensing requirements
                                • Adherence to federal financial services oversight standards
                                • Integration with licensed payment processors and financial institutions
                                • Full regulatory compliance for secure fund management
                                """
                            )
                            
                            LegalSection(
                                title: "Fund Protection & Security",
                                content: """
                                Your funds are protected through multiple layers of legal and technical safeguards:
                                
                                • Segregated client accounts maintained with FDIC-insured institutions
                                • Bonded escrow services with professional liability insurance
                                • Multi-signature authorization requirements for fund releases
                                • Real-time transaction monitoring and fraud prevention
                                • Compliance with anti-money laundering (AML) regulations
                                """
                            )
                            
                            LegalSection(
                                title: "Mediation Authority",
                                content: """
                                Our AI-powered mediation service operates within established legal parameters:
                                
                                • AI recommendations based on established legal precedents and mediation principles
                                • Neutral third-party facilitation without bias toward either party
                                • Transparent decision-making process with clear reasoning provided
                                • Compliance with Alternative Dispute Resolution (ADR) best practices
                                • Integration with court-approved mediation procedures where applicable
                                """
                            )
                            
                            LegalSection(
                                title: "Release Conditions & Procedures",
                                content: """
                                Escrow funds are released according to strict legal protocols:
                                
                                • Mutual agreement between parties triggers automatic release
                                • AI-mediated resolutions require digital signature confirmation
                                • Dispute escalation procedures for unresolved conflicts
                                • Court order compliance for judicial determinations
                                • Fraud protection with investigation and recovery procedures
                                """
                            )
                            
                            LegalSection(
                                title: "Legal Recourse & Limitations",
                                content: """
                                Parties retain full legal rights throughout the escrow process:
                                
                                • Right to legal counsel at any stage of the process
                                • Ability to escalate disputes to traditional court systems
                                • Access to detailed transaction records and documentation
                                • Professional liability coverage for service errors or omissions
                                • Clear appeals process for disputed AI recommendations
                                
                                MediationAI facilitates resolution but does not replace legal rights or remedies.
                                """
                            )
                        }
                        
                        // Footer
                        VStack(alignment: .center, spacing: 8) {
                            Text("This information is provided for educational purposes and does not constitute legal or financial advice.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("MediationAI Escrow Services 2025")
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

struct EscrowMediationView_Previews: PreviewProvider {
    static var previews: some View {
        EscrowMediationView()
    }
}