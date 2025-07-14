//
//  ResolutionView.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//


import SwiftUI

struct ResolutionView: View {
    let resolution: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "lightbulb.max.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(AppTheme.mainGradient)
                .padding()
                .background(AppTheme.card)
                .clipShape(Circle())
                .shadow(radius: 10)
            
            Text("AI Resolution")
                .font(AppTheme.titleFont())
                .foregroundColor(AppTheme.primary)
            
            Text(resolution)
                .font(AppTheme.bodyFont())
                .foregroundColor(.primary)
                .padding()
                .background(AppTheme.card)
                .cornerRadius(16)
                .shadow(radius: 4)
                .multilineTextAlignment(.center)
            
            Spacer()
            Button("Done") { dismiss() }
                .font(AppTheme.buttonFont())
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.mainGradient)
                .foregroundColor(.white)
                .cornerRadius(16)
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
    }
}
