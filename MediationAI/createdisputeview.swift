//
//  CreateDisputeView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct CreateDisputeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: MockAuthService
    @EnvironmentObject var disputeService: MockDisputeService
    @State private var title = ""
    @State private var description = ""
    @State private var error: String?
    @State private var createdDispute: Dispute?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create a Dispute")
                    .font(AppTheme.titleFont())
                    .foregroundColor(AppTheme.primary)
                
                TextField("Dispute Title", text: $title)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                
                TextField("Describe the situation...", text: $description, axis: .vertical)
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .frame(minHeight: 100, maxHeight: 150)
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: handleCreate) {
                    Text("Create & Get Share Code")
                        .font(AppTheme.buttonFont())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.mainGradient)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top)
                
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
            .sheet(item: $createdDispute) { dispute in
                ShareDisputeView(dispute: dispute)
            }
        }
    }
    
    func handleCreate() {
        error = nil
        guard let user = authService.currentUser else { return }
        if title.isEmpty || description.isEmpty {
            error = "Please fill in all fields."
            return
        }
        let dispute = disputeService.createDispute(title: title, description: description, user: user)
        createdDispute = dispute
    }
}
