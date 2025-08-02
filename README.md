# TrustPin iOS SDK

[![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-TrustPin-green.svg)](LICENSE)

[TrustPin](https://trustpin.cloud/) is a modern, lightweight, and secure iOS/macOS library designed to enforce **SSL Certificate Pinning** for native applications. Built with Swift Concurrency and following OWASP security recommendations, TrustPin prevents man-in-the-middle (MITM) attacks by ensuring server authenticity at the TLS level.

## 🚀 Key Features

- ✅ **Modern Swift Concurrency** - Built with `async`/`await` for seamless integration
- ✅ **Flexible Pinning Modes** - Strict validation or permissive mode for development
- ✅ **Multiple Hash Algorithms** - SHA-256 and SHA-512 certificate validation
- ✅ **Signed Configuration** - Cryptographically signed pinning configurations
- ✅ **URLSession Integration** - Drop-in `URLSessionDelegate` for automatic validation
- ✅ **Intelligent Caching** - 10-minute configuration cache with stale fallback
- ✅ **Comprehensive Logging** - Configurable log levels for debugging and monitoring
- ✅ **Cross-Platform** - iOS, macOS, watchOS, tvOS, and Mac Catalyst support
- ✅ **FIDO/WebAuthn Support** - Enhanced security with FIDO signature verification

---

## 📋 Platform Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 13.0+ |
| macOS | 13.0+ |
| watchOS | 7.0+ |
| tvOS | 13.0+ |
| Mac Catalyst | 13.0+ |

**Required:** Swift 5.5+ for async/await support

---

## 📦 Installation

### Swift Package Manager (Recommended)

Add TrustPin to your project using Xcode:

1. **File → Add Package Dependencies**
2. **Enter repository URL:**
   ```
   https://github.com/trustpin-cloud/TrustPin-Swift.binary
   ```
3. **Select version:** `0.7.0` or later

#### Manual Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/trustpin-cloud/TrustPin-Swift.binary", from: "0.7.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "TrustPinKit", package: "TrustPin-Swift")
        ]
    )
]
```

---

## 🔧 Quick Setup

### 1. Import and Configure

```swift
import TrustPinKit

// Configure TrustPin with your project credentials
try await TrustPin.setup(
    organizationId: "your-org-id",
    projectId: "your-project-id", 
    publicKey: "your-base64-public-key",
    mode: .strict  // Recommended for production
)
```

> 💡 **Find your credentials** in the [TrustPin Dashboard](https://app.trustpin.cloud)

> ⚠️ **Important**: `TrustPin.setup()` must be called only once during your app's lifecycle. Concurrent setup calls are not supported and will throw `TrustPinErrors.invalidProjectConfig`. If already initialized, subsequent calls will return immediately.

### 2. Choose Your Pinning Mode

TrustPin offers two validation modes:

#### Strict Mode (Recommended for Production)
```swift
try await TrustPin.setup(
    // ... your credentials
    mode: .strict  // Throws error for unregistered domains
)
```

#### Permissive Mode (Development & Testing)
```swift
try await TrustPin.setup(
    // ... your credentials  
    mode: .permissive  // Allows unregistered domains to bypass pinning
)
```

---

## 🛠 Usage Examples

### Automatic URLSession Integration

The simplest way to add certificate pinning to your network requests:

```swift
import TrustPinKit

class NetworkManager {
    private let trustPinDelegate = TrustPinURLSessionDelegate()
    private lazy var session = URLSession(
        configuration: .default,
        delegate: trustPinDelegate,
        delegateQueue: nil
    )
    
    func fetchData() async throws -> Data {
        let url = URL(string: "https://api.example.com/data")!
        let (data, _) = try await session.data(from: url)
        return data
    }
}
```

### Manual Certificate Verification

For custom networking stacks or certificate inspection:

```swift
import TrustPinKit

// Verify a PEM-encoded certificate for a specific domain
let domain = "api.example.com"
let pemCertificate = """
-----BEGIN CERTIFICATE-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END CERTIFICATE-----
"""

do {
    try await TrustPin.verify(domain: domain, certificate: pemCertificate)
    print("✅ Certificate is valid and matches configured pins")
} catch TrustPinErrors.domainNotRegistered {
    print("⚠️ Domain not configured for pinning")
} catch TrustPinErrors.pinsMismatch {
    print("❌ Certificate doesn't match any configured pins")
} catch {
    print("💥 Verification failed: \(error)")
}
```

### Setup and Initialization

```swift
import TrustPinKit

class AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Task {
            do {
                // Setup TrustPin once during app launch
                try await TrustPin.setup(
                    organizationId: "your-org-id",
                    projectId: "your-project-id",
                    publicKey: "your-public-key",
                    mode: .strict
                )
                print("✅ TrustPin initialized successfully")
            } catch {
                print("❌ TrustPin setup failed: \(error)")
            }
        }
        
        return true
    }
}
```

### Advanced Configuration

```swift
import TrustPinKit

