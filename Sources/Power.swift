// Everything Lid Awake asks of the system: is sleep disabled, is the lid closed, and
// turning sleep on and off.
//
// Measured on this Mac (MacBook, macOS 26.4, 2026-11-05):
// - Closing the lid puts the Mac to sleep unless `pmset -a disablesleep 1` is set
//   (or an external display, power and keyboard make it a clamshell desktop). The
//   setting needs root and survives reboots.
// - The lid is IOPMrootDomain's "AppleClamshellState" (Yes = closed); a change is
//   announced to the root domain's general-interest clients.
import Foundation
import IOKit

let pmset = "/usr/bin/pmset"
let bundlePrefix = "com.makebecome.lid-awake"
let sudoersFile = "/etc/sudoers.d/lid-awake"
let resetDaemon = "/Library/LaunchDaemons/\(bundlePrefix).reset.plist"

@discardableResult
func run(_ exe: String, _ args: [String]) -> (status: Int32, out: String) {
    let p = Process(); p.executableURL = URL(fileURLWithPath: exe); p.arguments = args
    let pipe = Pipe(); p.standardOutput = pipe; p.standardError = pipe
    guard (try? p.run()) != nil else { return (-1, "") }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    return (p.terminationStatus, String(data: data, encoding: .utf8) ?? "")
}

/// `pmset -g` prints "SleepDisabled  1" while sleep is disabled. Readable without root.
func sleepDisabled() -> Bool {
    run(pmset, ["-g"]).out.split(separator: "\n").contains { l in
        let w = l.split(whereSeparator: { $0 == " " || $0 == "\t" })
        return w.first == "SleepDisabled" && w.last == "1"
    }
}

/// The only root command the app runs, and the only one its sudoers rule allows.
/// `sudo -n` never asks for a password: without the rule it just fails.
@discardableResult
func setSleepDisabled(_ on: Bool) -> Bool {
    run("/usr/bin/sudo", ["-n", pmset, "-a", "disablesleep", on ? "1" : "0"]).status == 0 && sleepDisabled() == on
}

var permissionInstalled: Bool { FileManager.default.fileExists(atPath: sudoersFile) }

private let rootDomain = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))

func lidClosed() -> Bool {
    (IORegistryEntryCreateCFProperty(rootDomain, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0)?
        .takeRetainedValue() as? Bool) ?? false
}

/// Calls `changed` on the main thread whenever the root domain says anything; the caller
/// compares lid states, so unrelated messages cost one property read.
private var lidCallback: (() -> Void)?
private var lidNotifier: io_object_t = 0
func watchLid(_ changed: @escaping () -> Void) {
    lidCallback = changed
    let port = IONotificationPortCreate(kIOMainPortDefault)
    CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(port).takeUnretainedValue(), .defaultMode)
    IOServiceAddInterestNotification(port, rootDomain, "IOGeneralInterest", { _, _, _, _ in
        DispatchQueue.main.async { lidCallback?() }
    }, nil, &lidNotifier)
}

// MARK: - The one-time permission

/// Installs, as root and after macOS's own password dialog, the two files that are all
/// Lid Awake ever puts outside its own bundle:
/// - a sudoers rule letting this user (by uid) run exactly `pmset -a disablesleep 0|1`;
/// - a LaunchDaemon that runs `pmset -a disablesleep 0` at boot, so a restart never
///   leaves sleep disabled. It is not loaded now (that would reset the setting at once).
func installPermission() -> String? {
    let sudoers = """
    # Installed by Lid Awake (\(bundlePrefix)): lets this user turn "sleep disabled" on and off, nothing else.
    #\(getuid()) ALL=(root) NOPASSWD: \(pmset) -a disablesleep 0, \(pmset) -a disablesleep 1

    """
    let daemon = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><dict>
    <key>Label</key><string>\(bundlePrefix).reset</string>
    <key>ProgramArguments</key><array><string>\(pmset)</string><string>-a</string><string>disablesleep</string><string>0</string></array>
    <key>RunAtLoad</key><true/>
    </dict></plist>

    """
    // base64 keeps the file contents out of AppleScript's and the shell's quoting.
    let b64 = { (s: String) in Data(s.utf8).base64EncodedString() }
    let script = [
        "set -e", "T=$(mktemp -d)",
        "echo \(b64(sudoers)) | base64 -D > $T/s", "/usr/sbin/visudo -cf $T/s >/dev/null",
        "echo \(b64(daemon)) | base64 -D > $T/d", "/usr/bin/plutil -lint $T/d >/dev/null",
        "install -m 0440 -o root -g wheel $T/s '\(sudoersFile)'",
        "install -m 0644 -o root -g wheel $T/d '\(resetDaemon)'",
        "rm -rf $T",
    ].joined(separator: "; ")
    return asRoot(script, prompt: t("setupPrompt"))
}

func removePermission() -> String? {
    asRoot("rm -f '\(sudoersFile)' '\(resetDaemon)'", prompt: t("removePrompt"))
}

/// macOS's own administrator dialog; the password never reaches this app. nil = done.
private func asRoot(_ shell: String, prompt: String) -> String? {
    let esc = { (s: String) in s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") }
    var err: NSDictionary?
    NSAppleScript(source: "do shell script \"\(esc(shell))\" with prompt \"\(esc(prompt))\" with administrator privileges")?
        .executeAndReturnError(&err)
    guard let err else { return nil }
    if (err[NSAppleScript.errorNumber] as? Int) == -128 { return "" }  // the user pressed Cancel
    return err[NSAppleScript.errorMessage] as? String ?? "\(err)"
}

// MARK: - Guard

/// `LidAwake --guard <pid>`: a tiny second process that waits for the app to exit, however
/// it exits (Quit, crash, Force Quit), and then turns sleep back on.
func runGuard(_ parent: pid_t) -> Never {
    let kq = kqueue()
    var ev = kevent(ident: UInt(parent), filter: Int16(EVFILT_PROC), flags: UInt16(EV_ADD | EV_ONESHOT),
                    fflags: NOTE_EXIT, data: 0, udata: nil)
    if kevent(kq, &ev, 1, nil, 0, nil) == 0 {
        var out = kevent()
        _ = kevent(kq, nil, 0, &out, 1, nil)
    }  // else the parent is already gone
    if sleepDisabled() { setSleepDisabled(false) }
    exit(0)
}
