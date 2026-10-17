import UIKit

/// 独立可运行的原生 Swift 示例。没有账号、网络服务、CocoaPods 或旧 Demo 的启动依赖。
@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Native Swift Demo", sessionRole: .windowApplication)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

/// 每个 UIWindowScene 都有自己的导航目录和演示页，弹窗始终显式绑定所在页面的 view。
@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigation = UINavigationController(rootViewController: DemoCatalogViewController())
        navigation.view.tintColor = .systemTeal
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // scene 关闭时只回收它自己的演示页；不撤销其它 scene 或全应用的展示上下文。
        guard let navigation = window?.rootViewController as? UINavigationController else { return }
        navigation.viewControllers.compactMap { $0 as? DemoSceneViewController }.forEach { $0.clearScenePopups() }
    }
}
