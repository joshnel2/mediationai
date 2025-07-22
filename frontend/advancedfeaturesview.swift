//
//  AdvancedFeaturesView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI
import UIKit

struct AdvancedFeaturesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Advanced Features")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.primary)
                            .padding(.bottom, 10)
                        
                        Text("Maximize Your AI Dispute Resolution Experience")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondary)
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            GuideSection(
                                icon: "brain.head.profile",
                                title: "AI Evidence Analysis",
                                content: """
                                Our AI can analyze complex evidence types for better resolutions:
                                
                                • Document analysis and contract interpretation
                                • Image and video evidence evaluation
                                • Financial records and transaction history review
                                • Communication logs and email threads
                                • Timeline reconstruction and fact verification
                                
                                Upload multiple evidence types for comprehensive analysis.
                                """
                            )
                            
                            GuideSection(
                                icon: "signature",
                                title: "Digital Signatures & Contracts",
                                content: """
                                Create legally binding agreements with our digital signature system:
                                
                                • Generate custom contracts based on your dispute
                                • Secure digital signatures with legal validity
                                • Automated contract enforcement tracking
                                • Integration with escrow services
                                • Court-admissible documentation
                                
                                All signatures comply with ESIGN Act requirements.
                                """
                            )
                            
                            GuideSection(
                                icon: "creditcard.and.123",
                                title: "Escrow Protection",
                                content: """
                                Secure your funds during dispute resolution:
                                
                                • Automated escrow account creation
                                • FDIC-insured fund protection
                                • Smart contract-based release conditions
                                • Multi-party approval systems
                                • Fraud protection and monitoring
                                
                                Funds are only released when both parties agree or AI mediates.
                                """
                            )
                            
                            GuideSection(
                                icon: "person.3.sequence",
                                title: "Multi-Party Disputes",
                                content: """
                                Handle complex disputes involving multiple parties:
                                
                                • Add unlimited participants to disputes
                                • Weighted voting systems for decisions
                                • Individual evidence submission by each party
                                • Separate communication channels
                                • Proportional resolution recommendations
                                
                                Perfect for business partnerships and group contracts.
                                """
                            )
                            
                            GuideSection(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Analytics & Insights",
                                content: """
                                Track your dispute resolution performance:
                                
                                • Success rate tracking and improvement suggestions
                                • Average resolution time analysis
                                • Cost savings vs. traditional legal methods
                                • Dispute category performance metrics
                                • Predictive resolution likelihood scoring
                                
                                Use insights to prevent future disputes.
                                """
                            )
                        }
                        
                        // Footer
                        VStack(alignment: .center, spacing: 8) {
                            Text("Master these features to become a dispute resolution expert.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("MediationAI Advanced Guide 2025")
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

struct AdvancedFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedFeaturesView()
    }
}