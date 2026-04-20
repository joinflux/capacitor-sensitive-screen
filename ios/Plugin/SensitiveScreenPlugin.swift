import Capacitor
import UIKit

@objc(SensitiveScreenPlugin)
public class SensitiveScreenPlugin: CAPPlugin {

    private var isEnabled = false
    private var overlayView: UIView?
    private var observers: [NSObjectProtocol] = []

    // Solid black covers the system snapshot reliably. Swap here to a brand
    // color if the consuming app wants a themed placeholder.
    private let overlayBackgroundColor: UIColor = .black

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
        guard let window = UIApplication.shared.windows.first else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = overlayBackgroundColor
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlay)
        overlayView = overlay
    }

    private func handleDidBecomeActive() {
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
}
