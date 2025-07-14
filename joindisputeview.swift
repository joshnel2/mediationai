//
//  JoinDisputeView.swift
//  meidationaiapp
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct JoinDisputeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var code = ""
    @State private var error: String?
    @State private var joinedDispute: Dispute?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("Join a Dispute")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                
                TextField("Enter Share Code", text: $code)
                    .textCase(.uppercase)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .textInputAutocapitalization(.characters) // <-- ADD THIS LINE
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleJoin) {
                    Text("Join")
                        .font(AppTheme.buttonFont())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.mainGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func handleJoin() {
        error = nil
        guard let user = authService.currentUser else { return }
        if code.isEmpty {
            error = "Please enter a code."
            return
        }
        if let dispute = disputeService.joinDispute(shareCode: code, user: user) {
            joinedDispute = dispute
            dismiss()
        } else {
            error = "Invalid or already joined code."
        }
    }
}
