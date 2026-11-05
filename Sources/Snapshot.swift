// `LidAwake --snapshot <dir>` renders the app's own menu to PNG for the web page, once with the
// switch off and once on. (The menu-bar icon itself is drawn by the system, outside this process.)
// It captures only this process's windows, so nothing else on the screen ends up in a picture.
import AppKit

private typealias CreateImage = @convention(c) (CGRect, UInt32, UInt32, UInt32) -> Unmanaged<CGImage>?
// Looked up at run time: the SDK marks it obsolete, but it still captures a process's own windows.
private let createImage: CreateImage? = {
    guard let h = dlopen(nil, RTLD_NOW), let f = dlsym(h, "CGWindowListCreateImage") else { return nil }
    return unsafeBitCast(f, to: CreateImage.self)
}()

private func captureMenu(to path: String) {
    let level = Int(CGWindowLevelForKey(.popUpMenuWindow))
    let all = (CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]]) ?? []
    guard let w = all.first(where: { ($0[kCGWindowOwnerPID as String] as? Int32) == getpid() && ($0[kCGWindowLayer as String] as? Int) == level }),
          let id = w[kCGWindowNumber as String] as? UInt32,
          let img = createImage?(.null, 8 /* optionIncludingWindow */, id, 1 /* boundsIgnoreFraming */ | 8 /* bestResolution */)?.takeRetainedValue()
    else { FileHandle.standardError.write("no menu window to capture\n".data(using: .utf8)!); return }
    try? NSBitmapImageRep(cgImage: img).representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
}

private func after(_ s: TimeInterval, _ f: @escaping () -> Void) {
    let tm = Timer(timeInterval: s, repeats: false) { _ in f() }
    [RunLoop.Mode.default, .eventTracking].forEach { RunLoop.main.add(tm, forMode: $0) }
}

extension Delegate {
    func snapshot(to dir: String) {
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        NSApp.activate(ignoringOtherApps: true)
        func shot(_ on: Bool, then: @escaping () -> Void) {
            let m = NSMenu(); fill(m, on: on, permission: true, atLogin: true)
            after(0.8) { captureMenu(to: "\(dir)/menu-\(on ? "on" : "off")-\(lang).png"); m.cancelTracking() }
            after(1.2, then)
            m.popUp(positioning: nil, at: NSPoint(x: 300, y: 700), in: nil)
        }
        after(0.5) { shot(true) { shot(false) { exit(0) } } }
    }
}
