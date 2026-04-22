import Cocoa

/// Steuert die Tastatur-Hintergrundbeleuchtung des MacBook Air via
/// system-defined NSEvents (NX_KEYTYPE_ILLUMINATION_UP/DOWN).
///
/// Apple hat auf neueren MacBooks die F-Tasten zur Beleuchtungs-Steuerung
/// entfernt — die zugrunde liegenden Events funktionieren aber weiterhin.
@MainActor
enum BacklightController {
    private static let NX_KEYTYPE_ILLUMINATION_UP: Int = 21
    private static let NX_KEYTYPE_ILLUMINATION_DOWN: Int = 22
    private static let NX_SUBTYPE_AUX_CONTROL_BUTTONS: Int16 = 8

    /// Apple verwendet 16 Helligkeitsstufen — wir senden 20 zur Sicherheit.
    private static let stepCount = 20

    /// Aktueller logischer Status: hell (true) oder aus (false).
    /// Wird vom Toggle-Hotkey verwaltet.
    private(set) static var isOn: Bool = true

    /// Sendet einen einzelnen Aux-Key-Event (down + up Pair).
    private static func postAuxKey(_ keyCode: Int) {
        let downFlag = 0xa  // key down
        let upFlag = 0xb    // key up

        for flag in [downFlag, upFlag] {
            let data1 = (keyCode << 16) | (flag << 8)
            guard let event = NSEvent.otherEvent(
                with: .systemDefined,
                location: .zero,
                modifierFlags: [],
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: NX_SUBTYPE_AUX_CONTROL_BUTTONS,
                data1: data1,
                data2: -1
            ) else { continue }
            event.cgEvent?.post(tap: .cghidEventTap)
        }
    }

    /// Sendet `stepCount` mal DOWN — Tastatur wird komplett dunkel.
    static func turnOff() {
        for _ in 0..<stepCount {
            postAuxKey(NX_KEYTYPE_ILLUMINATION_DOWN)
            Thread.sleep(forTimeInterval: 0.015)
        }
        isOn = false
    }

    /// Sendet `stepCount` mal UP — Tastatur auf maximale Helligkeit.
    static func turnOn() {
        for _ in 0..<stepCount {
            postAuxKey(NX_KEYTYPE_ILLUMINATION_UP)
            Thread.sleep(forTimeInterval: 0.015)
        }
        isOn = true
    }

    /// Toggle zwischen On / Off.
    static func toggle() {
        if isOn {
            turnOff()
        } else {
            turnOn()
        }
    }
}
