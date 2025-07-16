//
//  SignatureView.swift
//  MediationAI
//
//  Created by AI Assistant on 7/14/25.
//

import SwiftUI
import PencilKit
import UIKit

struct SignatureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var signature: UIImage?
    @State private var isSignatureComplete = false
    let title: String
    let subtitle: String
    let onSignatureComplete: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                VStack(spacing: AppTheme.spacingMD) {
                    Image(systemName: "signature")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.primary)
                    
                    Text(title)
                        .font(AppTheme.title2())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(AppTheme.body())
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.spacingMD)
                }
                .padding(.top, AppTheme.spacingXL)
                
                // Signature canvas
                VStack(spacing: AppTheme.spacingMD) {
                    Text("Sign below:")
                        .font(AppTheme.headline())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                                    .stroke(AppTheme.primary, lineWidth: 2)
                            )
                        
                        SignatureCanvas(canvasView: $canvasView, isSignatureComplete: $isSignatureComplete)
                            .cornerRadius(AppTheme.radiusLG)
                        
                        if !isSignatureComplete {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("Sign here")
                                        .font(AppTheme.caption())
                                        .foregroundColor(AppTheme.textTertiary)
                                        .italic()
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal, AppTheme.spacingMD)
                }
                
                // Action buttons
                VStack(spacing: AppTheme.spacingMD) {
                    Button(action: clearSignature) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.headline)
                            Text("Clear")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(AppTheme.textSecondary)
                    }
                    .secondaryButton()
                    
                    Button(action: saveSignature) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                            Text("Confirm Signature")
                                .font(AppTheme.headline())
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                    }
                    .primaryButton()
                    .disabled(!isSignatureComplete)
                    .opacity(isSignatureComplete ? 1.0 : 0.6)
                }
                .padding(.horizontal, AppTheme.spacingLG)
                
                // Legal notice
                VStack(spacing: AppTheme.spacingSM) {
                    Text("Legal Notice & Disclaimer")
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .fontWeight(.bold)
                    
                    VStack(spacing: AppTheme.spacingSM) {
                        Text("By affixing your digital signature below, you hereby acknowledge and agree that:")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textTertiary)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                            Text("• This digital signature is legally binding and equivalent to a handwritten signature under the Electronic Signatures in Global and National Commerce Act (ESIGN) and applicable state laws.")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("• The dispute resolution and any contract terms agreed upon through this platform constitute a binding legal agreement enforceable in courts of competent jurisdiction.")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("• You waive any right to contest the validity of this digital signature or the enforceability of this agreement based solely on its electronic nature.")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("• This signed resolution may be presented as evidence in legal proceedings and shall have the same force and effect as if executed with a traditional handwritten signature.")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Text("• You have read, understood, and voluntarily agree to be bound by all terms and conditions set forth in this dispute resolution.")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        
                        Text("NOTICE: This signature creates a legally enforceable obligation. If you do not agree to be legally bound, do not sign.")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.warning)
                            .multilineTextAlignment(.center)
                            .padding(.top, AppTheme.spacingSM)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                }
                .padding(AppTheme.spacingMD)
                .background(AppTheme.glassPrimary)
                .cornerRadius(AppTheme.radiusMD)
                .padding(.horizontal, AppTheme.spacingLG)
                
                Spacer()
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func clearSignature() {
        canvasView.drawing = PKDrawing()
        isSignatureComplete = false
        signature = nil
    }
    
    private func saveSignature() {
        let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
        let image = renderer.image { _ in
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        
        onSignatureComplete(image)
        
        // Smooth transition back to home after signature completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                dismiss()
            }
        }
    }
}

struct SignatureCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isSignatureComplete: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .clear
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: SignatureCanvas
        
        init(_ parent: SignatureCanvas) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.isSignatureComplete = !canvasView.drawing.strokes.isEmpty
        }
    }
}

struct SignatureDisplayView: View {
    let signature: UIImage
    let signerName: String
    let signedDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            Text("Digital Signature")
                .font(AppTheme.caption())
                .foregroundColor(AppTheme.textSecondary)
                .fontWeight(.medium)
            
            HStack {
                Image(uiImage: signature)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(AppTheme.radiusSM)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                            .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(signerName)
                        .font(AppTheme.caption())
                        .foregroundColor(AppTheme.textPrimary)
                        .fontWeight(.medium)
                    
                    Text("Signed: \(signedDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.success)
                
                Text("Legally binding digital signature")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingMD)
        .background(AppTheme.glassPrimary)
        .cornerRadius(AppTheme.radiusMD)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                .stroke(AppTheme.success.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SignatureView(
        title: "Sign Contract Agreement",
        subtitle: "Please provide your digital signature to make this contract legally binding."
    ) { signature in
        // Handle signature
    }
}