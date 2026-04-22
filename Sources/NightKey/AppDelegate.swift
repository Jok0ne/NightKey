import Cocoa

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let controllerWatcher = GameControllerWatcher()

    /// Auto-Mode: bei Controller-Connect Beleuchtung aus, bei Disconnect wieder an.
    /// Lässt sich im Menü ausschalten.
    private var autoMode: Bool = true {
        didSet {
            UserDefaults.standard.set(autoMode, forKey: "NightKey.autoMode")
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        autoMode = UserDefaults.standard.object(forKey: "NightKey.autoMode") as? Bool ?? true

        setupStatusItem()
        setupControllerWatcher()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        updateIcon()

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func setupControllerWatcher() {
        controllerWatcher.onControllerConnected = { [weak self] in
            guard let self, self.autoMode else { return }
            BacklightController.turnOff()
            self.updateIcon()
        }
        controllerWatcher.onAllControllersDisconnected = { [weak self] in
            guard let self, self.autoMode else { return }
            BacklightController.turnOn()
            self.updateIcon()
        }
        controllerWatcher.start()
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            showMenu()
        } else {
            BacklightController.toggle()
            updateIcon()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "NightKey",
            action: nil,
            keyEquivalent: ""
        ))
        menu.addItem(NSMenuItem.separator())

        let toggleItem = NSMenuItem(
            title: BacklightController.isOn ? "Beleuchtung aus" : "Beleuchtung an",
            action: #selector(toggleBacklight),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let autoItem = NSMenuItem(
            title: "Auto bei Controller",
            action: #selector(toggleAutoMode),
            keyEquivalent: ""
        )
        autoItem.target = self
        autoItem.state = autoMode ? .on : .off
        menu.addItem(autoItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: "Beenden",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggleBacklight() {
        BacklightController.toggle()
        updateIcon()
    }

    @objc private func toggleAutoMode() {
        autoMode.toggle()
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let symbolName = BacklightController.isOn ? "keyboard" : "keyboard.badge.eye"
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "NightKey")
        image?.isTemplate = true
        button.image = image
    }
}
