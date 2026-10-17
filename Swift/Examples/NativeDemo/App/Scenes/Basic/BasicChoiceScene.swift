import UIKit
import LSTPopViewSwift

@MainActor
final class BasicChoiceScene: DemoSceneViewController {
    private var lastSingle = "尚未确认"
    private var lastMultiple = [String]()

    init() {
        super.init(sceneTitle: "单选与多选列表", introduction: "列表中的勾选只是弹窗内部的临时状态。只有确认按钮才把选择结果交给页面，取消会直接丢弃本轮草稿。", learnings: [
            "列表内容使用 UITableView 的正常 delegate/dataSource，弹窗库不接管业务选择。",
            "单选替换集合，多选切换集合；用稳定行索引展示和排序结果。",
            "业务状态与展示状态分开，确认/取消闭包不反向强持有 popup。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        addAction("打开单选列表", subtitle: "选择一项，再确认；初始选中第一项", accessibilityID: "basic.choice.single") { [weak self] in self?.showChoices(multiple: false) }
        addAction("打开多选列表", subtitle: "可选择零项或多项，再确认", accessibilityID: "basic.choice.multiple") { [weak self] in self?.showChoices(multiple: true) }
        addAction("查看最近确认结果", accessibilityID: "basic.choice.result") { [weak self] in
            guard let self else { return }
            self.log("最近单选：\(self.lastSingle)；最近多选：\(self.lastMultiple.isEmpty ? "空集合" : self.lastMultiple.joined(separator: "、"))。")
        }
    }

    private func showChoices(multiple: Bool) {
        // parent 是当前页 view；内容还需要避开其上/下安全区。小高度宿主中只缩短列表视口，
        // 不把底部确认/取消一起挤到屏幕外，也不通过强制竖屏回避横屏/分屏布局。
        let maximumHeight = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 24
        guard maximumHeight >= 160 else {
            log("当前安全区域不足 160 pt，无法同时容纳可操作的列表和确认栏，请增大窗口后再试。")
            return
        }
        let content = BasicChoiceContent(width: BasicUI.width(in: view), maximumHeight: maximumHeight, multiple: multiple)
        guard let popup = makePopup(content: content, group: "basic.choice") else { return }
        // 将内容居中在安全区内；上下安全区不对称时，不能只使用父 bounds 的几何中心。
        popup.adjustY = (view.safeAreaInsets.top - view.safeAreaInsets.bottom) / 2
        popup.isSingle = true
        popup.isClickBgDismiss = false
        content.onChange = { [weak self] count in self?.log("临时选择 \(count) 项，尚未提交给页面。") }
        content.onCancel = { [weak self, weak popup] in
            self?.log("取消列表，最近确认结果保持不变。")
            popup?.dismiss()
        }
        content.onConfirm = { [weak self, weak popup] names in
            if multiple { self?.lastMultiple = names } else { self?.lastSingle = names.first ?? "空集合" }
            self?.log("已确认\(multiple ? "多选" : "单选")：\(names.isEmpty ? "空集合" : names.joined(separator: "、"))。")
            popup?.dismiss()
        }
        popup.pop()
    }
}

@MainActor
private final class BasicChoiceContent: UIView, UITableViewDataSource, UITableViewDelegate {
    var onConfirm: (@MainActor ([String]) -> Void)?
    var onCancel: (@MainActor () -> Void)?
    var onChange: (@MainActor (Int) -> Void)?
    private let options = ["阅读示例", "练习布局", "观察生命周期", "验证键盘", "学习弱引用", "查看回归测试"]
    private var selected: Set<Int>
    private let multiple: Bool
    private let table = UITableView(frame: .zero, style: .plain)
    private let countLabel = BasicUI.label("", size: 13, color: .secondaryLabel)

    init(width: CGFloat, maximumHeight: CGFloat, multiple: Bool) {
        self.multiple = multiple
        selected = multiple ? [] : [0]
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: maximumHeight))
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.rowHeight = 46
        table.tableFooterView = UIView()
        table.accessibilityIdentifier = "basic.choice.list"
        table.contentInsetAdjustmentBehavior = .never
        table.alwaysBounceVertical = true
        countLabel.accessibilityIdentifier = "basic.choice.count"
        let cancel = BasicUI.button("取消", id: "basic.choice.cancel") { [weak self] in self?.onCancel?() }
        let confirm = BasicUI.button("确认选择", id: "basic.choice.confirm") { [weak self] in
            guard let self else { return }
            self.onConfirm?(self.selected.sorted().map { self.options[$0] })
        }
        // 标题/计数随 tableHeaderView 一起滚动，避免它们在很短的宿主里挤占最后一行操作。
        // footer 放在表格外且固定 46 pt，所以滚到任何一项时都能立即确认或取消。
        updateCount()
        let heading = BasicUI.label(multiple ? "选择多项演示主题" : "选择一项演示主题", size: 20, bold: true)
        let header = UIView()
        let innerWidth = width - 40
        let headingHeight = ceil(heading.sizeThatFits(CGSize(width: innerWidth, height: .greatestFiniteMagnitude)).height)
        let countHeight = ceil(countLabel.sizeThatFits(CGSize(width: innerWidth, height: .greatestFiniteMagnitude)).height)
        heading.frame = CGRect(x: 0, y: 0, width: innerWidth, height: headingHeight)
        countLabel.frame = CGRect(x: 0, y: headingHeight + 10, width: innerWidth, height: countHeight)
        header.frame = CGRect(x: 0, y: 0, width: innerWidth, height: headingHeight + countHeight + 22)
        header.addSubview(heading)
        header.addSubview(countLabel)
        table.tableHeaderView = header
        let buttons = BasicUI.row([cancel, confirm])
        buttons.translatesAutoresizingMaskIntoConstraints = false
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)
        addSubview(buttons)
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            table.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            table.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            table.bottomAnchor.constraint(equalTo: buttons.topAnchor, constant: -12),
            buttons.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            buttons.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttons.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            buttons.heightAnchor.constraint(equalToConstant: 46)
        ])
        let naturalHeight = header.frame.height + CGFloat(options.count) * table.rowHeight + 46 + 52
        frame.size.height = min(maximumHeight, naturalHeight)
    }

    required init?(coder: NSCoder) { fatalError("This demo creates content in Swift") }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "choice") ?? UITableViewCell(style: .default, reuseIdentifier: "choice")
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 15)
        cell.textLabel?.numberOfLines = 2
        cell.backgroundColor = .clear
        cell.accessoryType = selected.contains(indexPath.row) ? .checkmark : .none
        cell.accessibilityIdentifier = "basic.choice.option.\(indexPath.row)"
        cell.accessibilityValue = selected.contains(indexPath.row) ? "已选择" : "未选择"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if multiple {
            if selected.contains(indexPath.row) { selected.remove(indexPath.row) } else { selected.insert(indexPath.row) }
        } else { selected = [indexPath.row] }
        updateCount()
        tableView.reloadData()
        onChange?(selected.count)
    }

    private func updateCount() { countLabel.text = "已选 \(selected.count) 项，点击确认后才生效。" }
}
