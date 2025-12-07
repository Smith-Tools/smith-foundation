import Foundation

// MARK: - SmithErrorHandling Library
//
// A comprehensive error handling system with structured error types,
// actionable guidance, and intelligent error reporting.
// Perfect for embedding in commercial applications that need professional error management.
//

/// Core SmithError protocol for structured error handling
///
/// Provides a consistent interface for errors with actionable guidance,
/// making error handling more user-friendly and debuggable.
///
/// **Key Features:**
/// - Structured error codes and categorization
/// - Actionable user guidance
/// - Multiple output formats (human-readable, JSON)
/// - Error hierarchy and inheritance
/// - Documentation integration
/// - Recovery suggestions
public protocol SmithError: Error, LocalizedError {
    /// Unique error code for identification and logging
    var errorCode: String { get }
    
    /// User-friendly error message
    var userMessage: String { get }
    
    /// Technical details for debugging (optional)
    var technicalDetails: String? { get }
    
    /// Suggested actions to resolve the error
    var suggestedActions: [String] { get }
    
    /// URL to documentation for more help (optional)
    var documentationURL: URL? { get }
    
    /// Whether this error is fatal (cannot be recovered from)
    var isFatal: Bool { get }
}

// MARK: - Base Implementation

/// Base implementation of SmithError with all required properties
public struct BaseSmithError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL?
    public let isFatal: Bool
    
    public var errorDescription: String? {
        var message = "❌ \(userMessage)"
        
        if let technicalDetails = technicalDetails {
            message += "\n\nDetails: \(technicalDetails)"
        }
        
        if !suggestedActions.isEmpty {
            message += "\n\nTo fix:"
            for (index, action) in suggestedActions.enumerated() {
                message += "\n  \(index + 1). \(action)"
            }
        }
        
        if let documentationURL = documentationURL {
            message += "\n\nFor more help: \(documentationURL.absoluteString)"
        }
        
        return message
    }
    
    public var failureReason: String? {
        technicalDetails
    }
    
    public var recoverySuggestion: String? {
        suggestedActions.first
    }
}

// MARK: - Error Code System

/// Standardized error code categories and definitions
public enum SmithErrorCodes {
    // System Errors (SYS_XXX)
    public static let invalidArgument = "SMITH_SYS_001"
    public static let permissionDenied = "SMITH_SYS_002"
    public static let diskSpaceInsufficient = "SMITH_SYS_003"
    public static let memoryInsufficient = "SMITH_SYS_004"
    public static let networkUnavailable = "SMITH_SYS_005"
    
    // Validation Errors (VAL_XXX)
    public static let validationFailed = "SMITH_VAL_001"
    public static let invalidFormat = "SMITH_VAL_002"
    public static let missingRequired = "SMITH_VAL_003"
    public static let constraintViolation = "SMITH_VAL_004"
    
    // Configuration Errors (CFG_XXX)
    public static let configurationMissing = "SMITH_CFG_001"
    public static let configurationInvalid = "SMITH_CFG_002"
    public static let configurationPermission = "SMITH_CFG_003"
    
    // Resource Errors (RES_XXX)
    public static let resourceNotFound = "SMITH_RES_001"
    public static let resourceCorrupted = "SMITH_RES_002"
    public static let resourceLocked = "SMITH_RES_003"
    public static let resourceExpired = "SMITH_RES_004"
    
    // API Errors (API_XXX)
    public static let apiConnectionFailed = "SMITH_API_001"
    public static let apiAuthenticationFailed = "SMITH_API_002"
    public static let apiRateLimited = "SMITH_API_003"
    public static let apiServerError = "SMITH_API_004"
    
    // Business Logic Errors (BIZ_XXX)
    public static let businessRuleViolation = "SMITH_BIZ_001"
    public static let invalidState = "SMITH_BIZ_002"
    public static let operationNotAllowed = "SMITH_BIZ_003"
    
    // Generic Errors (GEN_XXX)
    public static let unknownError = "SMITH_GEN_001"
    public static let operationFailed = "SMITH_GEN_002"
    public static let timeout = "SMITH_GEN_003"
}

// MARK: - Specific Error Types

/// System-level errors
public struct SystemError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/system")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.invalidArgument, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Check system resources and permissions",
            "Verify input parameters",
            "Try running with administrator privileges"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

/// Validation errors
public struct ValidationError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/validation")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.validationFailed, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = false) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Review input parameters for validity",
            "Check expected data formats",
            "Ensure all required fields are provided"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

/// Configuration errors
public struct ConfigurationError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/configuration")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.configurationMissing, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Check configuration file exists and is readable",
            "Verify configuration format and syntax",
            "Ensure proper file permissions"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

/// Resource errors
public struct ResourceError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/resources")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.resourceNotFound, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Verify resource exists and is accessible",
            "Check file permissions and ownership",
            "Ensure resource is not locked by another process"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

