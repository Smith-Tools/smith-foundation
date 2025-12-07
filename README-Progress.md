# SmithProgress

A comprehensive, embeddable progress tracking system with smart TTY awareness, multiple progress styles, and real-time updates for Swift applications.

## Overview

SmithProgress provides intelligent progress display that automatically adapts to the terminal environment while offering multiple progress styles and real-time updates. It's perfect for commercial applications that need professional progress feedback without the complexity of building progress systems from scratch.

## Key Features

### 🎯 Smart TTY Detection
- Automatically detects terminal vs non-terminal environments
- Gracefully disables progress display in non-TTY contexts
- Respects user color preferences (`NO_COLOR`, `FORCE_COLOR`)

### 🎨 Multiple Progress Styles
- **Bar**: Traditional progress bar with percentage and ETA
- **Spinner**: Animated spinner for indeterminate operations
- **Dots**: Simple dot animation for lightweight feedback
- **Steps**: Step-by-step progress display
- **Percentage**: Simple percentage display
- **Custom**: Customizable format strings

### ⏱️ Time Tracking
- Automatic duration tracking
- Estimated time remaining (ETA) calculation
- Formatted time display (HH:MM:SS)

### 🔄 Real-Time Updates
- Throttled updates to avoid overwhelming display
- Thread-safe operations
- Observer pattern for real-time notifications

### 🏗️ Commercial Ready
- Zero external dependencies
- Cross-platform support (macOS, Linux, iOS, tvOS, watchOS)
- SwiftUI integration via Combine publishers
- Production-tested

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Smith-Tools/SmithProgress.git", from: "1.0.0")
]
```

### Xcode

1. Add the package to your Xcode project
2. Import the module:
```swift
import SmithProgress
```

## Quick Start

### Basic Progress Bar

```swift
import SmithProgress

let progress = SmithProgress()
progress.start(title: "Processing data", style: .bar)

for i in 0...100 {
    progress.update(current: i, total: 100, phase: "Processing item \(i)")
    usleep(50000) // Simulate work
}

progress.finish(success: true, finalMessage: "Data processing completed")
```

### Spinner for Indeterminate Operations

```swift
let spinner = SmithProgress()
spinner.start(title: "Connecting to server", style: .spinner)

// Simulate connection
DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
    spinner.finish(success: true, finalMessage: "Connected successfully")
}
```

### Step-by-Step Progress

```swift
let steps = SmithProgress()
steps.start(title: "Setup process", style: .steps)

steps.update(current: 1, total: 5, phase: "Initializing")
sleep(1)

steps.update(current: 2, total: 5, phase: "Loading configuration")
sleep(1)

steps.update(current: 3, total: 5, phase: "Setting up database")
sleep(1)

steps.update(current: 4, total: 5, phase: "Starting services")
sleep(1)

steps.update(current: 5, total: 5, phase: "Complete")
steps.finish(success: true, finalMessage: "Setup completed successfully")
```

## Advanced Usage

### Custom Configuration

```swift
let config = SmithProgress.Configuration(
    isTTY: true,
    isColored: true,
    updateInterval: 0.05, // Faster updates
    showETA: true,
    showDuration: true,
    width: 50 // Wider progress bar
)

let progress = SmithProgress(configuration: config)
```

### Observable Progress with Callbacks

```swift
let observableProgress = ObservableSmithProgress()

// Add observer
observableProgress.addObserver(object: self)

// Or use Combine Publishers (iOS 13+)
observableProgress.publisher.current
    .sink { state in
        print("Progress: \(state.percentage)%")
    }
    .store(in: &cancellables)
```

### Custom Format Strings

```swift
let progress = SmithProgress()
progress.start(title: "Custom format demo", style: .custom(
    format: "Processing {current}/{total} ({percentage}%) - {phase} [{elapsed}]"
))

progress.update(current: 50, total: 100, phase: "Step 1")

// Output: Processing 50/100 (50.0%) - Step 1 [0:15]
```

### Progress Utilities

```swift
// For known number of items
let items = ["File1", "File2", "File3", "File4"]
let itemProgress = SmithProgressUtils.forItems(items, title: "Processing files")

