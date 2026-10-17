import UIKit

@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default", sessionRole: .windowApplication)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = CoexistenceViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

@MainActor
final class CoexistenceViewController: UIViewController {
    private var pair: CoexistencePair!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "OC + Swift coexistence"
        view.backgroundColor = .systemBackground
        pair = CoexistencePair(host: view)

        let title = UILabel()
        title.text = "Two independent implementations\nOne iOS executable"
        title.font = .preferredFont(forTextStyle: .title2)
        title.textAlignment = .center
        title.numberOfLines = 0
        let detail = UILabel()
        detail.text = "OC runtime: \(pair.legacyRuntimeName)\nSwift runtime: \(pair.nativeRuntimeName)\n\nTap a popup's background to dismiss it."
        detail.numberOfLines = 0
        detail.font = .preferredFont(forTextStyle: .footnote)
        detail.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [
            title,
            button("Show original Objective-C", action: #selector(showLegacy)),
            button("Show native Swift", action: #selector(showNative)),
            button("Show both", action: #selector(showBoth)),
            detail
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func button(_ title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func showLegacy() { pair.legacy.pop() }
    @objc private func showNative() { pair.native.pop() }
    @objc private func showBoth() { pair.showBoth() }
}
