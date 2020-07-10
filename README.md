# LSTPopView 简易的iOS万能弹框

[![Platform](https://img.shields.io/badge/platform-iOS-red.svg)](https://developer.apple.com/iphone/index.action) [![Language](http://img.shields.io/badge/language-OC-yellow.svg?style=flat )](https://en.wikipedia.org/wiki/Objective-C) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://mit-license.org) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/LSTPopView.svg)](https://img.shields.io/cocoapods/v/LSTPopView.svg)

## 如果觉得好用,请给我一个小星星吧!

## 前言
- 在每个项目中,弹框的需求都有,而且各种各样,花里胡哨, 很是烦恼. LSTPopView的出现,可以让我们更专注弹框页面的布局.省心省力! 提高开发效率!
- 欢迎coder们发现问题或者提供更好的idea,一起努力完善

## 博客地址
- github: [https://github.com/LoSenTrad/LSTPopView](https://github.com/LoSenTrad/LSTPopView)
- CSDN: [https://blog.csdn.net/u012400600/article/details/106279654](https://blog.csdn.net/u012400600/article/details/106279654)
- 简书: [https://www.jianshu.com/p/8023a85dc2a2](https://www.jianshu.com/p/8023a85dc2a2)
- LSTPopView 属性接口介绍

## 特性

- 提供丰富的api,高度自定义弹框,简单入手使用
- 支持弹出动画,消失动画,主动动画等多重动画搭配
- 支持多弹框管理:编队,堆叠,优先级等
- 支持指定弹框父类,eg: UIWindow,self.view等
- 安全且内存占用小
- 自动规避键盘,防止被键盘遮挡
- 支持横竖屏切换
- 支持纯代码/xib页面
- 提供生命周期api,自定义动画控制
- 支持定时器,多定时器机制
- 支持多代理机制
- 支持二次封装,比如组件LSTHUD,LSTAlertView等

## 安装

- CocoaPods安装: 在podfile文件中添加以下描述,然后 `pod install` 或者 `pod update`

  ```ruby
  pod 'LSTPopView'
  ```  
- Carthage安装:(暂时未适配)


## 版本更新历史[点我](https://github.com/LoSenTrad/LSTPopView/blob/master/UPDATE_HISTORY.md)


## 效果演示(gif图比较大,请耐心等待~)

- 应用市场常用的示例场景

|QQ,微信,UC,微博<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/QQ_%E5%BE%AE%E4%BF%A1_%E5%BE%AE%E5%8D%9A_UC.gif" width = "200" height = "424" alt="图片名称" align=center />|抖音,百度网盘,侧边栏,加载指示器<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E6%8A%96%E9%9F%B3_%E7%99%BE%E5%BA%A6%E7%BD%91%E7%9B%98_%E4%BE%A7%E8%BE%B9%E6%A0%8F_%E5%8A%A0%E8%BD%BD%E6%8C%87%E7%A4%BA%E5%99%A8.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|

- 丰富的动画选择

|弹出动画,中间,自上,自左,自下,自左<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E5%BC%B9%E5%87%BA%E5%8A%A8%E7%94%BB.gif" width = "200" height = "424" alt="图片名称" align=center />|移除动画,中间,至上,至左,至下,至左<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E7%A7%BB%E9%99%A4%E5%8A%A8%E7%94%BB.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|

- 弹框位置

|弹框位置,中间,贴顶,贴左,贴底,贴右<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E5%BC%B9%E6%A1%86%E4%BD%8D%E7%BD%AE.gif" width = "200" height = "424" alt="图片名称" align=center />|移除X轴Y轴校准<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/X_Y%E6%A0%A1%E5%87%86.gif" width = "200" height = "424" alt="图片名称" align=center /> |
|---|---|

- 自动规避键盘遮挡,指定容器,定时器

|自动规避键盘遮挡<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E8%87%AA%E5%8A%A8%E8%A7%84%E9%81%BF%E9%94%AE%E7%9B%98.gif" width = "200" height = "424" alt="图片名称" align=center />|指定容器弹出<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E6%8C%87%E5%AE%9A%E5%AE%B9%E5%99%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|弹框计时<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E8%AE%A1%E6%97%B6%E5%99%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|
|---|---|---|
     
- 多窗口管理(优先级,编队)

|多窗口优先级<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E7%AA%97%E5%8F%A3%E4%BC%98%E5%85%88%E7%BA%A7.gif" width = "200" height = "424" alt="图片名称" align=center />|多窗口编队使用<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E7%AA%97%E5%8F%A3%E7%BC%96%E9%98%9F%E7%9A%84%E4%BD%BF%E7%94%A8.gif" width = "200" height = "424" alt="图片名称" align=center />|
|---|---|
     
 - 支持横竖屏
 
|屏幕旋转<br><img src="https://raw.githubusercontent.com/5208171/LSTBlog/master/LSTPopView/%E5%B1%8F%E5%B9%95%E6%97%8B%E8%BD%AC.gif" width = "500" height = "500" alt="图片名称" align=center />|
|---|

       

## 作者

490790096@qq.com, LoSenTrad@163.com

## 版权

 尊重劳动成果, 人人有责.
     



        
    
