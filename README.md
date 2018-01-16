# raml-iOS
Raml parse and render SDK


打包用的指令

```
#pod package ./RAMLSDK.podspec --force --no-mangle --verbose

使用Carthage的方式 - 在RamlSDK2目录下执行。会生成所有对应的framework Universal framework文件
carthage build --no-skip-current --platform iOS

```

调用示例

```
    let setting = RAMLRenderSetting() // 样式配置
    setting.fontColor = .black
    setting.fontSize = 16
    let view = RamlRenderView(frame: CGRect(x:0,y:64,width:self.view.bounds.size.width,height:self.view.bounds.size.height-64-49),
                                          contentHtml: contentHtml, 
                                          setting:setting)
    view.delegate = self // 回调
    view.viewController = self // 用于弹出视频
    self.view.insertSubview(view, at: 0)
```

RAMLRenderSetting 设置

```
public class RAMLRenderSetting: NSObject {
    public var fontSize:CGFloat = 16 // 正文字体大小
    public var fontColor:UIColor = UIColor.black // 正文字体颜色
    
    public var textLeftPadding:CGFloat = 10 // 左边距
    public var textRightPadding:CGFloat = 10 // 右边距
    
    public var backgroundColor:UIColor = UIColor.white // 背景色
}
```

RamlRenderViewDelegate回调方法

```
@objc public protocol RamlRenderViewDelegate : NSObjectProtocol {
    @objc optional func updateImageSize(_ view: UIView!) -> Void // 图片宽高变更
    @objc optional func updatePage(_ index: Int, count: Int) -> Void // 分页状态变更(分页模式下才有)
    @objc optional func willLoadContent(_ view: UIView!) -> Void // 加载内容之前
    @objc optional func didLoadContent(_ view: UIView!) -> Void // 加载内容之后
    @objc optional func tapPic(_ imageURL: String?) -> Void // 点击图片
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView) -> Void // 滑动
}
```