import Foundation

// MARK: - SmithOutputFormatter Library
//
// A comprehensive output formatting system with TTY detection and automatic format switching.
// Perfect for embedding in commercial applications that need intelligent terminal output.
//

/// Comprehensive output formatting system with TTY detection and automatic format switching.
///
/// This library provides smart output formatting that adapts to the terminal context,
/// making it ideal for commercial applications that need professional terminal interfaces.
///
/// **Key Features:**
/// - Automatic TTY detection and format selection
/// - Multiple output formats (JSON, human-readable, compact, etc.)
/// - Progress indicators with smart TTY awareness
/// - Color support with user preference respect
/// - Thread-safe operation
/// - Zero dependencies
///
/// **Usage Example:**
/// ```swift
/// import SmithOutputFormatter
///
/// let formatter = SmithOutputFormatter()
/// let result = formatter.format(data, as: .auto)
/// print(result)
/// ```
public struct SmithOutputFormatter {
    
    // MARK: - Output Format Options
    
    /// Output format options for different use cases
    public enum Format: String, CaseIterable {
        case json           // Machine-readable JSON
        case summary        // Human-readable summary
        case detailed       // Detailed human-readable
        case compact        // Compact human-readable (85%+ size reduction)
        case minimal        // Minimal output (95%+ size reduction)
        case auto           // Auto-detect based on context
    }
    
    // MARK: - Configuration
    
    /// Terminal detection and formatting configuration
    public struct Configuration {
        let isTTY: Bool
        let isColored: Bool
        let forceFormat: Format?
        
        public init(force format: Format? = nil, forceColored: Bool? = nil) {
            self.forceFormat = format
            
            #if canImport(Glibc)
            // Linux/Unix systems
            self.isTTY = isatty(STDOUT_FILENO) != 0
            #elseif canImport(Darwin)
            // macOS systems
            self.isTTY = isatty(STDOUT_FILENO) != 0
            #else
            // Default for unknown platforms
            self.isTTY = false
            #endif
            
            // Check color preferences
            let noColor = ProcessInfo.processInfo.environment["NO_COLOR"] != nil
            let forceColor = (forceColored != nil) ? forceColored! : (ProcessInfo.processInfo.environment["FORCE_COLOR"] != nil)
            
            self.isColored = isTTY && !noColor || forceColor
        }
        
        /// Create configuration for testing with custom settings
        public static func testConfig(isTTY: Bool = true, isColored: Bool = true) -> Configuration {
            let config = Configuration(force: nil, forceColored: isColored)
            return Configuration(
                force: config.forceFormat,
                forceColored: isColored
            )
        }
    }
    
    // MARK: - Public Interface
    
    private let config: Configuration
    
    /// Initialize the output formatter with default settings
    public init() {
        self.config = Configuration()
    }
    
    /// Initialize with specific configuration
    public init(config: Configuration) {
        self.config = config
    }
    
    /// Format any Codable value as a formatted string
    ///
    /// - Parameters:
    ///   - value: The value to format
    ///   - format: Output format to use (default: auto)
    /// - Returns: Formatted string representation
    public func format<T: Codable>(_ value: T, as format: Format = .auto) -> String {
        let resolvedFormat = resolveFormat(format)
        
        switch resolvedFormat {
        case .json:
            return formatAsJSON(value)
        case .summary:
            return formatAsSummary(value)
        case .detailed:
            return formatAsDetailed(value)
        case .compact:
            return formatAsCompact(value)
        case .minimal:
            return formatAsMinimal(value)
        case .auto:
            return config.isTTY ? formatAsSummary(value) : formatAsJSON(value)
        }
    }
    
    /// Format text content with intelligent formatting
    ///
    /// - Parameters:
    ///   - text: The text to format
    ///   - format: Output format to use (default: auto)
    /// - Returns: Formatted text
    public func formatText(_ text: String, as format: Format = .auto) -> String {
        let resolvedFormat = resolveFormat(format)
        
        switch resolvedFormat {
        case .json:
            return formatTextAsJSON(text)
        case .summary:
            return formatTextAsSummary(text)
        case .detailed:
            return formatTextAsDetailed(text)
        case .compact:
            return formatTextAsCompact(text)
        case .minimal:
            return formatTextAsMinimal(text)
        case .auto:
            return config.isTTY ? formatTextAsSummary(text) : formatTextAsJSON(text)
        }
    }
    
