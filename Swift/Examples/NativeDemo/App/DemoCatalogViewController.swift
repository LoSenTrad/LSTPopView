import UIKit

/// 原生 Swift Demo 的独立入口；原 OC 示例、共存 consumer 与本目录互不覆盖。
/// 基础和进阶场景各自在自己的文件维护，目录只消费 DemoScene 描述并按需创建页面。
@MainActor
final class DemoCatalogViewController: UITableViewController {
    private struct Section {
        let title: String
        let footer: String
        let scenes: [DemoScene]
    }

    private let sections = [
        Section(
            title: "基础用法 · 从创建到交互",
            footer: "每个页面包含详细说明、观察要点和事件日志，可重复操作比较实际行为。",
            scenes: BasicDemoScenes.scenes
        ),
        Section(
            title: "进阶场景 · 队列与生命周期",
            footer: "所有操作只影响当前演示宿主；返回目录会关闭本页弹窗，不调用全局账号失效。",
            scenes: AdvancedDemoScenes.scenes
        )
    ]

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("NativeDemo 目录使用纯代码初始化。")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swift 弹窗示例"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        view.accessibilityIdentifier = "nativeDemo.catalog"
        tableView.accessibilityIdentifier = "nativeDemo.sceneList"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 112
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "scene")
        configureHeader()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].scenes.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scene = sections[indexPath.section].scenes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "scene", for: indexPath)
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = scene.title
        configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
        configuration.textProperties.numberOfLines = 0
        configuration.secondaryText = "\(scene.subtitle)\nID：\(scene.id)"
        configuration.secondaryTextProperties.font = .preferredFont(forTextStyle: .subheadline)
        configuration.secondaryTextProperties.color = .secondaryLabel
        configuration.secondaryTextProperties.numberOfLines = 0
        configuration.textToSecondaryTextVerticalPadding = 8
        configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 12)
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "nativeDemo.scene.\(scene.id)"
        cell.accessibilityLabel = "\(scene.title)。\(scene.subtitle)"
        cell.accessibilityValue = "场景 ID：\(scene.id)"
        cell.accessibilityHint = "打开独立场景，查看操作和事件日志。"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let scene = sections[indexPath.section].scenes[indexPath.row]
        let controller = scene.makeViewController()
        (controller as? DemoSceneViewController)?.demoSceneID = scene.id
        controller.restorationIdentifier = scene.id
        navigationController?.pushViewController(controller, animated: true)
    }

    /// 使用自动布局测量 tableHeaderView，避免把不同屏幕宽度或动态字体写死为固定高度。
    private func configureHeader() {
        let heading = UILabel()
        heading.text = "原生 Swift / UIKit"
        heading.font = .preferredFont(forTextStyle: .title3)
        heading.adjustsFontForContentSizeCategory = true
        heading.textColor = .systemTeal
        let detail = UILabel()
        detail.text = "从常用弹窗到队列、键盘与生命周期，逐页观察真实运行结果。仅使用系统框架和仓库本地 LSTPopViewSwift Package。"
        detail.font = .preferredFont(forTextStyle: .subheadline)
        detail.adjustsFontForContentSizeCategory = true
        detail.textColor = .secondaryLabel
        detail.numberOfLines = 0
        let boundary = UILabel()
        boundary.text = "iOS 15+ · Swift 6.2+ · 不修改原 Objective-C Demo"
        boundary.font = .preferredFont(forTextStyle: .caption1)
        boundary.adjustsFontForContentSizeCategory = true
        boundary.textColor = .secondaryLabel
        boundary.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [heading, detail, boundary])
        stack.axis = .vertical
        stack.spacing = 10
        let header = UIView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: header.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])
        tableView.tableHeaderView = header
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let header = tableView.tableHeaderView else { return }
        let width = tableView.bounds.width
        let height = header.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if header.frame.width != width || abs(header.frame.height - height) > 0.5 {
            header.frame = CGRect(x: 0, y: 0, width: width, height: height)
            tableView.tableHeaderView = header
        }
    }
}
