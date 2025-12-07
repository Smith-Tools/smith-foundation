# SmithErrorHandling

A comprehensive, embeddable error handling library for Swift applications that need professional error management with actionable guidance and intelligent error reporting.

## Overview

SmithErrorHandling provides a structured approach to error management that goes beyond basic Swift error handling. It offers actionable user guidance, multiple output formats, comprehensive error categorization, and intelligent error recovery suggestions - perfect for commercial applications that need professional error handling.

## Key Features

### 🎯 Structured Error System
- Comprehensive error categorization (System, Validation, API, Business Logic, etc.)
- Unique error codes for identification and logging
- Hierarchical error types with inheritance support

### 💡 Actionable Guidance
- User-friendly error messages with context
- Specific suggested actions for error resolution
- Documentation links for deeper help

### 📊 Multiple Output Formats
- Human-readable format with emojis and structure
- Machine-readable JSON for logging and monitoring
- Auto-detection based on output context

### 🔄 Error Recovery
- Retry logic with intelligent delay calculation
- Error wrapping with context preservation
- Recovery suggestions and guidance

### 🏗️ Commercial Ready
- Zero external dependencies
- Thread-safe operation
- Cross-platform support (macOS, Linux, iOS, tvOS, watchOS)
- Production-tested in Smith Tools CLI

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Smith-Tools/SmithErrorHandling.git", from: "1.0.0")
]
```

### Xcode

1. Add the package to your Xcode project
2. Import the module:
```swift
import SmithErrorHandling
```

## Quick Start

### Basic Error Handling

```swift
import SmithErrorHandling

// Create a simple error
let error = ValidationError(
    code: SmithErrorCodes.validationFailed,
    message: "Invalid email format",
    technicalDetails: "Expected email format: user@domain.com",
    suggestedActions: [
        "Enter a valid email address",
        "Check for typos in the email",
        "Ensure @ symbol is included"
    ]
)

// Display the error
SmithErrorDisplay.display(error, format: .human)
```

### Error Builder Pattern

```swift
// Fluent error creation
let error = SmithErrorBuilder(message: "Configuration file not found")
    .withCode(SmithErrorCodes.configurationMissing)
    .withTechnicalDetails("Expected: ~/.config/app/config.json")
    .withSuggestedActions([
        "Create the configuration file",
        "Check file permissions",
        "Verify configuration path"
    ])
    .asFatal(true)
    .build()

SmithErrorDisplay.display(error, format: .json)
```

### Specific Error Types

```swift
// System errors
let systemError = SystemError.permissionDenied(
    operation: "write",
    path: "/var/log/app.log"
)

// Validation errors
let validationError = ValidationError.missingRequired(field: "username")

// API errors
let apiError = APIError.authenticationFailed(
    service: "GitHub API",
    reason: "Invalid token"
)

// Resource errors
let resourceError = ResourceError.resourceNotFound(
    resource: "Configuration",
    path: "/etc/app/config.json"
)
```

## Error Categories

### System Errors (SYS_XXX)
Handling system-level issues like permissions, resources, and environment problems.

```swift
// Permission denied
let permissionError = SystemError.permissionDenied(
    operation: "read",
    path: "/sensitive/data.txt"
)

// Insufficient disk space
let diskError = SystemError.insufficientDiskSpace(
    required: 1024 * 1024 * 100, // 100MB
    available: 1024 * 1024 * 10  // 10MB
)

// Network unavailable
let networkError = SystemError.networkUnavailable(service: "API Server")
```

### Validation Errors (VAL_XXX)
Input validation and data integrity issues.

```swift
// Missing required field
let missingError = ValidationError.missingRequired(field: "email")

// Invalid format
let formatError = ValidationError.invalidFormat(
    field: "phone",
    expected: "+1-XXX-XXX-XXXX",
    actual: "123-456-7890"
)

// Constraint violation
let constraintError = ValidationError.constraintViolation(
    field: "age",
    constraint: "must be >= 18",
    value: 16
)
```

### API Errors (API_XXX)
External service integration and API-related issues.

```swift
// Authentication failure
let authError = APIError.authenticationFailed(
    service: "Stripe API",
    reason: "Expired API key"
)

