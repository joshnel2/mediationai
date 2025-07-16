//
//  InAppPurchaseService.swift
//  MediationAI
//
//  Created by Linda Alster on 7/14/25.
//

import Foundation
import StoreKit
import SwiftUI

class InAppPurchaseService: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var purchaseError: String?
    
    // Product IDs
    static let createDisputeProductID = "com.mediationai.create_dispute"
    static let joinDisputeProductID = "com.mediationai.join_dispute"
    
    private var products: [Product] = []
    
    override init() {
        super.init()
        loadProducts()
    }
    
    func loadProducts() {
        Task {
            do {
                let products = try await Product.products(for: [
                    Self.createDisputeProductID,
                    Self.joinDisputeProductID
                ])
                await MainActor.run {
                    self.products = products
                }
            } catch {
                await MainActor.run {
                    self.purchaseError = "Failed to load products: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func purchaseCreateDispute() async -> Bool {
        return await purchaseProduct(productID: Self.createDisputeProductID)
    }
    
    func purchaseJoinDispute() async -> Bool {
        return await purchaseProduct(productID: Self.joinDisputeProductID)
    }
    
    private func purchaseProduct(productID: String) async -> Bool {
        guard let product = products.first(where: { $0.id == productID }) else {
            await MainActor.run {
                self.purchaseError = "Product not found"
            }
            return false
        }
        
        await MainActor.run {
            self.isLoading = true
            self.purchaseError = nil
        }
        
        do {
            let result = try await product.purchase()
            
            await MainActor.run {
                self.isLoading = false
            }
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified:
                    return true
                case .unverified:
                    await MainActor.run {
                        self.purchaseError = "Purchase could not be verified"
                    }
                    return false
                }
            case .pending:
                await MainActor.run {
                    self.purchaseError = "Purchase is pending approval"
                }
                return false
            case .userCancelled:
                return false
            @unknown default:
                await MainActor.run {
                    self.purchaseError = "Unknown purchase result"
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.purchaseError = "Purchase failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // Mock purchase for development/testing
    func mockPurchase() async -> Bool {
        await MainActor.run {
            self.isLoading = true
            self.purchaseError = nil
        }
        
        // Simulate purchase delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            self.isLoading = false
        }
        
        // Simulate 95% success rate for testing
        return Bool.random() ? true : Bool.random() ? true : true
    }
    
    // Purchase for truth submission
    func purchaseTruthSubmission() async -> Bool {
        return await purchaseProduct(productID: Self.createDisputeProductID)
    }
    
    // Purchase for dispute joining
    func purchaseDisputeJoining() async -> Bool {
        return await purchaseProduct(productID: Self.joinDisputeProductID)
    }
}