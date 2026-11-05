// Lid Awake: one switch in the menu bar that keeps the Mac running with the lid closed.
//
// ON is `pmset -a disablesleep 1`, OFF is `disablesleep 0`. It is meant for one job at a
// time, so it never stays on by accident:
// - closing the lid while it is on plays a beep, audible even when muted, so you know;
// - opening the lid again turns it off;
// - quitting, a crash or a Force Quit turn it off (a guard process waits for the app);
// - a restart turns it off (a LaunchDaemon at boot), and so does the app's next start.
import AppKit
import ServiceManagement

let appVersion = "1.0.0"

let args = CommandLine.arguments
if let i = args.firstIndex(of: "--guard"), i + 1 < args.count, let p = pid_t(args[i + 1]) { runGuard(p) }

final class Delegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var lastLid = lidClosed()

    func applicationDidFinishLaunching(_ n: Notification) {
        if let i = args.firstIndex(of: "--snapshot"), i + 1 < args.count { snapshot(to: args[i + 1]); return }
        if args.contains("--beep") { beepFromCommandLine(); return }
        if NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "").count > 1 {
            exit(0)
        }
        if sleepDisabled() { setSleepDisabled(false) }  // whatever was left on before this start
        let g = Process(); g.executableURL = Bundle.main.executableURL; g.arguments = ["--guard", "\(getpid())"]
        try? g.run()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let m = NSMenu(); m.delegate = self; statusItem.menu = m
        watchLid { [weak self] in self?.lidChanged() }
        // The notification is the signal; this only catches one that was missed.
        let tm = Timer(timeInterval: 5, repeats: true) { [weak self] _ in self?.lidChanged() }
        RunLoop.main.add(tm, forMode: .common)
        refreshIcon()
    }

    /// Opening the app again (Spotlight, Finder) pops its menu where the mouse is: the
    /// menu-bar icon can be hidden by the notch or by System Settings → Menu Bar.
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool {
        let m = NSMenu(); menuNeedsUpdate(m)
        NSApp.activate(ignoringOtherApps: true)
        m.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        return false
    }

    func applicationWillTerminate(_ n: Notification) {
        if sleepDisabled() { setSleepDisabled(false) }
    }

    func lidChanged() {
        let closed = lidClosed()
        defer { refreshIcon() }
        guard closed != lastLid else { return }
        lastLid = closed
        guard sleepDisabled() else { return }
        if closed { lidBeep() } else { setSleepDisabled(false) }
    }

    func refreshIcon() {
        guard let b = statusItem?.button else { return }
        let on = sleepDisabled()
        // Same laptop either way; red while sleep is disabled.
        let img = NSImage(systemSymbolName: "laptopcomputer", accessibilityDescription: t(on ? "isOn" : "isOff"))
        b.image = on ? img?.withSymbolConfiguration(.init(paletteColors: [.systemRed])) : img
        b.image?.isTemplate = !on
        b.toolTip = t(on ? "isOn" : "isOff")
    }

    // MARK: Menu

    func item(_ title: String, _ action: Selector?) -> NSMenuItem {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: ""); i.target = self; return i
    }

    func fill(_ m: NSMenu, on: Bool, permission: Bool, atLogin: Bool) {
        m.removeAllItems()
        let sw = item(t("stayOn"), #selector(toggle)); sw.state = on ? .on : .off; m.addItem(sw)
        m.addItem(item(t(on ? "isOn" : "isOff"), nil))
        if on { m.addItem(item(t("autoOff"), nil)) }
        m.addItem(.separator())
        m.addItem(item(t("testBeep"), #selector(testBeep)))
        let al = item(t("atLogin"), #selector(toggleAtLogin)); al.state = atLogin ? .on : .off; m.addItem(al)
        m.addItem(permission ? item(t("removeSetup"), #selector(removeSetup)) : item(t("setup"), #selector(setup)))
        m.addItem(.separator())
        m.addItem(item(t("quit"), #selector(quit)))
    }

    func menuNeedsUpdate(_ m: NSMenu) {
        fill(m, on: sleepDisabled(), permission: permissionInstalled, atLogin: SMAppService.mainApp.status == .enabled)
        refreshIcon()
    }

    @objc func toggle() {
        let want = !sleepDisabled()
        if !permissionInstalled && !askSetup() { return }
        if !setSleepDisabled(want) { alert(t("failed"), "sudo -n \(pmset) -a disablesleep \(want ? 1 : 0)") }
        lastLid = lidClosed()
        refreshIcon()
    }

    @objc func testBeep() { lidBeep() }

    @objc func toggleAtLogin() {
        if SMAppService.mainApp.status == .enabled { try? SMAppService.mainApp.unregister() } else { try? SMAppService.mainApp.register() }
    }

    @objc func setup() { _ = askSetup() }

    @objc func removeSetup() {
        if sleepDisabled() { setSleepDisabled(false) }
        if let e = removePermission(), !e.isEmpty { alert(t("failed"), e) }
        refreshIcon()
    }

    @objc func quit() { NSApp.terminate(nil) }

    /// Explains the one-time permission, then lets macOS ask for the password. true = installed.
    func askSetup() -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert(); a.messageText = t("needSetupTitle"); a.informativeText = t("needSetupText")
        a.addButton(withTitle: t("continue")); a.addButton(withTitle: t("cancel"))
        guard a.runModal() == .alertFirstButtonReturn else { return false }
        if let e = installPermission() {
            if !e.isEmpty { alert(t("failed"), e) }
            return false
        }
        return permissionInstalled
    }

    func alert(_ title: String, _ text: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert(); a.messageText = title; a.informativeText = text; a.runModal()
    }

    /// `LidAwake --beep`: plays the lid-closed beep and prints the output volume before,
    /// during and after, so the restore can be checked from a script.
    func beepFromCommandLine() {
        let describe = { (s: OutputState?) -> String in
            guard let s else { return "no output device" }
            return "volumes \(s.volumes.sorted { $0.key < $1.key }) mutes \(s.mutes.sorted { $0.key < $1.key })"
        }
        print("before: " + describe(OutputState()))
        lidBeep { print("after:  " + describe(OutputState())); exit(0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { print("during: " + describe(OutputState())) }
    }
}

let app = NSApplication.shared
let delegate = Delegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
