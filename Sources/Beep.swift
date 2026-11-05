// The lid-closed beep: audible even when the Mac is muted or at volume 0. The output is
// unmuted and raised for the length of the sound, then put back exactly as it was.
import AppKit
import CoreAudio

private func address(_ selector: AudioObjectPropertySelector, _ element: UInt32,
                     _ scope: AudioObjectPropertyScope = kAudioDevicePropertyScopeOutput) -> AudioObjectPropertyAddress {
    AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: element)
}

private func defaultOutput() -> AudioDeviceID? {
    var a = address(kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyElementMain, kAudioObjectPropertyScopeGlobal)
    var id = AudioDeviceID(0); var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    return AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &a, 0, nil, &size, &id) == noErr && id != 0 ? id : nil
}

private func get<T: BitwiseCopyable>(_ dev: AudioDeviceID, _ selector: AudioObjectPropertySelector, _ element: UInt32, _ zero: T) -> T? {
    var a = address(selector, element); var v = zero; var size = UInt32(MemoryLayout<T>.size)
    guard AudioObjectHasProperty(dev, &a) else { return nil }
    return AudioObjectGetPropertyData(dev, &a, 0, nil, &size, &v) == noErr ? v : nil
}

private func set<T: BitwiseCopyable>(_ dev: AudioDeviceID, _ selector: AudioObjectPropertySelector, _ element: UInt32, _ value: T) {
    var a = address(selector, element); var v = value
    var settable: DarwinBoolean = false
    guard AudioObjectHasProperty(dev, &a), AudioObjectIsPropertySettable(dev, &a, &settable) == noErr, settable.boolValue else { return }
    AudioObjectSetPropertyData(dev, &a, 0, nil, UInt32(MemoryLayout<T>.size), &v)
}

/// What the output was before the beep, per element: the main one if the device has a
/// master control, else the left and right channels (built-in speakers have a master).
struct OutputState {
    let device: AudioDeviceID
    var volumes: [UInt32: Float32] = [:]
    var mutes: [UInt32: UInt32] = [:]

    init?() {
        guard let d = defaultOutput() else { return nil }
        device = d
        for e in [kAudioObjectPropertyElementMain, 1, 2] {
            if let v = get(d, kAudioDevicePropertyVolumeScalar, e, Float32(0)) { volumes[e] = v }
            if let m = get(d, kAudioDevicePropertyMute, e, UInt32(0)) { mutes[e] = m }
        }
        if volumes[kAudioObjectPropertyElementMain] != nil { volumes[1] = nil; volumes[2] = nil }
    }

    func raise(to level: Float32) {
        for e in mutes.keys { set(device, kAudioDevicePropertyMute, e, UInt32(0)) }
        for (e, v) in volumes where v < level { set(device, kAudioDevicePropertyVolumeScalar, e, level) }
    }

    func restore() {
        for (e, v) in volumes { set(device, kAudioDevicePropertyVolumeScalar, e, v) }
        for (e, m) in mutes { set(device, kAudioDevicePropertyMute, e, m) }
    }
}

let beepLevel: Float32 = 0.5
private var playing: NSSound?

/// Two chimes, then the volume goes back. Returns the state it raised from, for tests.
@discardableResult
func lidBeep(done: (() -> Void)? = nil) -> OutputState? {
    let before = OutputState()
    before?.raise(to: beepLevel)
    let sound = NSSound(contentsOfFile: "/System/Library/Sounds/Glass.aiff", byReference: true)
    playing = sound
    let length = sound?.duration ?? 1
    sound?.play()
    DispatchQueue.main.asyncAfter(deadline: .now() + length * 0.6) { _ = playing?.stop(); playing?.play() }
    DispatchQueue.main.asyncAfter(deadline: .now() + length * 1.6 + 0.3) {
        playing = nil
        before?.restore()
        done?()
    }
    return before
}
