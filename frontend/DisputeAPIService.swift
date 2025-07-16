import Foundation

class DisputeAPIService: ObservableObject {
    @Published var disputes: [Dispute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = APIConfig.baseURL
    
    // MARK: - Authentication
    func register(email: String, password: String) async -> Bool {
        let endpoint = APIConfig.url(for: "register")
        let requestBody = [
            "email": email,
            "password": password
        ]
        
        do {
            let response = try await makeRequest(to: endpoint, method: "POST", body: requestBody)
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Registration failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        let endpoint = APIConfig.url(for: "login")
        let requestBody = [
            "email": email,
            "password": password
        ]
        
        do {
            let response = try await makeRequest(to: endpoint, method: "POST", body: requestBody)
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // MARK: - Dispute Management
    func createDispute(title: String, description: String, category: String, createContract: Bool) async -> String? {
        let endpoint = APIConfig.url(for: "createDispute")
        let requestBody = [
            "title": title,
            "description": description,
            "category": category,
            "created_by": "user_id", // Replace with actual user ID
            "requires_contract": createContract
        ] as [String: Any]
        
        do {
            let response = try await makeRequest(to: endpoint, method: "POST", body: requestBody)
            if let disputeData = response as? [String: Any],
               let disputeId = disputeData["id"] as? String {
                return disputeId
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to create dispute: \(error.localizedDescription)"
            }
        }
        return nil
    }
    
    func submitTruth(disputeId: String, content: String, attachments: [Attachment]) async -> Bool {
        let endpoint = "\(baseURL)/api/disputes/\(disputeId)/evidence"
        let requestBody = [
            "submitted_by": "user_id", // Replace with actual user ID
            "title": "Truth Submission",
            "description": content,
            "evidence_type": "testimony",
            "content": content
        ] as [String: Any]
        
        do {
            let response = try await makeRequest(to: endpoint, method: "POST", body: requestBody)
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to submit truth: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func getDisputes() async -> [Dispute] {
        let endpoint = APIConfig.url(for: "getDisputes")
        
        do {
            let response = try await makeRequest(to: endpoint, method: "GET")
            // Parse response to Dispute objects
            return [] // Implement parsing
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch disputes: \(error.localizedDescription)"
            }
            return []
        }
    }
    
    // MARK: - Helper Methods
    private func makeRequest(to endpoint: String, method: String, body: [String: Any]? = nil) async throws -> Any {
        guard let url = URL(string: endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = APIConfig.requestTimeout
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        return try JSONSerialization.jsonObject(with: data)
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case noData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .noData:
            return "No data received"
        }
    }
}