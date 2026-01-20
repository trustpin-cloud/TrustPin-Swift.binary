import Foundation
import Combine
import TrustPinKit

@MainActor
final class MainViewModel: ObservableObject {
    @Published var organizationId: String
    @Published var projectId: String
    @Published var publicKey: String
    @Published var testURL: String
    @Published var currentMode: TrustPinMode
    @Published var isConfigured = false
    @Published var isTesting = false
    @Published var statusMessage = "TrustPin not configured"
    @Published var logs: [LogEntry] = []
    @Published var showModeAlert = false
    
    private let trustPinService = TrustPinService()
    private let networkService = NetworkService()
    private let loggingService = LoggingService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let defaultConfiguration = TrustPinConfiguration.default
        
        self.organizationId = defaultConfiguration.organizationId
        self.projectId = defaultConfiguration.projectId
        self.publicKey = defaultConfiguration.publicKey
        self.currentMode = defaultConfiguration.mode
        self.testURL = "https://api.trustpin.cloud/health"
        
        setupBindings()
    }
    
    private func setupBindings() {
        loggingService.logs
            .receive(on: DispatchQueue.main)
            .assign(to: \.logs, on: self)
            .store(in: &cancellables)
    }
    
    func setupTrustPin() {
        let configuration = TrustPinConfiguration(
            organizationId: organizationId,
            projectId: projectId,
            publicKey: publicKey,
            mode: currentMode
        )
        
        guard configuration.isValid else {
            loggingService.log("Configuration failed: Missing required fields", level: .error)
            return
        }
        
        Task { @MainActor in
            loggingService.log("Configuring TrustPin...", level: .info)
            loggingService.log("Organization ID: \(organizationId)", level: .debug)
            loggingService.log("Project ID: \(projectId)", level: .debug)
            loggingService.log("Public Key: \(String(publicKey.prefix(20)))...", level: .debug)
            
            do {
                try await trustPinService.configure(configuration)
                
                loggingService.log("Mode: \(currentMode == .strict ? "Strict" : "Permissive")", level: .info)
                
                isConfigured = true
                statusMessage = "TrustPin configured"
                
                loggingService.log("TrustPin configuration successful", level: .success)
            } catch {
                isConfigured = false
                statusMessage = "TrustPin not configured"
                
                loggingService.log("TrustPin configuration failed: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    func testConnection() {
        guard isConfigured else {
            loggingService.log("Test connection failed: TrustPin not configured", level: .warning)
            return
        }
        
        guard !testURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            loggingService.log("Test connection failed: No URL provided", level: .warning)
            return
        }
        
        Task { @MainActor in
            isTesting = true
            statusMessage = "Testing connection..."
            
            loggingService.log("Testing connection to: \(testURL)", level: .info)
            loggingService.log("Making HTTP request...", level: .debug)
            loggingService.log("Method: GET", level: .debug)
            loggingService.log("URL: \(testURL)", level: .debug)
            loggingService.log("User-Agent: TrustPin-iOS-Sample/1.0", level: .debug)
            loggingService.log("Using TrustPin SSL certificate validation", level: .info)
            
            do {
                let result = try await networkService.testConnection(
                    url: testURL.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                isTesting = false
                statusMessage = "TrustPin configured"
                
                if result.success {
                    loggingService.log("Connection test successful!", level: .success)
                    
                    if let statusCode = result.statusCode {
                        loggingService.log("Response received:", level: .info)
                        loggingService.log("Status: \(statusCode)", level: .debug)
                    }
                    
                    if let preview = result.responsePreview {
                        loggingService.log("Response: \(preview)", level: .debug)
                    }
                } else if let error = result.error {
                    loggingService.log("Connection failed: \(error.localizedDescription)", level: .error)
                }
            } catch {
                isTesting = false
                statusMessage = "TrustPin configured"
                
                loggingService.log("Connection failed: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    func clearLog() {
        loggingService.clear()
    }
    
    func toggleModeAlert() {
        showModeAlert = true
    }
    
    var formattedLogs: String {
        logs.map { $0.formattedMessage }.joined(separator: "\n")
    }
}