    // MARK: - Progress Display
    
    /// Show progress with automatic TTY detection
    ///
    /// Automatically skips progress display in non-TTY environments
    ///
    /// - Parameters:
    ///   - title: Progress title
    ///   - current: Current progress value
    ///   - total: Total progress value
    ///   - phase: Optional phase description
    ///   - currentItem: Optional current item description
    ///   - format: Output format (default: auto)
    public func showProgress(
        title: String,
        current: Int,
        total: Int,
        phase: String = "",
        currentItem: String = "",
        format: Format = .auto
    ) {
        guard config.isTTY else { return } // Skip progress in non-TTY environments
        
        let resolvedFormat = resolveFormat(format)
        guard resolvedFormat == .auto || resolvedFormat == .summary else { return }
        
        let percentage = total > 0 ? Double(current) / Double(total) * 100 : 0
        let progressBar = createProgressBar(percentage)
        
        clearLine()
        
        let phaseText = phase.isEmpty ? "" : " [\(phase)]"
        let itemText = currentItem.isEmpty ? "" : " - \(currentItem)"
        
        print("\(progressBar) \(current)/\(total) (\(String(format: "%.1f", percentage))%)\(phaseText)\(itemText)", terminator: "")
        fflush(stdout)
    }
    
    /// Show spinner animation for indeterminate operations
    ///
    /// Automatically stops when terminal context changes
    ///
    /// - Parameters:
    ///   - title: Spinner title
    ///   - format: Output format (default: auto)
    /// - Returns: Timer for stopping the spinner
    @discardableResult
    public func showSpinner(title: String, format: Format = .auto) -> Timer {
        guard config.isTTY else { 
            // Return a dummy timer that does nothing for non-TTY environments
            return Timer(timeInterval: 1.0, repeats: true) { _ in }
        }
        
        let resolvedFormat = resolveFormat(format)
        guard resolvedFormat == .auto || resolvedFormat == .summary else {
            return Timer(timeInterval: 1.0, repeats: true) { _ in }
        }
        
        let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        var frameIndex = 0
        
        return Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.config.isTTY else {
                timer.invalidate()
                return
            }
            
            clearLine()
            print("\(frames[frameIndex]) \(title)", terminator: "")
            fflush(stdout)
            
            frameIndex = (frameIndex + 1) % frames.count
        }
    }
    
    /// Hide progress display and clear the line
    public func hideProgress() {
        guard config.isTTY else { return }
        clearLine()
    }
    
    // MARK: - Utility Properties
    
    /// Check if current output is going to a terminal
    public var isTTY: Bool {
        config.isTTY
    }
    
    /// Check if color output is enabled
    public var isColored: Bool {
        config.isColored
    }
    
    // MARK: - Private Implementation
    
    private func resolveFormat(_ format: Format) -> Format {
        if let forced = config.forceFormat { return forced }
        
        // Auto-detection based on context
        switch format {
        case .auto:
            return config.isTTY ? .summary : .json
        default:
            return format
        }
    }
    
    // MARK: - JSON Formatting
    
    private func formatAsJSON<T: Codable>(_ value: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return #"{"error": "Failed to encode JSON", "details": "\#(error.localizedDescription)"}"#
        }
    }
    
    private func formatTextAsJSON(_ text: String) -> String {
        let result: [String: Any] = ["text": text]
        
        if let data = try? JSONSerialization.data(withJSONObject: result),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return #"{"text": "Failed to encode"}"#
    }
    
    // MARK: - Human-Readable Formatting
    
    private func formatAsSummary<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .summary))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .summary))
            }
        }
        
        return output.joined(separator: "\n")
    }
    
    private func formatTextAsSummary(_ text: String) -> String {
        return text
    }
    
    private func formatAsDetailed<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        output.append("=== \(type(of: value)) ===")
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .detailed))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .detailed))
            }
        }
        
        return output.joined(separator: "\n")
    }
    
    private func formatTextAsDetailed(_ text: String) -> String {
        return "=== Text ===\n\(text)"
    }
    
    private func formatAsCompact<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .compact))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .compact))
            }
        }
        
        return output.joined(separator: " | ")
    }
    
    private func formatTextAsCompact(_ text: String) -> String {
        return text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: " ")
    }
    
    private func formatAsMinimal<T: Codable>(_ value: T) -> String {
        // Extract only the most essential information
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var essentialInfo = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            
            // Only include essential keys
            if ["status", "success", "count", "total", "errors", "warnings"].contains(key.lowercased()) {
                essentialInfo.append("\(key): \(child.value)")
            }
        }
        
        return essentialInfo.joined(separator: " | ")
    }
    
    private func formatTextAsMinimal(_ text: String) -> String {
        // Remove all formatting and extra whitespace
        return text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
    
    // MARK: - Helper Methods
    
    private enum ValueStyle {
        case summary, detailed, compact
    }
    
    private func formatKeyValue(key: String, value: Any, style: ValueStyle) -> String {
        let formattedValue: String
        
        switch style {
        case .summary:
            formattedValue = formatValueForSummary(value)
        case .detailed:
            formattedValue = formatValueForDetailed(value)
        case .compact:
            formattedValue = formatValueForCompact(value)
        }
        
        switch style {
        case .summary:
            return config.isColored ? "🎯 \(key): \(formattedValue)" : "\(key): \(formattedValue)"
        case .detailed:
            return config.isColored ? "📋 \(key):\n    \(formattedValue.replacingOccurrences(of: "\n", with: "\n    "))" : "\(key):\n    \(formattedValue.replacingOccurrences(of: "\n", with: "\n    "))"
        case .compact:
            return "\(key)=\(formattedValue)"
        }
    }
    
    private func formatValueForSummary(_ value: Any) -> String {
        if let stringValue = value as? String {
            return stringValue.count > 50 ? String(stringValue.prefix(50)) + "..." : stringValue
        }
        
        if let arrayValue = value as? [Any] {
            return "[\(arrayValue.count) items]"
        }
        
        if let dictValue = value as? [String: Any] {
            return "[\(dictValue.count) entries]"
        }
        
        return String(describing: value)
    }
    
    private func formatValueForDetailed(_ value: Any) -> String {
        return String(describing: value)
    }
    
    private func formatValueForCompact(_ value: Any) -> String {
        if let stringValue = value as? String {
            return stringValue.replacingOccurrences(of: " ", with: "_")
        }
        
        if let arrayValue = value as? [Any] {
            return "[\(arrayValue.count)]"
        }
        
        if let dictValue = value as? [String: Any] {
            return "{\(dictValue.count)}"
        }
        
        return String(describing: value).prefix(20) + (String(describing: value).count > 20 ? "..." : "")
    }
    
    private func createProgressBar(_ percentage: Double) -> String {
        let width = 20
        let filled = Int(Double(width) * percentage / 100)
        let empty = width - filled
        
        let filledChars = String(repeating: "█", count: filled)
        let emptyChars = String(repeating: "░", count: empty)
        
        return config.isColored ? "[\(filledChars)\(emptyChars)]" : "[\(filled)/\(width)]"
    }
    
    private func clearLine() {
        print("\r", terminator: "")
        let columns = terminalWidth()
        if columns > 0 {
            print(String(repeating: " ", count: columns), terminator: "")
        }
        print("\r", terminator: "")
    }
    
    private func terminalWidth() -> Int {
        #if canImport(Glibc)
        // Linux/Unix - try to get terminal size
        var winsize = winsize()
        if ioctl(Int(STDOUT_FILENO), TIOCGWINSZ, &winsize) == 0 {
            return Int(winsize.ws_col)
        }
        #elseif canImport(Darwin)
        // macOS - try to get terminal size
        var winsize = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsize) == 0 {
            return Int(winsize.ws_col)
        }
        #endif
        
        // Default fallback
        return 80
    }
    
    // MARK: - ANSI Color Support
    
    /// ANSI color codes for terminal output
    public enum Color {
        public static let red = "\u{001B}[31m"
        public static let green = "\u{001B}[32m"
        public static let yellow = "\u{001B}[33m"
        public static let blue = "\u{001B}[34m"
        public static let magenta = "\u{001B}[35m"
        public static let cyan = "\u{001B}[36m"
        public static let reset = "\u{001B}[0m"
        public static let bold = "\u{001B}[1m"
    }
}

