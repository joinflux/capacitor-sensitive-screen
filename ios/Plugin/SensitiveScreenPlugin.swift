import Capacitor
import UIKit

@objc(SensitiveScreenPlugin)
public class SensitiveScreenPlugin: CAPPlugin {

    private enum OverlayStyle: String {
        case solid
        case blur
    }

    private struct OverlayOptions {
        var style: OverlayStyle = .solid
        var backgroundColor: UIColor = .black
        var blurEffectStyle: UIBlurEffect.Style = .regular
        var imageName: String?
    }

    private var isEnabled = false
    private var overlayView: UIView?
    private var observers: [NSObjectProtocol] = []
    private var options = OverlayOptions()

    override public func load() {
        let center = NotificationCenter.default

        observers.append(
            center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleWillResignActive()
            }
        )

        observers.append(
            center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleDidBecomeActive()
            }
        )
    }

    deinit {
        let center = NotificationCenter.default
        for observer in observers {
            center.removeObserver(observer)
        }
    }

    @objc func enable(_ call: CAPPluginCall) {
        options = parseOptions(from: call)
        isEnabled = true
        call.resolve()
    }

    @objc func disable(_ call: CAPPluginCall) {
        isEnabled = false
        call.resolve()
    }

    // MARK: - Lifecycle

    private func handleWillResignActive() {
        guard isEnabled, overlayView == nil else { return }
        guard let window = activeKeyWindow() else { return }

        let overlay = buildOverlay(frame: window.bounds)
        window.addSubview(overlay)
        overlayView = overlay
    }

    private func activeKeyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        if let active = scenes.first(where: { $0.activationState == .foregroundActive }) {
            return active.keyWindow ?? active.windows.first { $0.isKeyWindow } ?? active.windows.first
        }

        if let inactive = scenes.first(where: { $0.activationState == .foregroundInactive }) {
            return inactive.keyWindow ?? inactive.windows.first { $0.isKeyWindow } ?? inactive.windows.first
        }

        return nil
    }

    private func handleDidBecomeActive() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }

    // MARK: - Options

    private func parseOptions(from call: CAPPluginCall) -> OverlayOptions {
        var next = OverlayOptions()

        if let styleString = call.getString("style"),
           let style = OverlayStyle(rawValue: styleString) {
            next.style = style
        }

        if let hex = call.getString("backgroundColor"),
           let color = UIColor(hex: hex) {
            next.backgroundColor = color
        }

        if let blurString = call.getString("blurStyle"),
           let blur = Self.blurEffectStyle(from: blurString) {
            next.blurEffectStyle = blur
        }

        if let imageName = call.getString("imageName"), !imageName.isEmpty {
            next.imageName = imageName
        }

        return next
    }

    // MARK: - Overlay construction

    private func buildOverlay(frame: CGRect) -> UIView {
        let container: UIView

        switch options.style {
        case .solid:
            container = UIView(frame: frame)
            container.backgroundColor = options.backgroundColor
        case .blur:
            let effect = UIBlurEffect(style: options.blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = frame
            container = effectView
        }

        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if let name = options.imageName, let image = UIImage(named: name) {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            let host: UIView = (container as? UIVisualEffectView)?.contentView ?? container
            host.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: host.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: host.centerYAnchor),
            ])
        }

        return container
    }

    private static func blurEffectStyle(from name: String) -> UIBlurEffect.Style? {
        switch name {
        case "light": return .light
        case "dark": return .dark
        case "regular": return .regular
        case "prominent": return .prominent
        case "extraLight": return .extraLight
        default: return nil
        }
    }
}

private extension UIColor {
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }

        guard s.count == 6 || s.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&value) else { return nil }

        let r, g, b, a: CGFloat
        if s.count == 6 {
            r = CGFloat((value >> 16) & 0xff) / 255.0
            g = CGFloat((value >> 8) & 0xff) / 255.0
            b = CGFloat(value & 0xff) / 255.0
            a = 1.0
        } else {
            r = CGFloat((value >> 24) & 0xff) / 255.0
            g = CGFloat((value >> 16) & 0xff) / 255.0
            b = CGFloat((value >> 8) & 0xff) / 255.0
            a = CGFloat(value & 0xff) / 255.0
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