/// API errors
public struct APIError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/api")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.apiConnectionFailed, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = true) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Check network connectivity",
            "Verify API endpoint URL and credentials",
            "Review API documentation for correct usage",
            "Try again after some time if rate limited"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

/// Business logic errors
public struct BusinessLogicError: SmithError {
    public let errorCode: String
    public let userMessage: String
    public let technicalDetails: String?
    public let suggestedActions: [String]
    public let documentationURL: URL? = URL(string: "https://smith-tools.dev/docs/errors/business-logic")
    public let isFatal: Bool
    
    public init(code: String = SmithErrorCodes.businessRuleViolation, message: String, technicalDetails: String? = nil, suggestedActions: [String] = [], isFatal: Bool = false) {
        self.errorCode = code
        self.userMessage = message
        self.technicalDetails = technicalDetails
        self.suggestedActions = suggestedActions.isEmpty ? [
            "Review business rules and constraints",
            "Check current application state",
            "Ensure operation is valid in current context"
        ] : suggestedActions
        self.isFatal = isFatal
    }
}

// MARK: - Error Handling Extensions

extension SmithError {
    /// Get formatted output for human-readable display
    public var formattedOutput: String {
        errorDescription ?? userMessage
    }
    
    /// Get JSON representation for structured logging
    public var jsonOutput: [String: Any] {
        var result: [String: Any] = [
            "errorCode": errorCode,
            "userMessage": userMessage,
            "isFatal": isFatal
        ]
        
        if let technicalDetails = technicalDetails {
            result["technicalDetails"] = technicalDetails
        }
        
        if !suggestedActions.isEmpty {
            result["suggestedActions"] = suggestedActions
        }
        
        if let documentationURL = documentationURL {
            result["documentationURL"] = documentationURL.absoluteString
        }
        
        return result
    }
    
    /// Convert to JSON string
    public var jsonString: String {
        if let data = try? JSONSerialization.data(withJSONObject: jsonOutput),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return #"{"error": "Failed to serialize error"}"#
    }
    
    /// Check if error should be logged
    public var shouldLog: Bool {
        // Log all fatal errors and non-trivial non-fatal errors
        return isFatal || !suggestedActions.isEmpty
    }
    
    /// Get error severity level for monitoring
    public var severityLevel: ErrorSeverity {
        switch errorCode.prefix(10) {
        case "SMITH_SYS":
            return .critical
        case "SMITH_API":
            return .high
        case "SMITH_CFG":
            return .high
        case "SMITH_RES":
            return .medium
        case "SMITH_VAL":
            return .low
        case "SMITH_BIZ":
            return .medium
        default:
            return .unknown
        }
    }
}

/// Error severity levels for monitoring and alerting
public enum ErrorSeverity: String, CaseIterable {
    case critical = "critical"
    case high = "high"
    case medium = "medium"
    case low = "low"
    case unknown = "unknown"
}

// MARK: - Error Display Manager

/// Manages error display with multiple output formats
public struct SmithErrorDisplay {
    /// Output format options
    public enum Format {
        case json
        case human
        case auto
    }
    
    /// Display an error with specified format
    public static func display(_ error: SmithError, format: Format = .auto) {
        switch format {
        case .json:
            displayJSON(error)
        case .human:
            displayHuman(error)
        case .auto:
            displayAuto(error)
        }
    }
    
    private static func displayJSON(_ error: SmithError) {
        print(error.jsonString)
    }
    
    private static func displayHuman(_ error: SmithError) {
        print(error.formattedOutput)
    }
    
    private static func displayAuto(_ error: SmithError) {
        // Check if output is TTY or piped
        #if canImport(Glibc)
        let isTTY = isatty(STDOUT_FILENO) != 0
        #elseif canImport(Darwin)
        let isTTY = isatty(STDOUT_FILENO) != 0
        #else
        let isTTY = false
        #endif
        
        if isTTY {
            displayHuman(error)
        } else {
            displayJSON(error)
        }
    }
}

// MARK: - Error Builder

/// Builder pattern for creating errors with fluent interface
public struct SmithErrorBuilder {
    private var errorCode: String = SmithErrorCodes.unknownError
    private var userMessage: String = ""
    private var technicalDetails: String? = nil
    private var suggestedActions: [String] = []
    private var documentationURL: URL? = nil
    private var isFatal: Bool = true
    
    public init() {}
    
    public init(message: String) {
        self.userMessage = message
    }
    
    // Fluent configuration methods
    public func withCode(_ code: String) -> SmithErrorBuilder {
        var builder = self
        builder.errorCode = code
        return builder
    }
    
    public func withMessage(_ message: String) -> SmithErrorBuilder {
        var builder = self
        builder.userMessage = message
        return builder
    }
    