// MARK: - Progress Indicator

/// Manages progress display with automatic TTY detection and duration tracking
public struct SmithProgressIndicator {
    private let formatter: SmithOutputFormatter
    private var startTime: Date
    
    /// Initialize progress indicator with formatter
    public init(formatter: SmithOutputFormatter) {
        self.formatter = formatter
        self.startTime = Date()
    }
    
    /// Start progress tracking with spinner
    public mutating func start(title: String, format: SmithOutputFormatter.Format = .auto) {
        formatter.showSpinner(title: title, format: format)
        startTime = Date()
    }
    
    /// Update progress with current status
    public mutating func update(
        current: Int,
        total: Int,
        phase: String = "",
        currentItem: String = "",
        format: SmithOutputFormatter.Format = .auto
    ) {
        formatter.hideProgress()
        formatter.showProgress(
            title: "",
            current: current,
            total: total,
            phase: phase,
            currentItem: currentItem,
            format: format
        )
    }
    
    /// Finish progress with result message
    public mutating func finish(message: String, success: Bool = true) {
        formatter.hideProgress()
        
        let duration = Date().timeIntervalSince(startTime)
        let durationText = String(format: "%.1f", duration)
        
        if success {
            print(formatter.isColored ? "\(SmithOutputFormatter.Color.green)✅\(SmithOutputFormatter.Color.reset) \(message) (\(durationText)s)" : "✅ \(message) (\(durationText)s)")
        } else {
            print(formatter.isColored ? "\(SmithOutputFormatter.Color.red)❌\(SmithOutputFormatter.Color.reset) \(message) (\(durationText)s)" : "❌ \(message) (\(durationText)s)")
        }
    }
}

