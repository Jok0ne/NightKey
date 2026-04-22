import Foundation
import GameController

/// Beobachtet Game Controller Verbindungen.
/// Wenn ein Controller verbunden wird → onControllerConnected().
/// Wenn der letzte Controller getrennt wird → onAllControllersDisconnected().
@MainActor
final class GameControllerWatcher {
    var onControllerConnected: (() -> Void)?
    var onAllControllersDisconnected: (() -> Void)?

    func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil
        )

        // Initial-Check: schon ein Controller verbunden?
        if !GCController.controllers().isEmpty {
            onControllerConnected?()
        }
    }

    @objc private nonisolated func controllerDidConnect() {
        Task { @MainActor in
            onControllerConnected?()
        }
    }

    @objc private nonisolated func controllerDidDisconnect() {
        Task { @MainActor in
            if GCController.controllers().isEmpty {
                onAllControllersDisconnected?()
            }
        }
    }
}
