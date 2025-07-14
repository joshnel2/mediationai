//
//  HomeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var showSettings = false
    @State private var shareCode = ""
    @State private var error: String?
    @State private var selectedDispute: Dispute?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "person.circle")
                                    .font(.title3)
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            NavigationView {
                contentView
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showSettings = true }) {
                                Image(systemName: "person.circle")
                                    .font(.title3)
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var contentView: some View {
            VStack(spacing: 24) {
                // Header with welcome message
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back!")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.primary)
                            
                            Text(authService.currentUser?.email.components(separatedBy: "@").first ?? "User")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                // Disputes Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Your Disputes")
                            .font(AppTheme.titleFont())
                            .foregroundColor(AppTheme.primary)
                        
                        Spacer()
                        
                        // Dispute count badge
                        let userDisputes = disputeService.disputes.filter { $0.partyA?.id == authService.currentUser?.id || $0.partyB?.id == authService.currentUser?.id }
                        
                        if !userDisputes.isEmpty {
                            Text("\(userDisputes.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                    
                    if disputeService.disputes.filter({ $0.partyA?.id == authService.currentUser?.id || $0.partyB?.id == authService.currentUser?.id }).isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "scale.3d")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            VStack(spacing: 8) {
                                Text("No disputes yet")
                                    .font(AppTheme.subtitleFont())
                                    .foregroundColor(.gray)
                                
                                Text("Create or join a dispute to get started with AI-powered mediation")
                                    .font(AppTheme.bodyFont())
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                        .background(AppTheme.card)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    } else {
                        ScrollView {
                            ForEach(disputeService.disputes.filter { $0.partyA?.id == authService.currentUser?.id || $0.partyB?.id == authService.currentUser?.id }) { dispute in
                                Button {
                                    selectedDispute = dispute
                                } label: {
                                    DisputeCardView(dispute: dispute)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: { showCreate = true }) {
                            Label("Create Dispute", systemImage: "plus.circle.fill")
                                .font(AppTheme.buttonFont())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.mainGradient)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(radius: 4)
                        }
                        
                        Button(action: { showJoin = true }) {
                            Label("Join Dispute", systemImage: "link.circle.fill")
                                .font(AppTheme.buttonFont())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.secondary)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(radius: 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick info
                    Text("$1 to create • $1 to join • AI-powered resolution")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.bottom)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .sheet(item: $selectedDispute) { dispute in
                DisputeRoomView(dispute: dispute)
            }
            .sheet(isPresented: $showCreate) {
                CreateDisputeView()
            }
            .sheet(isPresented: $showJoin) {
                JoinDisputeView()
            }
        }
}