// Rate limiting
let rateError = APIError.rateLimited(
    service: "GitHub API",
    retryAfter: 60
)

// Connection failure
let connError = APIError(
    code: SmithErrorCodes.apiConnectionFailed,
    message: "Failed to connect to payment service",
    suggestedActions: [
        "Check internet connection",
        "Verify service endpoint",
        "Try again later"
    ]
)
```

### Resource Errors (RES_XXX)
File system, database, and external resource issues.

```swift
// Resource not found
let notFoundError = ResourceError.resourceNotFound(
    resource: "User Database",
    path: "/data/users.db"
)

// Corrupted resource
let corruptedError = ResourceError.resourceCorrupted(
    resource: "Configuration File",
    reason: "Invalid JSON syntax"
)

// Resource locked
let lockedError = ResourceError(
    code: SmithErrorCodes.resourceLocked,
    message: "Database is locked by another process",
    technicalDetails: "SQLite database /data/app.db is locked",
    suggestedActions: [
        "Close other applications using the database",
        "Wait for current operations to complete",
        "Restart the application if needed"
    ]
)
```

### Business Logic Errors (BIZ_XXX)
Application-specific business rule violations.

```swift
// Business rule violation
let businessError = BusinessLogicError(
    code: SmithErrorCodes.businessRuleViolation,
    message: "Insufficient funds for transaction",
    technicalDetails: "Balance: $50, Required: $75",
    suggestedActions: [
        "Add funds to account",
        "Reduce transaction amount",
        "Use alternative payment method"
    ]
)

// Invalid state
let stateError = BusinessLogicError(
    code: SmithErrorCodes.invalidState,
    message: "Cannot process order in current state",
    technicalDetails: "Order is cancelled, cannot ship",
    suggestedActions: [
        "Create a new order",
        "Restore cancelled order",
        "Check order status"
    ]
)
```

## Advanced Usage

### Error Wrapping

```swift
// Wrap existing errors with context
do {
    try performNetworkOperation()
} catch {
    let wrappedError = SmithErrorUtils.wrap(
        error,
        context: "User profile update",
        suggestions: [
            "Check network connection",
            "Verify user permissions",
            "Try again in a few minutes"
        ]
    )
    
    SmithErrorDisplay.display(wrappedError, format: .human)
}
```

### Error Logging

```swift
// Configure error logging
var logger = SmithErrorLogger()
logger.logLevel = .error
logger.includeStackTrace = true

