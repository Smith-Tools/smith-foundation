import Foundation
import Combine

// MARK: - SmithProgress Library
//
// A comprehensive progress tracking system with smart TTY awareness,
// multiple progress styles, and real-time updates.
// Perfect for embedding in commercial applications that need professional progress feedback.
//

/// Comprehensive progress tracking system
///
/// Provides intelligent progress display with automatic TTY detection,
/// multiple progress styles, and real-time updates for commercial applications.
///
/// **Key Features:**
/// - Smart TTY detection and automatic progress display
/// - Multiple progress styles (bar, spinner, dots, custom)
/// - Real-time updates with throttling
/// - Duration tracking and ETA estimation
/// - Thread-safe operations
/// - Cross-platform compatibility
/// - Zero dependencies
public class SmithProgress {
    
    // MARK: - Configuration
    
    /// Progress display configuration
    public struct Configuration {
        let isTTY: Bool
        let isColored: Bool
        let updateInterval: TimeInterval
        let showETA: Bool
        let showDuration: Bool
        let width: Int
        
        public init(
            isTTY: Bool? = nil,
            isColored: Bool? = nil,
            updateInterval: TimeInterval = 0.1,
            showETA: Bool = true,
            showDuration: Bool = true,
            width: Int = 40
        ) {
            #if canImport(Glibc)
            self.isTTY = isTTY ?? (isatty(STDOUT_FILENO) != 0)
            #elseif canImport(Darwin)
            self.isTTY = isTTY ?? (isatty(STDOUT_FILENO) != 0)
            #else
            self.isTTY = isTTY ?? false
            #endif
            
            let noColor = ProcessInfo.processInfo.environment["NO_COLOR"] != nil
            let forceColor = (isColored != nil) ? isColored! : (ProcessInfo.processInfo.environment["FORCE_COLOR"] != nil)
            
            self.isColored = self.isTTY && !noColor || forceColor ?? false
            self.updateInterval = updateInterval
            self.showETA = showETA
            self.showDuration = showDuration
            self.width = width
        }
        
        /// Create configuration for testing
        public static func testConfig(isTTY: Bool = true, isColored: Bool = true) -> Configuration {
            return Configuration(
                isTTY: isTTY,
                isColored: isColored,
                updateInterval: 0.01, // Faster updates for tests
                showETA: true,
                showDuration: true,
                width: 20
            )
        }
    }
    
    // MARK: - Progress Style
    
    /// Different progress display styles
    public enum Style {
        case bar           // Traditional progress bar
        case spinner       // Spinning animation
        case dots          // Animated dots
        case steps         // Step-by-step progress
        case percentage    // Just percentage
        case custom(String) // Custom format string
        
        /// Get spinner frames for spinner style
        var spinnerFrames: [String] {
            switch self {
            case .spinner:
                return ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
            case .dots:
                return ["", ".", "..", "..."]
            default:
                return ["⠋"] // Default frame
            }
        }
    }
    
    // MARK: - Progress State
    
    /// Current progress state
    public struct State {
        public var current: Int
        public var total: Int
        public var phase: String
        public var message: String
        public var startTime: Date
        public var lastUpdate: Date
        
        public init(current: Int = 0, total: Int = 100, phase: String = "", message: String = "") {
            self.current = current
            self.total = total
            self.phase = phase
            self.message = message
            self.startTime = Date()
            self.lastUpdate = Date()
        }
        
        /// Calculate progress percentage
        public var percentage: Double {
            guard total > 0 else { return 0 }
            return Double(current) / Double(total) * 100
        }
        
        /// Calculate elapsed time
        public var elapsedTime: TimeInterval {
            Date().timeIntervalSince(startTime)
        }
        
        /// Calculate estimated time remaining
        public var estimatedTimeRemaining: TimeInterval? {
            guard current > 0 && total > current else { return nil }
            let rate = Double(current) / elapsedTime
            guard rate > 0 else { return nil }
            let remaining = Double(total - current) / rate
            return remaining.isFinite ? remaining : nil
        }
        