// Enable debug logging before setup
await TrustPin.set(logLevel: .debug)

// Setup with permissive mode for staging environment
try await TrustPin.setup(
    organizationId: "staging-org-id",
    projectId: "staging-project-id",
    publicKey: "staging-public-key",
    mode: .permissive
)
```

---

## 🔧 Integration Examples

### With Alamofire

```swift
import Alamofire
import TrustPinKit

// Create a custom SessionDelegate that extends TrustPinURLSessionDelegate
class TrustPinAlamofireDelegate: TrustPinURLSessionDelegate, SessionDelegate {
    // TrustPinURLSessionDelegate handles the certificate validation
}

let trustPinDelegate = TrustPinAlamofireDelegate()
let session = Session(
    configuration: .default,
    delegate: trustPinDelegate,
    rootQueue: DispatchQueue(label: "com.trustpin.alamofire.queue"),
    startRequestsImmediately: true
)

// Use the session for your requests
let response = try await session.request("https://api.example.com/data")
    .validate()
    .serializingData()
    .value
```

### With Custom URLSession

```swift
import Foundation
import TrustPinKit

class SecureNetworkClient {
    private let trustPinDelegate = TrustPinURLSessionDelegate()
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config, delegate: trustPinDelegate, delegateQueue: nil)
    }()
    
    func performSecureRequest(to url: URL) async throws -> (Data, URLResponse) {
        return try await urlSession.data(from: url)
    }
}
```

---

## 🎯 Pinning Modes Explained

| Mode | Behavior | Use Case |
|------|----------|----------|
| **`.strict`** | ❌ Throws `TrustPinErrors.domainNotRegistered` for unregistered domains | **Production environments** where all connections should be validated |
| **`.permissive`** | ✅ Allows unregistered domains to bypass pinning | **Development/Testing** or apps connecting to dynamic domains |

### When to Use Each Mode

#### Strict Mode (`.strict`)
- ✅ **Production applications**
- ✅ **High-security environments**  
- ✅ **Known, fixed set of API endpoints**
- ✅ **Compliance requirements**

#### Permissive Mode (`.permissive`)
- ✅ **Development and staging**
- ✅ **Applications with dynamic/unknown endpoints**
- ✅ **Gradual migration to certificate pinning**
- ✅ **Third-party SDK integrations**

---

## 📊 Error Handling

TrustPin provides detailed error types for proper handling:

```swift
do {
    try await TrustPin.verify(domain: "api.example.com", certificate: pemCert)
} catch TrustPinErrors.domainNotRegistered {
    // Domain not configured in TrustPin (only in strict mode)
    handleUnregisteredDomain()
} catch TrustPinErrors.pinsMismatch {
    // Certificate doesn't match configured pins - possible MITM
    handleSecurityThreat()
} catch TrustPinErrors.allPinsExpired {
    // All pins for domain have expired
    handleExpiredPins()
} catch TrustPinErrors.invalidServerCert {
    // Certificate format is invalid
    handleInvalidCertificate()
} catch TrustPinErrors.invalidProjectConfig {
    // Setup parameters are invalid
    handleConfigurationError()
} catch TrustPinErrors.errorFetchingPinningInfo {
    // Network error fetching configuration
    handleNetworkError()
} catch TrustPinErrors.configurationValidationFailed {
    // configuration signature validation failed
    handleSignatureError()
}
```

---

## 🔍 Logging and Debugging

TrustPin provides comprehensive logging for debugging and monitoring:

```swift
// Set log level before setup
await TrustPin.set(logLevel: .debug)

// Available log levels:
// .none     - No logging
// .error    - Errors only  
// .info     - Errors and informational messages
// .debug    - All messages including debug information
```

### Example Debug Output

```
[14:30:15] [DEBUG] Starting certificate verification for domain: api.example.com
[14:30:15] [DEBUG] Sanitized domain: api.example.com
[14:30:15] [INFO] Using cached configuration
[14:30:15] [DEBUG] Found domain configuration with 2 pins
[14:30:15] [DEBUG] Certificate hash matches sha256 pin for domain api.example.com
[14:30:15] [INFO] Valid pin found for api.example.com
```

---

## 🏗 Best Practices

### Setup and Initialization

1. **Call `TrustPin.setup()` only once** during app launch (typically in `AppDelegate`)
2. **Handle setup errors gracefully** - don't block app launch if TrustPin fails
3. **Set log level before setup** for complete logging coverage
4. **Never call setup concurrently** - it's not supported and will throw errors
5. **Use Task/async context** for setup in synchronous app lifecycle methods

### Security Recommendations

1. **Always use `.strict` mode in production**
2. **Rotate pins before expiration**
3. **Monitor pin validation failures**
4. **Use HTTPS for all pinned domains**
5. **Keep public keys secure and version-controlled**

### Performance Optimization

1. **Cache TrustPin configuration** (handled automatically)
2. **Reuse URLSession instances** with TrustPin delegate
3. **Use appropriate log levels** (`.error` or `.none` in production)
4. **Initialize early** to avoid setup delays during first network requests

### Development Workflow

1. **Start with `.permissive` mode** during development
2. **Test all endpoints** with pinning enabled
3. **Validate pin configurations** in staging
4. **Switch to `.strict` mode** for production releases
5. **Use debug logging** to troubleshoot pinning issues

---

## 🔧 Advanced Configuration

### Custom URLSession Configuration

```swift
let trustPinDelegate = TrustPinURLSessionDelegate()