for (index, item) in items.enumerated() {
    process(item)
    itemProgress.update(current: index + 1)
}
itemProgress.finish(success: true)

// For indefinite operations
let indefiniteProgress = SmithProgressUtils.indefinite(title: "Waiting for response")
// Use indefiniteProgress.update() as needed
indefiniteProgress.finish(success: true)

// For time-based operations
let timeProgress = SmithProgressUtils.forDuration(10.0, title: "Timer demo")
// Automatically updates based on time elapsed
```

## Progress Styles

### Bar Style
```
[████████████░░░░░░░] 60.0% (2m 30s remaining) [Downloading files]
```

### Spinner Style
```
⠼ Connecting to server [Downloading files] [0:15]
```

### Dots Style
```
Processing data... [Analyzing] [0:08]
```

### Steps Style
```
Steps: 3/5 [Database migration] [1:22]
```

### Percentage Style
```
45.2% (1m 15s remaining) [3:45]
```

### Custom Style
```
Custom: Processing 75/100 (75.0%) - Step 2 [2:30]
```

## API Reference

### SmithProgress Class

```swift
public class SmithProgress {
    public init(configuration: Configuration = Configuration(), initialState: State = State())
    
    // Control methods
    public func start(title: String = "", style: Style = .bar)
    public func update(current: Int? = nil, total: Int? = nil, phase: String? = nil, message: String? = nil)
    public func finish(success: Bool = true, finalMessage: String? = nil)
    public func cancel()
    
    // State access
    public var currentState: State { get }
    public var running: Bool { get }
}
```

### Configuration

```swift
public struct Configuration {
    public init(
        isTTY: Bool? = nil,
        isColored: Bool? = nil,
        updateInterval: TimeInterval = 0.1,
        showETA: Bool = true,
        showDuration: Bool = true,
        width: Int = 40
    )
    
    // Properties
    public let isTTY: Bool
    public let isColored: Bool
    public let updateInterval: TimeInterval
    public let showETA: Bool
    public let showDuration: Bool
    public let width: Int
}
```

### State

```swift
public struct State {
    public var current: Int
    public var total: Int
    public var phase: String
    public var message: String
    public var startTime: Date
    public var lastUpdate: Date
    
    // Computed properties
    public var percentage: Double { get }
    public var elapsedTime: TimeInterval { get }
    public var estimatedTimeRemaining: TimeInterval? { get }
    public var formattedElapsedTime: String { get }
    public var formattedTimeRemaining: String? { get }
}
```

### Style Options

```swift
public enum Style {
    case bar           // Traditional progress bar
    case spinner       // Spinning animation
    case dots          // Animated dots
    case steps         // Step-by-step progress
    case percentage    // Just percentage
    case custom(String) // Custom format string
}
```

### Observer Pattern

```swift
public protocol SmithProgressObserver: AnyObject {
    func progressDidUpdate(_ progress: SmithProgress, state: SmithProgress.State)
    func progressDidStart(_ progress: SmithProgress, state: SmithProgress.State)
    func progressDidFinish(_ progress: SmithProgress, state: SmithProgress.State, success: Bool)
    func progressDidCancel(_ progress: SmithProgress, state: SmithProgress.State)
}

public class ObservableSmithProgress: SmithProgress {
    public func addObserver(_ observer: SmithProgressObserver)
    public func removeObserver(_ observer: SmithProgressObserver)
}
```

### Combine Integration

```swift
#if canImport(Combine)
import Combine

extension ObservableSmithProgress {
    public struct ProgressPublisher {
        public var current: AnyPublisher<SmithProgress.State, Never>
        public var running: AnyPublisher<Bool, Never>
    }
    