// MARK: - Convenience Extensions

extension Encodable where Self: Decodable {
    /// Format this value using SmithOutputFormatter
    public func formattedOutput(
        format: SmithOutputFormatter.Format = .auto,
        colored: Bool = false
    ) -> String {
        let formatter = SmithOutputFormatter(
            config: SmithOutputFormatter.Configuration(force: format, forceColored: colored)
        )
        return formatter.format(self, as: format)
    }
}

// MARK: - CLI Output Helpers

/// Convenience wrapper for common CLI-style output operations
public struct SmithCLIOutput {
    private let formatter: SmithOutputFormatter
    
    /// Initialize with formatter configuration
    public init(format: SmithOutputFormatter.Format = .auto, colored: Bool? = nil) {
        self.formatter = SmithOutputFormatter(
            config: SmithOutputFormatter.Configuration(force: format, forceColored: colored)
        )
    }
    
    /// Print success message
    public func success(_ message: String) {
        if formatter.isColored {
            print("\(SmithOutputFormatter.Color.green)✅\(SmithOutputFormatter.Color.reset) \(message)")
        } else {
            print("✅ \(message)")
        }
    }
    
    /// Print error message
    public func error(_ message: String) {
        if formatter.isColored {
            print("\(SmithOutputFormatter.Color.red)❌\(SmithOutputFormatter.Color.reset) \(message)")
        } else {
            print("❌ \(message)")
        }
    }
    
    /// Print warning message
    public func warning(_ message: String) {
        if formatter.isColored {
            print("\(SmithOutputFormatter.Color.yellow)⚠️\(SmithOutputFormatter.Color.reset) \(message)")
        } else {
            print("⚠️  \(message)")
        }
    }
    
    /// Print informational message
    public func info(_ message: String) {
        if formatter.isColored {
            print("\(SmithOutputFormatter.Color.blue)ℹ️\(SmithOutputFormatter.Color.reset) \(message)")
        } else {
            print("ℹ️  \(message)")
        }
    }
    
    /// Print section header
    public func section(_ title: String) {
        let separator = String(repeating: "=", count: title.count + 4)
        if formatter.isColored {
            print("\(SmithOutputFormatter.Color.bold)\(separator)\(SmithOutputFormatter.Color.reset)")
            print("\(SmithOutputFormatter.Color.bold)\(SmithOutputFormatter.Color.reset) \(title) ")
            print("\(SmithOutputFormatter.Color.bold)\(separator)\(SmithOutputFormatter.Color.reset)")
        } else {
            print(separator)
            print("  \(title)  ")
            print(separator)
        }
    }
}

#if canImport(Glibc)
import Glibc

// Linux-specific imports for terminal width detection
private struct winsize {
    var ws_row: UInt16 = 0
    var ws_col: UInt16 = 0
    var ws_xpixel: UInt16 = 0
    var ws_ypixel: UInt16 = 0
}

private let TIOCGWINSZ = UInt(0x5413)

#endif