let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30
configuration.timeoutIntervalForResource = 300
configuration.httpMaximumConnectionsPerHost = 4

let session = URLSession(
    configuration: configuration,
    delegate: trustPinDelegate,
    delegateQueue: OperationQueue()
)
```

### Error Recovery Strategies

```swift
func performNetworkRequest() async -> Data? {
    do {
        return try await secureNetworkRequest()
    } catch TrustPinErrors.domainNotRegistered {
        // Log security event but continue in permissive mode
        logger.warning("Unregistered domain accessed")
        return try await fallbackNetworkRequest()
    } catch TrustPinErrors.pinsMismatch {
        // This is a serious security issue - do not retry
        logger.critical("Certificate pinning failed - possible MITM attack")
        throw SecurityError.potentialMITMAttack
    }
}
```

### FIDO/WebAuthn Configuration

TrustPin supports enhanced security through FIDO/WebAuthn signatures for configuration validation:

```swift
// TrustPin automatically detects and validates FIDO-signed configurations
// No additional setup required - the SDK handles WebAuthn verification internally

// When your TrustPin configuration is signed with FIDO credentials:
// 1. The SDK detects the FIDO flag in the JWS header
// 2. Validates the WebAuthn signature using authenticator data
// 3. Verifies the challenge matches the signing input
// 4. Ensures cryptographic integrity of the configuration

// This provides an additional layer of security for configuration distribution
```

---

## 📚 API Reference

### Core Classes

- **`TrustPin`** - Main SDK interface for setup and verification
- **`TrustPinMode`** - Enum defining pinning behavior modes
- **`TrustPinURLSessionDelegate`** - URLSession delegate for automatic validation
- **`TrustPinErrors`** - Error types for detailed error handling
- **`TrustPinLogLevel`** - Logging configuration options

### Key Methods

```swift
// Setup and configuration
static func setup(organizationId: String, projectId: String, publicKey: String, mode: TrustPinMode) async throws

// Manual verification  
static func verify(domain: String, certificate: String) async throws

// Logging configuration
static func set(logLevel: TrustPinLogLevel)
```

---

## 🐛 Troubleshooting

### Common Issues

#### **Setup Fails with `invalidProjectConfig`**
- ✅ Verify organization ID, project ID, and public key are correct
- ✅ Check for extra whitespace or newlines in credentials
- ✅ Ensure public key is properly base64-encoded
- ✅ **Avoid concurrent setup calls** - only call `TrustPin.setup()` once per app lifecycle
- ✅ **Check for multiple setup attempts** - if already initialized, subsequent calls return immediately

#### **Certificate Verification Fails**
- ✅ Confirm domain is registered in TrustPin dashboard
- ✅ Check certificate format (must be PEM-encoded)
- ✅ Verify pins haven't expired
- ✅ Test with `.permissive` mode first

#### **Network Requests Hang**
- ✅ Ensure you're using the correct URLSession delegate
- ✅ Check for retain cycles with URLSession
- ✅ Verify network connectivity

### Debug Steps

1. **Enable debug logging**: `await TrustPin.set(logLevel: .debug)`
2. **Test with permissive mode** first
3. **Verify credentials** in TrustPin dashboard
4. **Check certificate expiration** dates

---

## 📖 Documentation

- **API Documentation**: [TrustPin iOS SDK Docs](https://trustpin-cloud.github.io/TrustPin-Swift/)
- **Dashboard**: [TrustPin Cloud Console](https://app.trustpin.cloud)
- **Support**: [Contact TrustPin](https://trustpin.cloud/)

---

## 📝 License

This project is licensed under the TrustPin Binary License Agreement - see the [LICENSE](LICENSE) file for details.

**Commercial License**: For enterprise licensing or custom agreements, contact [contact@trustpin.cloud](mailto:contact@trustpin.cloud)

**Attribution Required**: When using this software, you must display "Uses TrustPin™ technology – https://trustpin.cloud" in your application.

---

## 🤝 Support & Feedback

We welcome your feedback and questions!

- 📧 **Email**: [support@trustpin.cloud](mailto:support@trustpin.cloud)
- 🌐 **Website**: [https://trustpin.cloud](https://trustpin.cloud)
- 📋 **Issues**: [GitHub Issues](https://github.com/trustpin-cloud/TrustPin-Swift.binary/issues)

---

*Built with ❤️ by the TrustPin team*