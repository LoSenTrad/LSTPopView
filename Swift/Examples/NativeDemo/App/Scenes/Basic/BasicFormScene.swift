import UIKit
import LSTPopViewSwift

@MainActor
final class BasicFormScene: DemoSceneViewController {
    private let avoidKeyboard = UISwitch()

    init() {
        super.init(sceneTitle: "输入表单与键盘", introduction: "输入一项本地演示任务。可以对比开启/关闭键盘避让，验证空值校验、取消和提交。输入不会存盘或上传。", learnings: [
            "先给自定义内容真实尺寸，再配置 isAvoidKeyboard 和 avoidKeyboardSpace。",
            "文本输入控件不需要被替换；库只根据实际键盘重叠移动整个内容 UIView。",
            "关闭避让时也可用键盘工具条或点击背景收起键盘，草稿不丢失。",
            "保存、取消和展示回调均弱捕获内容/弹窗/页面；关闭时结束编辑。"
        ])
    }

    required init?(coder: NSCoder) { fatalError("This demo creates pages in Swift") }

    override func configureDemo() {
        avoidKeyboard.isOn = true
        avoidKeyboard.accessibilityIdentifier = "basic.form.avoidKeyboard"
        let row = UIStackView(arrangedSubviews: [BasicUI.label("开启键盘避让（下次展示生效）"), avoidKeyboard])
        row.spacing = 12
        addControl(row)
        addAction("打开空白表单", subtitle: "空标题提交会在弹窗内显示校验信息", accessibilityID: "basic.form.show") { [weak self] in self?.showForm(prefilled: false) }
        addAction("打开预填演示表单", subtitle: "只有虚构任务内容，没有真实个人资料", accessibilityID: "basic.form.prefilled") { [weak self] in self?.showForm(prefilled: true) }
    }

    private func showForm(prefilled: Bool) {
        let content = BasicFormContent(width: BasicUI.width(in: view))
        if prefilled {
            content.titleField.text = "阅读弹窗示例"
            content.notes.text = "这段文字仅用于本地演示，关闭后不会持久化。"
        }
        guard let popup = makePopup(content: content, group: "basic.form") else { return }
        popup.isSingle = true
        popup.isAvoidKeyboard = avoidKeyboard.isOn
        popup.avoidKeyboardSpace = 14
        // 编辑场景不允许背景点击直接丢失草稿；页面里有明确的取消按钮。
        popup.isClickBgDismiss = false
        popup.bgClickBlock = { [weak self, weak content] in
            content?.endEditing(true)
            self?.log("点击背景：只收起键盘，表单及本轮草稿继续保留。")
        }
        content.onCancel = { [weak self, weak popup, weak content] in
            content?.endEditing(true)
            self?.log("已取消表单，输入只留在本轮 UIView 中，没有持久化。")
            popup?.dismiss()
        }
        content.onSave = { [weak self, weak popup, weak content] title, note in
            // 校验在内容内完成，此处演示把结果交回页面；日志只记长度，不暴露完整输入。
            self?.log("模拟保存成功：标题 \(title.count) 字、备注 \(note.count) 字；未写文件或请求网络。")
            content?.endEditing(true)
            popup?.dismiss()
        }
        popup.popViewDidPopBlock = { [weak content] in content?.titleField.becomeFirstResponder() }
        popup.keyboardWillShowBlock = { [weak self] in self?.log("收到 keyboardWillShow，库按实际遮挡计算位移。") }
        popup.keyboardWillHideBlock = { [weak self] in self?.log("收到 keyboardWillHide，库恢复本轮原始位置。") }
        popup.popViewDidDismissBlock = { [weak self] in self?.log("表单已移除，可重新打开一份独立内容。") }
        popup.pop()
        log("打开表单：键盘避让 \(avoidKeyboard.isOn ? "开启" : "关闭")。")
    }
}

/// 自定义业务内容独立于 popup：它只发布保存/取消意图，不直接管理全局弹窗。
/// 宽高在 init 时确定；控件使用自身 bounds 排版，库负责整个内容在父视图中的位置。
@MainActor
private final class BasicFormContent: UIView, UITextFieldDelegate {
    let titleField = UITextField()
    let notes = UITextView()
    var onSave: (@MainActor (String, String) -> Void)?
    var onCancel: (@MainActor () -> Void)?
    private let stack = UIStackView()
    private let validation = BasicUI.label("标题不能为空，最多 20 个字符。", size: 13, color: .secondaryLabel)

    init(width: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 430))
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        titleField.borderStyle = .roundedRect
        titleField.placeholder = "输入演示任务标题"
        titleField.returnKeyType = .next
        titleField.clearButtonMode = .whileEditing
        titleField.autocorrectionType = .no
        titleField.delegate = self
        titleField.accessibilityIdentifier = "basic.form.title"
        titleField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        notes.font = .systemFont(ofSize: 15)
        notes.backgroundColor = .tertiarySystemBackground
        notes.layer.cornerRadius = 10
        notes.accessibilityLabel = "演示任务备注"
        notes.accessibilityIdentifier = "basic.form.notes"
        notes.heightAnchor.constraint(equalToConstant: 108).isActive = true
        // isAvoidKeyboard=false 是有意演示“库不移动内容”，软件键盘可能盖住保存/取消。
        // 因此两个输入控件共用一个可见的 inputAccessoryView；先收起键盘就能访问全部按钮。
        // 工具条只 endEditing，不 dismiss、不清空文本，也不偷偷重新打开库的避让开关。
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        toolbar.autoresizingMask = .flexibleWidth
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let hideKeyboard = UIBarButtonItem(title: "收起键盘", style: .done, target: self, action: #selector(hideKeyboardTapped))
        hideKeyboard.accessibilityIdentifier = "basic.form.hideKeyboard"
        toolbar.items = [flexibleSpace, hideKeyboard]
        titleField.inputAccessoryView = toolbar
        notes.inputAccessoryView = toolbar
        validation.accessibilityIdentifier = "basic.form.validation"
        let cancel = BasicUI.button("取消", id: "basic.form.cancel") { [weak self] in self?.onCancel?() }
        let save = BasicUI.button("模拟保存", id: "basic.form.save") { [weak self] in self?.submit() }
        [BasicUI.label("创建演示任务", size: 21, bold: true), titleField, BasicUI.label("备注（可选）", size: 13, color: .secondaryLabel), notes, validation, BasicUI.row([cancel, save])].forEach(stack.addArrangedSubview)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22)
        ])
        // 不能只设置约束后直接 pop；先量出该宽度下的自然高度，再把尺寸交给库。
        let fitting = stack.systemLayoutSizeFitting(CGSize(width: width - 40, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        frame.size.height = ceil(fitting.height) + 44
    }

    required init?(coder: NSCoder) { fatalError("This demo creates content in Swift") }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        notes.becomeFirstResponder()
        return true
    }

    @objc private func hideKeyboardTapped() { endEditing(true) }

    private func submit() {
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, title.count <= 20 else {
            validation.text = title.isEmpty ? "请先输入任务标题。" : "标题超过 20 个字符，请缩短后重试。"
            validation.textColor = .systemRed
            titleField.becomeFirstResponder()
            return
        }
        onSave?(title, notes.text ?? "")
    }
}