    public var publisher: ProgressPublisher { get }
}
#endif
```

## Use Cases

### 1. File Processing

```swift
func processFiles(_ filePaths: [String]) {
    let progress = SmithProgressUtils.forItems(filePaths, title: "Processing files")
    
    for (index, filePath) in filePaths.enumerated() {
        do {
            try processFile(at: filePath)
            progress.update(current: index + 1, phase: "Processed \(filePath)")
        } catch {
            progress.cancel()
            throw error
        }
    }
    
    progress.finish(success: true, finalMessage: "All files processed")
}
```

### 2. Network Operations

```swift
func downloadFiles(_ urls: [URL]) {
    let progress = SmithProgress(configuration: SmithProgress.Configuration())
    progress.start(title: "Downloading files", style: .bar)
    
    for (index, url) in urls.enumerated() {
        do {
            try await downloadFile(at: url)
            progress.update(
                current: index + 1,
                total: urls.count,
                phase: "Downloading \(url.lastPathComponent)"
            )
        } catch {
            progress.cancel()
            throw error
        }
    }
    
    progress.finish(success: true, finalMessage: "Download completed")
}
```

### 3. Data Processing Pipeline

```swift
func processDataPipeline() {
    let pipeline = ObservableSmithProgress()
    pipeline.addObserver(object: self)
    
    pipeline.start(title: "Data pipeline", style: .steps)
    
    // Stage 1: Validation
    pipeline.update(current: 1, total: 4, phase: "Validating data")
    validateData()
    
    // Stage 2: Transformation
    pipeline.update(current: 2, total: 4, phase: "Transforming data")
    transformData()
    
    // Stage 3: Analysis
    pipeline.update(current: 3, total: 4, phase: "Analyzing data")
    analyzeData()
    
    // Stage 4: Export
    pipeline.update(current: 4, total: 4, phase: "Exporting results")
    exportResults()
    
    pipeline.finish(success: true, finalMessage: "Pipeline completed successfully")
}
```

### 4. Installation Wizard

```swift
func installationWizard() {
    let steps = [
        "System requirements check",
        "Downloading components",
        "Installing dependencies",
        "Configuration",
        "Testing installation",
        "Cleanup"
    ]
    
    let progress = SmithProgress(configuration: SmithProgress.Configuration())
    progress.start(title: "Installation", style: .steps)
    
    for (index, step) in steps.enumerated() {
        progress.update(current: index + 1, total: steps.count, phase: step)
        
        switch index {
        case 0: checkSystemRequirements()
        case 1: downloadComponents()
        case 2: installDependencies()
        case 3: configureInstallation()
        case 4: testInstallation()
        case 5: cleanup()
        default: break
        }
    }
    
    progress.finish(success: true, finalMessage: "Installation completed successfully")
}
```

### 5. Background Task Progress

```swift
class BackgroundTaskManager {
    private var progressTracker: SmithProgress?
    
    func startBackgroundTask() {
        progressTracker = SmithProgressUtils.indefinite(
            title: "Background processing",
            style: .spinner
        )
        
        Task {
            await processBackgroundWork()
            progressTracker?.finish(success: true, finalMessage: "Background task completed")
        }
    }
    
    private func processBackgroundWork() async {
        // Simulate long-running work with progress updates
        for i in 0..<100 {
            await processBatch(i)
            progressTracker?.update(phase: "Processing batch \(i)")
            try await Task.sleep(for: .milliseconds(100))
        }
    }
}
```

## SwiftUI Integration

### ProgressView Alternative

```swift
import SwiftUI
import SmithProgress

struct ProgressScreen: View {
    @State private var progress = 0
    @State private var isRunning = false
    private let progressTracker = ObservableSmithProgress()
    
    var body: some View {
        VStack {
            if isRunning {
                ProgressView(value: Double(progress), total: 100) {
                    Text("Processing...")
                }
                .progressViewStyle(LinearProgressViewStyle())
                .onReceive(progressTracker.publisher.current) { state in
                    progress = Int(state.percentage)
                }
            } else {
                Button("Start Process") {
                    startProcess()
                }
            }
        }
        .padding()
    }
    
    private func startProcess() {
        isRunning = true
        progressTracker.start(title: "Processing", style: .bar)
        
        Task {
            for i in 0...100 {
                try await Task.sleep(for: .milliseconds(50))
                progressTracker.update(current: i, phase: "Step \(i)")
            }
            isRunning = false
            progressTracker.finish(success: true)
        }
    }
}
```

### Custom Progress Component

```swift
struct CustomProgressView: View {
    let progress: ObservableSmithProgress
    @State private var displayState = SmithProgress.State()
    
