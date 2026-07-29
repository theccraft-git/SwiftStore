import Foundation

/// LoopbackSigner is a stub implementation for the local loopback signing tunnel.
/// Real implementation requires device-level entitlements and careful security review.
final class LoopbackSigner {
    enum State {
        case stopped, running
    }

    private(set) var state: State = .stopped

    func start() throws {
        // Start networking/listener for loopback signing. Requires entitlements on device.
        // Here we only simulate.
        state = .running
    }

    func stop() {
        state = .stopped
    }

    func sign(ipaURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        // Simulate signing by returning the same URL after a delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            completion(.success(ipaURL))
        }
    }
}