    public func withTechnicalDetails(_ details: String) -> SmithErrorBuilder {
        var builder = self
        builder.technicalDetails = details
        return builder
    }
    
    public func withSuggestedActions(_ actions: [String]) -> SmithErrorBuilder {
        var builder = self
        builder.suggestedActions = actions
        return builder
    }
    
    public func withDocumentationURL(_ url: URL) -> SmithErrorBuilder {
        var builder = self
        builder.documentationURL = url
        return builder
    }
    
    public func asFatal(_ fatal: Bool = true) -> SmithErrorBuilder {
        var builder = self
        builder.isFatal = fatal
        return builder
    }
    
    /// Build the error
    public func build() -> SmithError {
        BaseSmithError(
            errorCode: errorCode,
            userMessage: userMessage,
            technicalDetails: technicalDetails,
            suggestedActions: suggestedActions,
            documentationURL: documentationURL,
            isFatal: isFatal
        )
    }
}

// MARK: - Convenience Error Creators

// Note: Convenience error creators removed due to Swift syntax issues
// Use direct struct initialization instead:
// SystemError(code: ..., message: ..., ...)

// MARK: - Error Handling Utilities

/// Utility functions for common error handling patterns
public enum SmithErrorUtils {
    /// Create a wrapped error with additional context
    public static func wrap<T: Error>(_ error: T, context: String, suggestions: [String] = []) -> SmithError {
        let baseError = BaseSmithError(
            errorCode: SmithErrorCodes.operationFailed,
            userMessage: "Error in \(context): \(error.localizedDescription)",
            technicalDetails: "Wrapped error: \(error)",
            suggestedActions: suggestions.isEmpty ? ["Check underlying error", "Review context operations"] : suggestions,
            documentationURL: nil,
            isFatal: true
        )
        return baseError
    }
    
    /// Convert any error to SmithError
    public static func asSmithError<T: Error>(_ error: T) -> SmithError {
        if let smithError = error as? SmithError {
            return smithError
        }
        
        return BaseSmithError(
            errorCode: SmithErrorCodes.unknownError,
            userMessage: error.localizedDescription,
            technicalDetails: "\(type(of: error)): \(error)",
            suggestedActions: ["Check error details", "Review operation context"],
            documentationURL: nil,
            isFatal: true
        )
    }
    
    /// Check if error should be retried
    public static func shouldRetry(_ error: SmithError) -> Bool {
        // Retry network-related and temporary errors
        return error.errorCode.starts(with: "SMITH_API") ||
               error.errorCode == SmithErrorCodes.timeout ||
               error.errorCode == SmithErrorCodes.resourceLocked
    }
    
    /// Get retry delay for error (in seconds)
    public static func retryDelay(for error: SmithError) -> TimeInterval {
        switch error.errorCode {
        case SmithErrorCodes.apiRateLimited:
            return 60.0 // 1 minute
        case SmithErrorCodes.networkUnavailable:
            return 5.0 // 5 seconds
        case SmithErrorCodes.resourceLocked:
            return 2.0 // 2 seconds
        default:
            return 1.0 // 1 second default
        }
    }
}

// MARK: - Error Logging

/// Error logging configuration and utilities
public struct SmithErrorLogger {
    private var logLevel: LogLevel = .info
    private var includeStackTrace: Bool = false
    private var includeTechnicalDetails: Bool = true
    
    public enum LogLevel: String, CaseIterable {
        case debug = "debug"
        case info = "info"
        case warning = "warning"
        case error = "error"
        case critical = "critical"
    }
    
    public init() {}
    
    public func log(_ error: SmithError, level: LogLevel = .error) {
        guard shouldLog(level: level, error: error) else { return }
        
        let logEntry = createLogEntry(error: error, level: level)
        
        // In a real implementation, this would write to your logging system
        print(logEntry)
    }
    
    private func shouldLog(level: LogLevel, error: SmithError) -> Bool {
        // Simple level checking - in practice, this would be more sophisticated
        return error.shouldLog
    }
    
    private func createLogEntry(error: SmithError, level: LogLevel) -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        var entry: [String: Any] = [
            "timestamp": timestamp,
            "level": level.rawValue,
            "errorCode": error.errorCode,
            "message": error.userMessage
        ]
        
        if includeTechnicalDetails, let details = error.technicalDetails {
            entry["technicalDetails"] = details
        }
        
        if includeStackTrace {
            entry["stackTrace"] = Thread.callStackSymbols.joined(separator: "\n")
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: entry),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        
        return "{\"timestamp\": \"\(timestamp)\", \"level\": \"\(level.rawValue)\", \"message\": \"\(error.userMessage)\"}"
    }
}

// MARK: - Result Extensions

// Note: Result extension removed due to protocol constraint issues
// Core functionality remains intact