// Log errors with structured data
logger.log(systemError, level: .critical)
logger.log(validationError, level: .warning)
```

### Error Recovery

```swift
// Check if error should be retried
if SmithErrorUtils.shouldRetry(apiError) {
    let delay = SmithErrorUtils.retryDelay(for: apiError)
    print("Retrying after \(delay) seconds...")
    
    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
        // Retry the operation
        performAPICall()
    }
}
```

### Converting Standard Errors

```swift
// Convert any error to SmithError
do {
    try JSONDecoder().decode(MyType.self, from: data)
} catch {
    let smithError = SmithErrorUtils.asSmithError(error)
    // Now you have structured error handling
    SmithErrorDisplay.display(smithError, format: .json)
}
```

## API Reference

### SmithError Protocol

```swift
public protocol SmithError: Error, LocalizedError {
    var errorCode: String { get }
    var userMessage: String { get }
    var technicalDetails: String? { get }
    var suggestedActions: [String] { get }
    var documentationURL: URL? { get }
    var isFatal: Bool { get }
}
```

### Error Types

- `SystemError` - System-level issues
- `ValidationError` - Input validation problems
- `ConfigurationError` - Configuration-related errors
- `ResourceError` - File system and resource issues
- `APIError` - External service integration errors
- `BusinessLogicError` - Business rule violations

### SmithErrorDisplay

```swift
public struct SmithErrorDisplay {
    public enum Format { case json, human, auto }
    public static func display(_ error: SmithError, format: Format)
}
```

### SmithErrorBuilder

```swift
public struct SmithErrorBuilder {
    public init(message: String)
    public func withCode(_ code: String) -> SmithErrorBuilder
    public func withMessage(_ message: String) -> SmithErrorBuilder
    public func withTechnicalDetails(_ details: String) -> SmithErrorBuilder
    public func withSuggestedActions(_ actions: [String]) -> SmithErrorBuilder
    public func asFatal(_ fatal: Bool) -> SmithErrorBuilder
    public func build() -> SmithError
}
```

### SmithErrorUtils

```swift
public enum SmithErrorUtils {
    public static func wrap<T: Error>(_ error: T, context: String, suggestions: [String]) -> SmithError
    public static func asSmithError<T: Error>(_ error: T) -> SmithError
    public static func shouldRetry(_ error: SmithError) -> Bool
    public static func retryDelay(for error: SmithError) -> TimeInterval
}
```

## Use Cases

### 1. API Client Libraries

```swift
class APIClient {
    func fetchData<T: Decodable>(_ type: T.Type, from endpoint: String) -> Result<T, SmithError> {
        do {
            let data = try await performRequest(endpoint)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            let smithError = SmithErrorUtils.wrap(
                error,
                context: "API request to \(endpoint)",
                suggestions: [
                    "Check network connectivity",
                    "Verify endpoint URL",
                    "Check authentication"
                ]
            )
            return .failure(smithError)
        }
    }
}
```

### 2. File Processing Applications

```swift
struct FileProcessor {
    func processFile(at path: String) -> Result<FileResult, SmithError> {
        guard FileManager.default.fileExists(atPath: path) else {
            let error = ResourceError.resourceNotFound(
                resource: "Input file",
                path: path
            )
            return .failure(error)
        }
        
        do {
            let content = try String(contentsOfFile: path)
            let result = try parseContent(content)
            return .success(result)
        } catch {
            let error = ResourceError.resourceCorrupted(
                resource: "Input file",
                reason: error.localizedDescription
            )
            return .failure(error)
        }
    }
}
```

### 3. Configuration Management

```swift
struct ConfigurationManager {
    func loadConfiguration() -> Result<AppConfig, SmithError> {
        let configPath = getConfigPath()
        
        guard FileManager.default.isReadableFile(atPath: configPath) else {
            let error = ConfigurationError.configurationMissing(
                message: "Configuration file not found or not readable",
                technicalDetails: "Expected at: \(configPath)",
                suggestedActions: [
                    "Create configuration file",
                    "Check file permissions",
                    "Verify configuration path"
                ]
            )
            return .failure(error)
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            return .success(config)
        } catch {
            let error = ConfigurationError.configurationInvalid(
                message: "Invalid configuration format",
                technicalDetails: error.localizedDescription,
                suggestedActions: [
                    "Check JSON syntax",
                    "Validate configuration schema",
                    "Refer to configuration documentation"
                ]
            )
            return .failure(error)
        }
    }
}
```

### 4. Data Validation Frameworks

```swift
struct Validator<T> {
    func validate(_ input: T) -> Result<T, SmithError> {
        var errors: [SmithError] = []
        
        // Check required fields
        if let requiredFields = getRequiredFields() {
            for field in requiredFields {
                if !hasValue(input, field: field) {
                    errors.append(ValidationError.missingRequired(field: field))
                }
            }
        }
        
        // Check format constraints
        if let formatRules = getFormatRules() {
            for rule in formatRules {
                if !matchesFormat(input, rule: rule) {
                    errors.append(ValidationError.invalidFormat(
                        field: rule.field,
                        expected: rule.expected,
                        actual: getValue(input, field: rule.field)
                    ))
                }
            }
        }
        
        // Check business constraints
        if let businessRules = getBusinessRules() {
            for rule in businessRules {
                if !satisfiesBusinessRule(input, rule: rule) {
                    errors.append(BusinessLogicError.businessRuleViolation(
                        message: "Business rule violation: \(rule.description)",
                        technicalDetails: "Rule: \(rule.name)",
                        suggestedActions: rule.suggestions
                    ))
                }
            }
        }
        
        if !errors.isEmpty {
            return .failure(combineErrors(errors))
        }
        
        return .success(input)
    }
}
```

## Error Output Examples

### Human-Readable Format

```
❌ Configuration file not found