    var body: some View {
        VStack {
            Text(displayState.message)
                .font(.headline)
            
            ProgressView(value: Double(displayState.current), total: Double(displayState.total)) {
                Text(displayState.phase)
            }
            
            Text("\(String(format: "%.1f", displayState.percentage))%")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let timeRemaining = displayState.formattedTimeRemaining {
                Text("Remaining: \(timeRemaining)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onReceive(progress.publisher.current) { state in
            displayState = state
        }
    }
}
```

## Thread Safety

All SmithProgress operations are thread-safe:

```swift
let progress = SmithProgress()

// Safe to call from any thread
DispatchQueue.global().async {
    progress.start(title: "Background task")
    
    for i in 0...100 {
        DispatchQueue.main.async {
            progress.update(current: i, phase: "Processing item \(i)")
        }
        usleep(10000) // Simulate work
    }
    
    DispatchQueue.main.async {
        progress.finish(success: true)
    }
}
```

## Error Handling

```swift
do {
    let progress = SmithProgress()
    progress.start(title: "Critical operation")
    
    try performCriticalOperation { current, total in
        progress.update(current: current, total: total)
    }
    
    progress.finish(success: true, finalMessage: "Operation completed")
} catch {
    progress?.cancel()
    handleError(error)
}
```

## Performance Considerations

### Update Throttling
- Updates are automatically throttled to avoid overwhelming the display
- Configurable update interval (default: 0.1 seconds)
- No performance impact in non-TTY environments

### Memory Usage
- Minimal memory footprint
- Automatic cleanup when progress completes
- Weak references for observers to prevent retain cycles

### CPU Usage
- Efficient timer-based updates
- No CPU usage when progress is not displayed
- Optimized for high-frequency updates

## Testing

### Unit Testing

```swift
func testProgressInitialization() {
    let config = SmithProgress.Configuration.testConfig()
    let state = SmithProgress.State(current: 50, total: 100, phase: "Test")
    let progress = SmithProgress(configuration: config, initialState: state)
    
    XCTAssertEqual(progress.currentState.current, 50)
    XCTAssertEqual(progress.currentState.total, 100)
    XCTAssertEqual(progress.currentState.phase, "Test")
    XCTAssertFalse(progress.running)
}

func testProgressUpdate() {
    let progress = SmithProgress()
    progress.start(title: "Test")
    progress.update(current: 25, total: 50, phase: "Step 1")
    
    XCTAssertEqual(progress.currentState.current, 25)
    XCTAssertEqual(progress.currentState.total, 50)
    XCTAssertEqual(progress.currentState.phase, "Step 1")
    XCTAssertTrue(progress.running)
}

func testTimeCalculations() {
    let state = SmithProgress.State()
    let elapsed = state.elapsedTime
    
    // Should be very close to 0
    XCTAssertTrue(elapsed < 0.1)
    
    XCTAssertEqual(state.percentage, 0.0)
    XCTAssertNil(state.estimatedTimeRemaining)
}
```

### Integration Testing

```swift
func testProgressDisplay() {
    let config = SmithProgress.Configuration.testConfig(isTTY: true, isColored: false)
    let progress = SmithProgress(configuration: config)
    
    let expectation = self.expectation(description: "Progress completion")
    
    progress.start(title: "Test progress")
    
    DispatchQueue.global().async {
        for i in 0...100 {
            Thread.sleep(forTimeInterval: 0.01)
            progress.update(current: i)
        }
        
        DispatchQueue.main.async {
            progress.finish(success: true)
            expectation.fulfill()
        }
    }
    
    waitForExpectations(timeout: 2.0)
}
```

## Platform Support

### Supported Platforms
- **macOS**: 12.0+
- **iOS**: 15.0+
- **tvOS**: 15.0+
- **watchOS**: 8.0+
- **Linux**: Any Swift-supported distribution

### Platform-Specific Features
- ✅ TTY detection on all platforms
- ✅ ANSI colors on macOS and Linux
- ✅ Terminal width detection
- ✅ File descriptor operations

## Customization

### Custom Styles

```swift
extension SmithProgress.Style {
    static let heartbeat = SmithProgress.Style.custom(
        format: "💓 {message} {current}/{total} | {elapsed}"
    )
    
    static let minimal = SmithProgress.Style.custom(
        format: "{percentage}% ({remaining})"
    )
}
```

### Custom Colors

```swift
public enum CustomProgressColor {
    public static let purple = "\u{001B}[35m"
    public static let orange = "\u{001B}[38;5;208m"
    
    // Override default colors
    public static let success = green  // Use green for success
    public static let error = red      // Use red for errors
}
```

### Progress Callbacks

```swift
class CustomProgressHandler {
    private var onUpdate: ((SmithProgress.State) -> Void)?
    
    func setUpdateCallback(_ callback: @escaping (SmithProgress.State) -> Void) {
        self.onUpdate = callback
    }
    
    func createProgress() -> SmithProgress {
        let progress = ObservableSmithProgress()
        progress.addObserver(object: self)
        return progress
    }
}

extension CustomProgressHandler: SmithProgressObserver {
    func progressDidUpdate(_ progress: SmithProgress, state: SmithProgress.State) {
        onUpdate?(state)
    }
    
    // Implement other required methods...
}
```

## Migration Guide

### From Manual Progress

**Before:**
```swift
func processFiles(_ files: [String]) {
    print("Processing \(files.count) files:")
    
    for (index, file) in files.enumerated() {
        print("[\(index + 1)/\(files.count)] Processing \(file)")
        process(file)
    }
    
    print("✅ All files processed")
}
```

**After:**
```swift
func processFiles(_ files: [String]) {
    let progress = SmithProgressUtils.forItems(files, title: "Processing files")
    
    for (index, file) in files.enumerated() {
        process(file)
        progress.update(current: index + 1, phase: "Processing \(file)")
    }
    
    progress.finish(success: true)
}
```

### From Other Progress Libraries

**From NVActivityIndicatorView:**
```swift
// Before (UIKit)
let activityIndicator = NVActivityIndicatorView(
    frame: CGRect(x: 0, y: 0, width: 50, height: 50),
    type: .ballTrianglePath
)
activityIndicator.startAnimating()

// After (Terminal)
let progress = SmithProgressUtils.indefinite(
    title: "Loading",
    style: .spinner
)
```

## Best Practices

### Progress Message Design
- **Be descriptive**: Clear, action-oriented messages
- **Include context**: What's being processed and why
- **Keep it brief**: Don't overwhelm the user with details
- **Use consistent terminology**: Same operations should use same messages

### Update Frequency
- **Don't update too frequently**: Use throttling (default 0.1s)
- **Update meaningfully**: Show real progress, not just time
- **Batch operations**: Group related updates when possible

### Error Handling
- **Always call finish()**: Even on errors, call finish(success: false)
- **Use cancel() for cancellation**: Not errors, but user cancellation
- **Clean up properly**: Ensure timers are invalidated

### Performance
- **Use appropriate styles**: Spinner for unknown duration, bar for known
- **Consider the context**: Terminal vs GUI applications
- **Monitor resource usage**: Especially in long-running operations

## Troubleshooting

### Progress Not Displaying
```swift
// Check TTY status
let config = SmithProgress.Configuration()
print("TTY: \(config.isTTY)") // Should be true in terminal

// Force TTY mode for testing
let testConfig = SmithProgress.Configuration.testConfig(isTTY: true)
let progress = SmithProgress(configuration: testConfig)
```

### Colors Not Working
```swift
// Check color support
let config = SmithProgress.Configuration()
print("Colors: \(config.isColored)") // Should be true in color terminal

// Force colors
let colorConfig = SmithProgress.Configuration(forceColored: true)
```

### Performance Issues
```swift
// Increase update interval for better performance
let config = SmithProgress.Configuration(updateInterval: 0.5)
```

## Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup
```bash
git clone https://github.com/Smith-Tools/SmithProgress.git
cd SmithProgress
swift test
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- **Documentation**: https://smith-tools.dev/docs/libraries/progress
- **Issues**: https://github.com/Smith-Tools/SmithProgress/issues
- **Discussions**: https://github.com/Smith-Tools/SmithProgress/discussions

---

Built with ❤️ by the Smith Tools team for the Swift community.