        /// Format elapsed time
        public var formattedElapsedTime: String {
            let interval = elapsedTime
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) % 3600) / 60
            let seconds = Int(interval) % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%d:%02d", minutes, seconds)
            }
        }
        
        /// Format estimated time remaining
        public var formattedTimeRemaining: String? {
            guard let remaining = estimatedTimeRemaining else { return nil }
            let hours = Int(remaining) / 3600
            let minutes = (Int(remaining) % 3600) / 60
            let seconds = Int(remaining) % 60
            
            if hours > 0 {
                return String(format: "%dh %dm", hours, minutes)
            } else if minutes > 0 {
                return String(format: "%dm %ds", minutes, seconds)
            } else {
                return String(format: "%ds", seconds)
            }
        }
    }
    
    // MARK: - Public Interface
    
    private let config: Configuration
    private var state: State
    private var timer: Timer?
    private var isRunning: Bool = false
    private let queue = DispatchQueue(label: "smith.progress.queue", qos: .userInitiated)
    private var lastDisplayTime: Date = Date()
    
    /// Initialize progress tracker
    public init(
        configuration: Configuration = Configuration(),
        initialState: State = State()
    ) {
        self.config = configuration
        self.state = initialState
    }
    
    /// Start progress tracking
    public func start(title: String = "", style: Style = .bar) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.state.message = title
            self.state.startTime = Date()
            self.state.lastUpdate = Date()
            self.isRunning = true
            
            if self.config.isTTY {
                self.startDisplayTimer(style: style)
            } else {
                // For non-TTY environments, just record start time
                self.recordProgress()
            }
        }
    }
    
    /// Update progress
    public func update(
        current: Int? = nil,
        total: Int? = nil,
        phase: String? = nil,
        message: String? = nil
    ) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            if let current = current { self.state.current = current }
            if let total = total { self.state.total = total }
            if let phase = phase { self.state.phase = phase }
            if let message = message { self.state.message = message }
            
            self.state.lastUpdate = Date()
            self.recordProgress()
        }
    }
    
    /// Finish progress tracking
    public func finish(success: Bool = true, finalMessage: String? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.isRunning = false
            self.timer?.invalidate()
            self.timer = nil
            
            // Clear progress display
            if self.config.isTTY {
                self.clearDisplay()
            }
            
            // Show final result
            let message = finalMessage ?? self.state.message
            if !message.isEmpty {
                let duration = self.state.formattedElapsedTime
                
                if self.config.isColored {
                    let status = success ? "✅" : "❌"
                    let color = success ? ProgressColor.green : ProgressColor.red
                    print("\(color)\(status) \(message) (\(duration))\(ProgressColor.reset)")
                } else {
                    let status = success ? "✅" : "❌"
                    print("\(status) \(message) (\(duration))")
                }
            }
        }
    }
    
    /// Cancel progress tracking
    public func cancel() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            self.isRunning = false
            self.timer?.invalidate()
            self.timer = nil
            
            if self.config.isTTY {
                self.clearDisplay()
            }
            
            print("⚠️  Progress cancelled")
        }
    }
    
    /// Get current state (thread-safe)
    public var currentState: State {
        queue.sync { state }
    }
    
    /// Check if progress is currently running
    public var running: Bool {
        queue.sync { isRunning }
    }
    
    // MARK: - Private Implementation
    
    private func startDisplayTimer(style: Style) {
        timer = Timer.scheduledTimer(withTimeInterval: config.updateInterval, repeats: true) { [weak self] _ in
            self?.updateDisplay(style: style)
        }
    }
    
    private func updateDisplay(style: Style) {
        guard isRunning else { return }
        
        // Throttle updates to avoid overwhelming the display
        let now = Date()
        guard now.timeIntervalSince(lastDisplayTime) >= config.updateInterval else { return }
        lastDisplayTime = now
        
        clearDisplay()
        
        switch style {
        case .bar:
            displayProgressBar()
        case .spinner:
            displaySpinner()
        case .dots:
            displayDots()
        case .steps:
            displaySteps()
        case .percentage:
            displayPercentage()
        case .custom(let format):
            displayCustom(format)
        }
        
        fflush(stdout)
    }
    
    private func displayProgressBar() {
        let percentage = state.percentage
        let filledWidth = Int(Double(config.width) * percentage / 100)
        let emptyWidth = config.width - filledWidth
        
        let filledChars = String(repeating: "█", count: filledWidth)
        let emptyChars = String(repeating: "░", count: emptyWidth)
        
        var output = "\(config.isColored ? ProgressColor.cyan : "")[\(filledChars)\(emptyChars)] \(String(format: "%.1f", percentage))%"
        
        if config.showETA, let timeRemaining = state.formattedTimeRemaining {
            output += " (\(timeRemaining) remaining)"
        }
        
        if config.showDuration {
            output += " [\(state.formattedElapsedTime)]"
        }
        
        if !state.phase.isEmpty {
            output += " \(config.isColored ? ProgressColor.yellow : "")[\(state.phase)]\(ProgressColor.reset)"
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func displaySpinner() {
        let frames = Style.spinner.spinnerFrames
        let frameIndex = Int(Date().timeIntervalSince(state.startTime) * 10) % frames.count
        let frame = frames[frameIndex]
        
        var output = "\(config.isColored ? ProgressColor.magenta : "")\(frame) \(state.message)"
        
        if !state.phase.isEmpty {
            output += " \(config.isColored ? ProgressColor.yellow : "")[\(state.phase)]\(ProgressColor.reset)"
        }
        
        if config.showDuration {
            output += " [\(state.formattedElapsedTime)]"
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func displayDots() {
        let frames = Style.dots.spinnerFrames
        let frameIndex = Int(Date().timeIntervalSince(state.startTime) * 2) % frames.count
        let dots = frames[frameIndex]
        
        var output = "\(config.isColored ? ProgressColor.blue : "")\(state.message)\(dots)"
        
        if !state.phase.isEmpty {
            output += " \(config.isColored ? ProgressColor.yellow : "")[\(state.phase)]\(ProgressColor.reset)"
        }
        
        if config.showDuration {
            output += " [\(state.formattedElapsedTime)]"
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func displaySteps() {
        let totalSteps = max(state.total, 1)
        let currentStep = min(state.current, totalSteps)
        
        var output = "\(config.isColored ? ProgressColor.green : "")Steps: \(currentStep)/\(totalSteps)"
        
        if !state.phase.isEmpty {
            output += " \(config.isColored ? ProgressColor.yellow : "")[\(state.phase)]\(ProgressColor.reset)"
        }
        
        if config.showDuration {
            output += " [\(state.formattedElapsedTime)]"
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func displayPercentage() {
        let percentage = state.percentage
        var output = "\(config.isColored ? ProgressColor.cyan : "")\(String(format: "%.1f", percentage))%"
        
        if config.showETA, let timeRemaining = state.formattedTimeRemaining {
            output += " (\(timeRemaining) remaining)"
        }
        
        if config.showDuration {
            output += " [\(state.formattedElapsedTime)]"
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func displayCustom(_ format: String) {
        let percentage = state.percentage
        var output = format
        
        // Replace format placeholders
        output = output.replacingOccurrences(of: "{percentage}", with: String(format: "%.1f", percentage))
        output = output.replacingOccurrences(of: "{current}", with: "\(state.current)")
        output = output.replacingOccurrences(of: "{total}", with: "\(state.total)")
        output = output.replacingOccurrences(of: "{phase}", with: state.phase)
        output = output.replacingOccurrences(of: "{message}", with: state.message)
        output = output.replacingOccurrences(of: "{elapsed}", with: state.formattedElapsedTime)
        
        if let timeRemaining = state.formattedTimeRemaining {
            output = output.replacingOccurrences(of: "{remaining}", with: timeRemaining)
        } else {
            output = output.replacingOccurrences(of: "{remaining}", with: "N/A")
        }
        
        print("\r\(output)", terminator: "")
    }
    
    private func clearDisplay() {
        print("\r\(String(repeating: " ", count: terminalWidth()))\r", terminator: "")
    }
    
    private func recordProgress() {
        // In a real implementation, this could record to analytics or logging
        // For now, just ensure state is updated
    }
    
    private func terminalWidth() -> Int {
        #if canImport(Glibc)
        var winsize = winsize()
        if ioctl(Int(STDOUT_FILENO), TIOCGWINSZ, &winsize) == 0 {
            return Int(winsize.ws_col)
        }
        #elseif canImport(Darwin)
        var winsize = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsize) == 0 {
            return Int(winsize.ws_col)
        }
        #endif
        return 80 // Default fallback
    }
}

// MARK: - Progress Color Support

/// ANSI color codes for progress display
public enum ProgressColor {
    public static let red = "\u{001B}[31m"
    public static let green = "\u{001B}[32m"
    public static let yellow = "\u{001B}[33m"
    public static let blue = "\u{001B}[34m"
    public static let magenta = "\u{001B}[35m"
    public static let cyan = "\u{001B}[36m"
    public static let reset = "\u{001B}[0m"
    public static let bold = "\u{001B}[1m"
}

// MARK: - Progress Observer

/// Protocol for observing progress updates
public protocol SmithProgressObserver: AnyObject {
    func progressDidUpdate(_ progress: SmithProgress, state: SmithProgress.State)
    func progressDidStart(_ progress: SmithProgress, state: SmithProgress.State)
    func progressDidFinish(_ progress: SmithProgress, state: SmithProgress.State, success: Bool)
    func progressDidCancel(_ progress: SmithProgress, state: SmithProgress.State)
}

/// Observable progress tracker
public class ObservableSmithProgress: SmithProgress {
    private var observers: [WeakProgressObserver] = []
    
    public override func start(title: String = "", style: Style = .bar) {
        super.start(title: title, style: style)
        notifyObservers { $0.progressDidStart(self, state: currentState) }
    }
    
    public override func update(
        current: Int? = nil,
        total: Int? = nil,
        phase: String? = nil,
        message: String? = nil
    ) {
        super.update(current: current, total: total, phase: phase, message: message)
        notifyObservers { $0.progressDidUpdate(self, state: currentState) }
    }
    
    public override func finish(success: Bool = true, finalMessage: String? = nil) {
        super.finish(success: success, finalMessage: finalMessage)
        notifyObservers { $0.progressDidFinish(self, state: currentState, success: success) }
    }
    
    public override func cancel() {
        super.cancel()
        notifyObservers { $0.progressDidCancel(self, state: currentState) }
    }
    
    public func addObserver(_ observer: SmithProgressObserver) {
        let weakObserver = WeakProgressObserver(observer)
        observers.append(weakObserver)
        cleanupObservers()
    }
    
    public func removeObserver(_ observer: SmithProgressObserver) {
        observers.removeAll { $0.observer === observer }
    }
    
    private func notifyObservers(_ notification: (SmithProgressObserver) -> Void) {
        cleanupObservers()
        observers.forEach { weakObserver in
            if let observer = weakObserver.observer {
                notification(observer)
            }
        }
    }
    
    private func cleanupObservers() {
        observers.removeAll { $0.observer == nil }
    }
}

private class WeakProgressObserver {
    weak var observer: SmithProgressObserver?
    
    init(_ observer: SmithProgressObserver) {
        self.observer = observer
    }
}

// MARK: - Progress Publishers

#if canImport(Combine)
import Combine

/// Combine publishers for SwiftUI integration
public extension ObservableSmithProgress {
    struct ProgressPublisher {
        let progress: ObservableSmithProgress
        
        public var current: AnyPublisher<SmithProgress.State, Never> {
            Just(progress.currentState)
                .eraseToAnyPublisher()
        }
        
        public var running: AnyPublisher<Bool, Never> {
            Just(progress.running)
                .eraseToAnyPublisher()
        }
    }
    
    public var publisher: ProgressPublisher {
        return ProgressPublisher(progress: self)
    }
}
#endif

// MARK: - Progress Utilities

/// Utility functions for progress operations
public enum SmithProgressUtils {
    /// Create progress tracker for known total items
    public static func forItems<T>(
        _ items: [T],
        title: String = "Processing items",
        style: SmithProgress.Style = .bar
    ) -> SmithProgress {
        let progress = SmithProgress(
            configuration: SmithProgress.Configuration(),
            initialState: SmithProgress.State(total: items.count)
        )
        progress.start(title: title, style: style)
        return progress
    }
    
    /// Create progress tracker for unknown/indefinite progress
    public static func indefinite(
        title: String = "Processing",
        style: SmithProgress.Style = .spinner
    ) -> SmithProgress {
        let progress = SmithProgress(
            configuration: SmithProgress.Configuration(),
            initialState: SmithProgress.State(total: 0)
        )
        progress.start(title: title, style: style)
        return progress
    }
    
    /// Create progress tracker for time-based operations
    public static func forDuration(
        _ duration: TimeInterval,
        title: String = "Processing",
        style: SmithProgress.Style = .bar
    ) -> SmithProgress {
        let progress = SmithProgress(
            configuration: SmithProgress.Configuration(),
            initialState: SmithProgress.State(total: 100)
        )
        progress.start(title: title, style: style)
        
        // Simulate progress based on elapsed time
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(progress.currentState.startTime)
            let percentage = min(elapsed / duration * 100, 100)
            progress.update(current: Int(percentage))
            
            if elapsed >= duration {
                timer.invalidate()
                progress.finish(success: true, finalMessage: title)
            }
        }
        
        return progress
    }
}

#if canImport(Glibc)
import Glibc

// Linux-specific imports for terminal size detection
private struct winsize {
    var ws_row: UInt16 = 0
    var ws_col: UInt16 = 0
    var ws_xpixel: UInt16 = 0
    var ws_ypixel: UInt16 = 0
}

private let TIOCGWINSZ = UInt(0x5413)

#endif
