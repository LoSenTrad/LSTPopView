# LSTPopView iOS万能弹窗

[![Platform](https://img.shields.io/badge/platform-iOS-red.svg)](https://developer.apple.com/iphone/index.action) [![Language](http://img.shields.io/badge/language-OC-yellow.svg?style=flat )](https://en.wikipedia.org/wiki/Objective-C) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://mit-license.org) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/LSTPopView.svg)](https://img.shields.io/cocoapods/v/LSTPopView.svg)

### LSTPopView 万能弹窗,功能强大,易于拓展,性能优化和内存控制让其运行更加的流畅和稳健, LSTPopView的出现,可以让我们更专注弹窗页面的布局. 省心省力 ! 提高开发效率 !

## 原生 Swift 版本（可选）

本仓库同时维护原 Objective-C 实现和新的原生 Swift/UIKit 实现，按项目需要选择安装。

| | Objective-C 版 | 原生 Swift 版 |
|---|---|---|
| 模块 / Pod | `LSTPopView` | `LSTPopViewSwift` |
| 源码 | `LSTPopView/Classes/Code/` | `Swift/Sources/LSTPopViewSwift/` |
| 安装 | 原有 CocoaPods 入口保持不变 | Swift Package Manager、独立 CocoaPod 或手动集成 |
| 系统下限 | 原 podspec 的 iOS 8.0 保持不变 | iOS 15.0+ |
| Swift 工具链 | 不新增要求 | Swift 6.2+ / Xcode 26+，Swift 6 语言模式 |
| 第三方依赖 | 原有 `LSTTimer` 保持不变 | 无；仅使用系统框架 |

旧用户继续使用 `pod 'LSTPopView'`，无需迁移。原 OC 源码、头文件、podspec、默认 subspec 和旧示例保持原样；新增 Swift 文件不在原 OC 的 source glob 内。Swift 的系统和工具链要求只影响主动安装新模块的用户。

### Swift Package Manager

在 Xcode 的 **File → Add Package Dependencies** 中添加：

```text
https://github.com/LoSenTrad/LSTPopView.git
```

选择 **Branch: `master`**，并添加产品 **`LSTPopViewSwift`**。已有 `0.3.10` 及更早标签属于 OC 历史版本，不包含 Swift Package；需要固定版本时，可使用合并后的提交 revision。Swift 独立发版前，暂不使用这些 OC 标签选择 Swift 版本。

### Swift CocoaPods

新模块使用独立名称和源码范围。Swift Pod 尚未发布到 CocoaPods Trunk 时，使用仓库分支安装：

```ruby
platform :ios, '15.0'
pod 'LSTPopViewSwift', :git => 'https://github.com/LoSenTrad/LSTPopView.git', :branch => 'master'
```

原 OC 用户的 `pod 'LSTPopView'` 写法保持不变。两种名称也可出现在同一个兼容 iOS 15+ 的应用中；Swift 版不依赖、替换或自动安装 OC 版。

### Swift 基本使用

```swift
import UIKit
import LSTPopViewSwift

@MainActor
func showPopup(in parent: UIView) {
    let content = UILabel(frame: CGRect(x: 0, y: 0, width: 280, height: 160))
    content.text = "Native Swift popup"
    content.textAlignment = .center
    content.backgroundColor = .systemBackground

    guard let popup = LSTPopViewSwift.LSTPopView.initWithCustomView(
        content,
        parentView: parent,
        popStyle: .smoothFromBottom,
        dismissStyle: .smoothToBottom
    ) else { return }

    popup.hemStyle = .bottom
    popup.cornerRadius = 16
    popup.isClickBgDismiss = true
    popup.popViewDidDismissBlock = { print("Native popup removed") }
    popup.pop()
}
```

显式传入 `parentView` 最明确；省略时，工厂只在前台宿主能够唯一确定时推断窗口。需要多个 scene 时分别指定各自父容器。显示和排队期间，内部 Session 持有弹窗；移除后解除持有。内容视图引用弹窗、闭包引用业务控制器时请使用 `weak`，避免引用环。

### 新旧版并存及行为边界

- 两版模块独立，管理队列和清场接口互不影响。Swift 类型通过 `LSTPopViewSwift.LSTPopView` 显式限定；两版同文件出现同名类型时也应使用模块限定或类型别名。
- 原生 Swift 类没有注册为 OC 的全局 `LSTPopView` 类名；不需要也不要添加 `@objc(LSTPopView)`。内部 `UIView.pv_*` 辅助扩展不导出，避免与原 OC 分类产生消费方 API 歧义。
- Swift 公开 API 受 `@MainActor` 隔离；队列使用不可变的每轮 Session、事务和代际校验处理回调重入。Swift 6.2 的隔离析构保证计时器、观察者清理遵守相同隔离；键盘通知先转成 `Sendable` 值快照再交给界面状态机。
- Swift 的 `popViewDidDismissBlock` 在实际移除完成时调用；原 OC 的回调时机继续遵循原实现（包含析构通知语义），不会被新模块改写。不能依赖两版完全相同的内部生命周期。
- Swift 支持原有弹窗样式、位置、手势、分组、优先级、弱多代理、键盘避让和倒计时接口；不包含 OC 的独立 `LSTAlert` 封装，也不提供 Objective-C 到原生 Swift 的自动替换层。
- Swift 的 `removeAllPopView()` 是普通清场，清场结束后可明确重新展示；`invalidateAllScopes()` 用于退出账号或切换根界面前撤销旧上下文；`invalidatePopViews(in: scene)` 用于 scene 断开。Swift 的清场不会关闭原 OC 队列。
- 原生 Swift 使用系统单调时钟，并支持减少动态效果、模态可访问性和关闭后的焦点恢复；这些策略的单元测试采用注入环境，不等同于真实设备 VoiceOver 人工验证。

### 测试与共存示例

面向使用和学习的 [原生 Swift 场景 Demo](Swift/Examples/NativeDemo/README.md) 独立提供 16 个中文场景页，覆盖确认框、分享面板、键盘输入、列表选择、侧边栏、优先级、堆叠、动画、拖拽、倒计时、动态高度和生命周期。直接打开 `Swift/Examples/NativeDemo/NativeSwiftDemo.xcodeproj` 即可通过本地 Swift Package 运行，无需 Pods。原 OC Demo 保留在 `Example/`。

`Swift/Tests/LSTPopViewSwiftTests/` 保存独立库行为测试；`Swift/Tests/PublicAPIConsumer/Consumer.swift` 使用普通 import 检查公开 API。库测试需要已经建立真实 `UIWindowScene` 的 UIKit 宿主，不能把普通 macOS 的 `swift test` 当成 iOS 验证。

可运行的 [新旧版共存示例及验证说明](Swift/Examples/Coexistence/README.md) 使用原 OC podspec 和真实 `LSTTimer`，在同一个 iOS App 中链接原 OC 与原生 Swift，并验证运行时类名、各自展示/关闭及队列隔离。示例和测试宿主要求 iOS 16+，不改变库的 iOS 15 下限。

`./Swift/Scripts/verify-public-api.sh` 会实际编译、链接 Swift 6 严格并发模块，再从模块外检查公开接口。仓库现有两个独立 podspec，校验时请显式选择：`pod lib lint LSTPopView.podspec` 或 `pod lib lint LSTPopViewSwift.podspec`。原 Travis 的 OC 校验也显式指定原 spec，避免自动选择时产生歧义。

## 前言
- 考虑到笔者的精力问题,遇到问题请先查看 API、效仿Demo、阅读README、搜索 Issues。如果是BUG 或 Feature,最好是提Issue
- 联系方式: LoSenTrad@163.com, QQ群:1045568246, 微信:a_LSTKit
- 开发环境: Xcode12.3, iOS13.5, iPhone XS Max~

## 博客地址
- github: [https://github.com/LoSenTrad/LSTPopView](https://github.com/LoSenTrad/LSTPopView)
- CSDN: [https://blog.csdn.net/u012400600/article/details/106279654](https://blog.csdn.net/u012400600/article/details/106279654)
- 简书: [https://www.jianshu.com/p/8023a85dc2a2](https://www.jianshu.com/p/8023a85dc2a2)

## 目录
* [特性](#特性)   
* [版本更新历史](#版本更新历史)  
* [安装](#安装)  
* [基本使用](#基本使用)  
* [使用注意事项](#使用注意事项)  
* [演示效果](#演示效果)  
* [作者](#作者)  
* [版权](#版权)  

## 特性
- 提供丰富的api,高度自定义弹窗,简单入手使用
- 支持弹出动画,消失动画,主动动画等多重动画搭配
- 支持点击,长按,拖拽,横扫手势交互
- 支持多弹窗管理:编队,堆叠,优先级等
- 支持指定弹窗父类,eg: UIWindow,self.view等
- 安全且内存占用小,弹窗内存自动回收
- 提供生命周期api,自定义动画控制
- 自动规避键盘,防止被键盘遮挡
- 支持定时器,多定时器机制
- 支持纯代码/xib页面
- 支持横竖屏切换
- 支持多代理机制
- 支持二次封装,比如组件LSTHUD,LSTAlertView等

## 版本更新历史
- [点我查看](https://github.com/LoSenTrad/LSTPopView/blob/master/UPDATE_HISTORY.md)

## 安装
- OC版本安装 
    - CocoaPods安装: 在podfile文件中添加以下描述,然后 `pod install` 或者 `pod update`

      ```
      pod 'LSTPopView'
      ```  
    - Carthage安装:(暂时未适配)
- Swift版本安装
    - 原生 Swift 模块已在本仓库提供，见上方“原生 Swift 版本（可选）”。

- 手动导入集成
    - 1.拖动LSTPopView文件下5个文件到项目中
    
     ```objective-c
     LSTPopView.h
     LSTPopView.m
     UIView+LSTPV.h
     UIView+LSTPV.m
     LSTPopViewProtocol.h
     ```  
    - 2.在项目中podfile添加依赖库LSTTimer: https://github.com/LoSenTrad/LSTTimer
     ```ruby
     pod 'LSTTimer'
     ```  
      
## 基本使用
- 代码示例

    ```objective-c
    //自定义view
    LSTPopViewTVView *customView = [[LSTPopViewTVView alloc] initWithFrame:CGRectMake(0, 0, 300,400)];
   //创建弹窗PopViiew 指定父容器self.view, 不指定默认是app window
    LSTPopView *popView = [LSTPopView initWithCustomView:customView
                                              parentView:self.view
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
   //弹窗位置: 居中 贴顶 贴左 贴底 贴右 
   popView.hemStyle = LSTHemStyleBottom;
   LSTPopViewWK(popView)
   //点击背景触发
   popView.bgClickBlock = ^{ [wk_popView dismiss]; };
   //弹窗显示
  [popView pop];
  ```
  
- 调试日志 
  ```objective-c
  /** 调试日志类型 */
  typedef NS_ENUM(NSInteger, LSTPopViewLogStyle) {
  LSTPopViewLogStyleNO = 0,          // 关闭调试信息(窗口和控制台日志输出)
  LSTPopViewLogStyleWindow,          // 开启左上角小窗
  LSTPopViewLogStyleConsole,         // 开启控制台日志输出
  LSTPopViewLogStyleALL              // 开启小窗和控制台日志
  };
  ```
    - 调试小窗: S表示当前已经显示的弹窗数, R表示在移除队列的弹窗, S+R是表示当前所有的弹窗数
  
  

  

## 使用注意事项 
#### (一定用weak修饰)
- 解析: LSTPopView对每个弹窗都有自动内存销毁机制, 外部对弹窗的强引用对打破这种自动内存销毁机制, 比如成员变量用strong修饰,否则弹窗不能自动销毁,导致内存回收不了.
- 类成员变量使用规范:

  ```objective-c
  //成员变量用weak修饰, 不可以用strong修饰
  @property (nonatomic,weak) LSTPopView *popView;
  ```
- 成员变量的创建
  ```objective-c
  LSTPopViewTVView *customView = [[LSTPopViewTVView alloc] initWithFrame:CGRectMake(0, 0, 300,400)];
  //弹窗实例创建
  LSTPopView *popView = [LSTPopView initWithCustomView:customView
                                                popStyle:LSTPopStyleSmoothFromBottom
                                            dismissStyle:LSTDismissStyleSmoothToBottom];
  //这里赋值给成员变量self.popView
  self.popView = popView;
  [popView pop];
  ```
  
- 错误使用: 
  ```objective-c
  //直接赋值给成员变量 导致成员变量为空, 请参考以上使用规范
  self.popView = [LSTPopView initWithCustomView:customView
                                         popStyle:LSTPopStyleSmoothFromBottom
                                     dismissStyle:LSTDismissStyleSmoothToBottom];
  ```

    
## 演示效果

- 应用市场常用的示例场景

|QQ,微信,UC,微博,抖音<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/base_demo.gif" width = "200" height = "424" alt="图片名称" align=center />|拖拽移除,横扫移除<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/drag_sweep.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|

- 丰富的出入场动画, 拖拽, 横扫动画

|弹出动画,中间,自上,自左,自下,自左<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/pop.gif" width = "200" height = "424" alt="图片名称" align=center />|移除动画,中间,至上,至左,至下,至左<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/dismiss.gif" width = "200" height = "424" alt="图片名称" align=center /> |拖拽,横扫动画<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/dragSweep.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|---|

- 弹窗位置

|弹窗位置,中间,贴顶,贴左,贴底,贴右<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/hem_Style.gif" width = "200" height = "424" alt="图片名称" align=center />|X轴,Y轴调教,宽度和高度调教<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/x_y_w_h.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|

- 自动规避键盘遮挡,指定容器,定时器

|自动规避键盘遮挡<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/keyboard.gif" width = "200" height = "424" alt="图片名称" align=center />|指定容器弹出<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E6%8C%87%E5%AE%9A%E5%AE%B9%E5%99%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|弹窗计时<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E8%AE%A1%E6%97%B6%E5%99%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|
|---|---|---|
     
- 多弹窗管理(优先级,编队)

|app启动多弹窗优先级显示<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/uPic/launch.gif" width = "200" height = "424" alt="图片名称" align=center />|多窗口编队使用<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E7%AA%97%E5%8F%A3%E7%BC%96%E9%98%9F%E7%9A%84%E4%BD%BF%E7%94%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|
|---|---|
     
 - 支持横竖屏
 
|屏幕旋转<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E5%B1%8F%E5%B9%95%E6%97%8B%E8%BD%AC.gif" width = "500" height = "500" alt="图片名称" align=center />|
|---|

       

## 作者

LoSenTrad@163.com, QQ群:1045568246, 微信:a_LSTKit

## 版权

 尊重劳动成果, 人人有责.
    
