#!/usr/bin/env swift
// make-icon.swift — rendert ein 1024x1024 PNG für NightKey.
// Usage: swift make-icon.swift <output.png>

import Cocoa

guard CommandLine.arguments.count == 2 else {
    print("Usage: swift make-icon.swift <output.png>")
    exit(1)
}

let outputPath = CommandLine.arguments[1]
let size = NSSize(width: 1024, height: 1024)

let image = NSImage(size: size)
image.lockFocus()

// Hintergrund: Nacht-Verlauf (dunkles Indigo → Schwarz)
let bg = NSBezierPath(
    roundedRect: NSRect(origin: .zero, size: size),
    xRadius: 180,
    yRadius: 180
)
bg.addClip()
let gradient = NSGradient(colors: [
    NSColor(srgbRed: 0.20, green: 0.18, blue: 0.45, alpha: 1.0),
    NSColor(srgbRed: 0.05, green: 0.04, blue: 0.15, alpha: 1.0)
])!
gradient.draw(in: NSRect(origin: .zero, size: size), angle: -90)

// Tastatur-Emoji als Glyph rendern
let glyph = "⌨" as NSString
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 720, weight: .regular),
    .foregroundColor: NSColor.white,
    .paragraphStyle: {
        let s = NSMutableParagraphStyle()
        s.alignment = .center
        return s
    }()
]
let glyphSize = glyph.size(withAttributes: attributes)
let glyphRect = NSRect(
    x: (size.width - glyphSize.width) / 2,
    y: (size.height - glyphSize.height) / 2 - 30,
    width: glyphSize.width,
    height: glyphSize.height
)
glyph.draw(in: glyphRect, withAttributes: attributes)

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("FEHLER: Konnte PNG nicht erzeugen.")
    exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
print("OK: \(outputPath)")
