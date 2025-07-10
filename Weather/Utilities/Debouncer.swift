import Foundation
import Combine

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    
    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }
    
    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        
        queue.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    func cancel() {
        workItem?.cancel()
    }
}

// MARK: - Combine Extension
extension Publisher where Failure == Never {
    func debounce(for duration: TimeInterval) -> AnyPublisher<Output, Never> {
        self.debounce(for: .seconds(duration), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Async Debouncer
actor AsyncDebouncer {
    private let duration: Duration
    private var task: Task<Void, Never>?
    
    init(duration: Duration = .milliseconds(300)) {
        self.duration = duration
    }
    
    func debounce(operation: @escaping () async -> Void) {
        task?.cancel()
        
        task = Task {
            do {
                try await Task.sleep(for: duration)
                guard !Task.isCancelled else { return }
                await operation()
            } catch {
                // Task was cancelled
            }
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}

// MARK: - Search Debouncer
@MainActor
class SearchDebouncer: ObservableObject {
    @Published var searchText = ""
    @Published var debouncedSearchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let delay: TimeInterval
    
    init(delay: TimeInterval = 0.3) {
        self.delay = delay
        
        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.debouncedSearchText = text
            }
            .store(in: &cancellables)
    }
}