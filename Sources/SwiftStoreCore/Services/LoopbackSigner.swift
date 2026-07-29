import Foundation

public final class LoopbackSignerCore {
    public enum State { case stopped, running }
    private(set) public var state: State = .stopped
    public init() {}
    public func start() throws { state = .running }
    public func stop() { state = .stopped }
    public func sign(ipaURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(.success(ipaURL))
        }
    }
}
