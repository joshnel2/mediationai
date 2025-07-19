import Foundation

struct APIConfig {
    // MARK: - Backend Configuration
    // Update this URL to your deployed Vercel backend
    static let baseURL = "https://mediationai-3ueg.vercel.app"
    
    // For local development, uncomment this line instead:
    // static let baseURL = "http://localhost:8000"
    
    // MARK: - API Endpoints
    static let endpoints = [
        "register": "/api/register",
        "requestCode": "/api/auth/request-code",
        "login": "/api/login",
        "logout": "/api/logout",
        "profile": "/api/me",
        "createDispute": "/api/disputes/create",
        "getDisputes": "/api/disputes/user",
        "joinDispute": "/api/disputes/join",
        "getDisputeDetails": "/api/disputes/",
        "submitTruth": "/api/disputes/truth",
        "getMessages": "/api/disputes/messages",
        "sendMessage": "/api/disputes/message",
        "getResolution": "/api/disputes/resolution"
    ]
    
    // MARK: - Helper Methods
    static func url(for endpoint: String) -> String {
        return baseURL + (endpoints[endpoint] ?? "")
    }
    
    static func disputeURL(for disputeId: String) -> String {
        return baseURL + "/api/disputes/" + disputeId
    }
    
    // MARK: - App Configuration
    static let appDomain = "mediationai.app"
    static let appStoreURL = "https://apps.apple.com/app/id123456789"
    static let websiteURL = "https://www.mediationai.app"
    
    // MARK: - Request Configuration
    static let requestTimeout: TimeInterval = 30.0
    static let maxRetries = 3
    
    // MARK: - Development/Debug Settings
    #if DEBUG
    static let enableLogging = true
    static let enableMockData = false
    #else
    static let enableLogging = false
    static let enableMockData = false
    #endif
}

// MARK: - NetworkManager Extension
extension APIConfig {
    static func createURLRequest(for endpoint: String, method: String = "GET", body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: url(for: endpoint)) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}