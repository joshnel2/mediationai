//
//  HomeView.swift
//  meidationaiapp
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var showCreate = false
    @State private var showJoin = false
    @State private var shareCode = ""
    @State private var error: String?
    @State private var selectedDispute: Dispute?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                contentView
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            NavigationView {
                contentView
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var contentView: some View {
            VStack(spacing: 24) {
                Text("Your Disputes")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                    .padding(.top)
                
                if disputeService.disputes.filter({ $0.partyA?.id == authService.currentUser?.id || $0.partyB?.id == authService.currentUser?.id }).isEmpty {
                    Text("No disputes yet. Create or join one!")
                        .font(AppTheme.bodyFont())
                        .foregroundColor(.gray)
                        .padding()
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
                
                HStack(spacing: 16) {
                    Button(action: { showCreate = true }) {
                        Label("Create", systemImage: "plus")
                            .font(AppTheme.buttonFont())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.mainGradient)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    Button(action: { showJoin = true }) {
                        Label("Join", systemImage: "link")
                            .font(AppTheme.buttonFont())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
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