Details: Expected at: ~/.config/app/config.json

To fix:
  1. Create the configuration file
  2. Check file permissions
  3. Verify configuration path

For more help: https://smith-tools.dev/docs/errors/configuration

Run with --help for more options
```

### JSON Format

```json
{
  "errorCode": "SMITH_CFG_001",
  "userMessage": "Configuration file not found or not readable",
  "technicalDetails": "Expected at: ~/.config/app/config.json",
  "suggestedActions": [
    "Create configuration file",
    "Check file permissions",
    "Verify configuration path"
  ],
  "documentationURL": "https://smith-tools.dev/docs/errors/configuration",
  "isFatal": true
}
```

### Auto-Detection

```swift
// Automatically selects format based on output context
SmithErrorDisplay.display(error, format: .auto)

// Terminal: Human-readable with colors and emojis
// Script/API: JSON format for processing
```

## Error Code Reference

| Category | Prefix | Description |
|----------|---------|-------------|
| System | SMITH_SYS | System-level errors |
| Validation | SMITH_VAL | Input validation errors |
| Configuration | SMITH_CFG | Configuration errors |
| Resource | SMITH_RES | Resource handling errors |
| API | SMITH_API | External API errors |
| Business Logic | SMITH_BIZ | Business rule violations |
| Generic | SMITH_GEN | Generic error codes |

## Best Practices

### Error Message Design
- **Be specific**: Clear, actionable messages
- **Include context**: Where and why the error occurred
- **Provide solutions**: Concrete steps to resolve
- **Use appropriate severity**: Not all errors are fatal

### Error Categorization
- **Choose the right type**: System, Validation, API, etc.
- **Use appropriate codes**: Follow the error code conventions
- **Be consistent**: Same error types should have consistent structure

### Error Handling Patterns
- **Wrap external errors**: Always wrap third-party errors with context
- **Provide recovery**: Include retry logic where appropriate
- **Log appropriately**: Use structured logging for monitoring

### Performance Considerations
- **Lazy evaluation**: Only create error details when needed
- **Memory efficiency**: Avoid storing unnecessary context
- **Thread safety**: All operations should be thread-safe

## Migration from Standard Errors

### Before (Standard Error Handling)

```swift
enum MyError: Error {
    case invalidInput(String)
    case networkError(String)
    case fileNotFound(String)
}

do {
    try processInput(data)
} catch MyError.invalidInput(let message) {
    print("Error: \(message)")
} catch MyError.networkError(let message) {
    print("Error: \(message)")
} catch {
    print("Unknown error: \(error)")
}
```

### After (SmithErrorHandling)

```swift
// Consistent error structure
let validationError = ValidationError.invalidFormat(
    field: "email",
    expected: "user@domain.com",
    actual: "invalid-email"
)

SmithErrorDisplay.display(validationError, format: .auto)

// Or wrap existing errors
do {
    try processInput(data)
} catch {
    let smithError = SmithErrorUtils.wrap(
        error,
        context: "Input processing",
        suggestions: ["Check input format", "Verify required fields"]
    )
    SmithErrorDisplay.display(smithError, format: .json)
}
```

## Integration with Logging Systems

### SwiftLog Integration

```swift
import Logging

struct SmithErrorLoggerAdapter {
    private let logger: Logger
    
