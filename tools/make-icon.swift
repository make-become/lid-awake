// swift tools/make-icon.swift → Resources/AppIcon.icns and docs/img/app-icon.png
// A closed laptop seen from the side under a small sun: the lid is shut, the Mac is on.
import AppKit
func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let n = CGFloat(px)
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let bg = NSRect(x: n * 0.1, y: n * 0.1, width: n * 0.8, height: n * 0.8)
    NSGradient(starting: NSColor(red: 0.14, green: 0.17, blue: 0.27, alpha: 1), ending: NSColor(red: 0.05, green: 0.06, blue: 0.11, alpha: 1))!
        .draw(in: NSBezierPath(roundedRect: bg, xRadius: n * 0.18, yRadius: n * 0.18), angle: -90)
    // the closed laptop: base and lid, a thin gap between them
    NSColor(white: 0.78, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: n * 0.22, y: n * 0.30, width: n * 0.56, height: n * 0.05), xRadius: n * 0.02, yRadius: n * 0.02).fill()
    NSColor(white: 0.62, alpha: 1).setFill()
    NSBezierPath(roundedRect: NSRect(x: n * 0.25, y: n * 0.365, width: n * 0.50, height: n * 0.035), xRadius: n * 0.015, yRadius: n * 0.015).fill()
    // the sun
    let sun = NSColor(red: 1.0, green: 0.78, blue: 0.25, alpha: 1)
    let c = NSPoint(x: n * 0.5, y: n * 0.60), r = n * 0.085
    sun.setFill(); NSBezierPath(ovalIn: NSRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)).fill()
    sun.setStroke()
    for k in 0..<8 {
        let a = CGFloat(k) * .pi / 4, p = NSBezierPath()
        p.lineWidth = n * 0.022; p.lineCapStyle = .round
        p.move(to: NSPoint(x: c.x + cos(a) * r * 1.45, y: c.y + sin(a) * r * 1.45))
        p.line(to: NSPoint(x: c.x + cos(a) * r * 1.9, y: c.y + sin(a) * r * 1.9)); p.stroke()
    }
    NSGraphicsContext.current = nil
    return rep.representation(using: .png, properties: [:])!
}
let set = URL(fileURLWithPath: NSTemporaryDirectory() + "AppIcon.iconset")
try? FileManager.default.removeItem(at: set)
try! FileManager.default.createDirectory(at: set, withIntermediateDirectories: true)
for s in [16, 32, 128, 256, 512] {
    try! render(s).write(to: set.appendingPathComponent("icon_\(s)x\(s).png"))
    try! render(s * 2).write(to: set.appendingPathComponent("icon_\(s)x\(s)@2x.png"))
}
try! render(512).write(to: URL(fileURLWithPath: "docs/img/app-icon.png"))
let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", set.path, "-o", "Resources/AppIcon.icns"]; try! p.run(); p.waitUntilExit()