    func log(_ error: SmithError, level: Logger.Level = .error) {
        var metadata = Logger.Metadata()
        metadata["errorCode"] = .string(error.errorCode)
        metadata["isFatal"] = .string("\(error.isFatal)")
        metadata["severity"] = .string(error.severityLevel.rawValue)
        
        if let details = error.technicalDetails {
            metadata["technicalDetails"] = .string(details)
        }
        
        logger.log(level: level, "\(error.userMessage)", metadata: metadata)
    }
}
```

### Custom Logging Integration

```swift
struct CustomErrorLogger {
    func log(_ error: SmithError, to service: LogService) {
        let logEntry = ErrorLogEntry(
            timestamp: Date(),
            level: mapSeverity(error.severityLevel),
            errorCode: error.errorCode,
            message: error.userMessage,
            technicalDetails: error.technicalDetails,
            suggestedActions: error.suggestedActions,
            metadata: extractMetadata(from: error)
        )
        
        service.submit(logEntry)
    }
}
```

## Testing

### Unit Testing Errors

```swift
func testValidationErrorCreation() {
    let error = ValidationError.missingRequired(field: "username")
    
    XCTAssertEqual(error.errorCode, SmithErrorCodes.missingRequired)
    XCTAssertEqual(error.userMessage, "Required field missing: username")
    XCTAssertFalse(error.isFatal)
    XCTAssertFalse(error.suggestedActions.isEmpty)
}

func testErrorFormatting() {
    let error = SystemError.permissionDenied(operation: "read", path: "/file.txt")
    
    let humanOutput = error.formattedOutput
    XCTAssertTrue(humanOutput.contains("Permission denied"))
    XCTAssertTrue(humanOutput.contains("read"))
    
    let jsonOutput = error.jsonOutput
    XCTAssertEqual(jsonOutput["errorCode"] as? String, error.errorCode)
    XCTAssertEqual(jsonOutput["userMessage"] as? String, error.userMessage)
}
```

### Integration Testing

```swift
func testErrorDisplay() {
    let error = APIError.rateLimited(service: "Test API", retryAfter: 60)
    
    // Test human-readable format
    SmithErrorDisplay.display(error, format: .human)
    // Verify output contains expected elements
    
    // Test JSON format
    SmithErrorDisplay.display(error, format: .json)
    // Verify JSON structure
}
```

## Platform Support

### Supported Platforms
- **macOS**: 12.0+
- **iOS**: 15.0+
- **tvOS**: 15.0+
- **watchOS**: 8.0+
- **Linux**: Any Swift-supported distribution

### Cross-Platform Features
- ✅ All error types work across platforms
- ✅ JSON serialization is platform-agnostic
- ✅ File system error handling adapts to platform
- ✅ Network error handling uses standard APIs

## Error Monitoring Integration

### Application Monitoring

```swift
struct ErrorMonitor {
    private let errorCount = Atomic<Int>(0)
    
    func track(_ error: SmithError) {
        errorCount.wrappingIncrement()
        
        // Send to monitoring service
        switch error.severityLevel {
        case .critical, .high:
            sendToAlerting(error)
        case .medium:
            sendToDashboard(error)
        case .low:
            sendToLogging(error)
        case .unknown:
            sendToLogging(error)
        }
    }
    
    func getErrorRate() -> Double {
        return Double(errorCount.value) / getUptime()
    }
}
```

### Performance Monitoring

```swift
struct ErrorPerformanceTracker {
    private var errorTimes: [TimeInterval] = []
    
    func record(error: SmithError, duration: TimeInterval) {
        errorTimes.append(duration)
        
        // Track slow error recovery
        if duration > 5.0 {
            logSlowRecovery(error, duration: duration)
        }
        
        // Track error frequency per type
        trackErrorFrequency(error)
    }
    
    func getAverageRecoveryTime() -> TimeInterval {
        errorTimes.reduce(0, +) / Double(errorTimes.count)
    }
}
```

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup

```bash
git clone https://github.com/Smith-Tools/SmithErrorHandling.git
cd SmithErrorHandling
swift test
swift build
```

### Adding New Error Types

1. Inherit from `SmithError` or appropriate base type
2. Follow error code naming conventions
3. Provide helpful suggested actions
4. Add documentation links
5. Include test coverage

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Documentation**: https://smith-tools.dev/docs/libraries/error-handling
- **Issues**: https://github.com/Smith-Tools/SmithErrorHandling/issues
- **Discussions**: https://github.com/Smith-Tools/SmithErrorHandling/discussions

---

Built with ❤️ by the Smith Tools team for the Swift community.
