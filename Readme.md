## Diplomat

统一第三方 SDKs 的登录和分享接口。目前支持**微信**、 **QQ** 、**微博**。  
P.S: 其中除微博支持 OAuth ，其它第三方只支持 SSO ，需安装相应的客户端才能使用。


### 使用

1. 通过 CocoaPods 安装。  
``` pod 'Diplomat' ```  
	选择性安装  
``` pod 'Diplomat/Wechat' ```  
```	pod 'Diplomat/QQ' ```  

2. 导入需要使用的第三方 SDK。  
``` #import <Diplomat/WechatProxy.h> ```  
``` #import <Diplomat/QQProxy.h> ```  

3. 使用

```objc

// 在 application:didFinishLaunchingWithOptions: 添加  
[[Diplomat sharedInstance] registerWithConfigurations:@{kDiplomatTypeWechat: @{kDiplomatAppIdKey: @"wxd930ea5d5a258f4f",
                                                                               kDiplomatAppSecretKey: @"db426a9829e4b49a0dcac7b4162da6b6"},
                                                        kDiplomatTypeQQ: @{kDiplomatAppIdKey: @"222222"}}];

// 授权登录。
[[Diplomat sharedInstance] authWithName:thirdPartyName
                              completed:^(id result, NSError *error) {
                                 // ...
                            }];
  
// 分享。
 // Create DTMessage message ...
[[Diplomat sharedInstance] share:message
                            name:thirdPartyName
                       completed:^(id result, NSError *error) {
                        // ...
                       }];
```

### DTMessage 中 userInfo 的使用。  
userInfo 是用来携带额外的信息。  
微信分享场景的选择： 
```objc
DTMessage *message = DTMessage()
// ...
message.userInfo = @{kWechatSceneTypeKey: @(WXSceneTimeline)}
// WXSceneTimeline: 朋友圈（默认）、WXSceneSession: 好友、WXSceneFavorite: 收藏。
```

通过 Safari 分享到 QZone （感谢 [@hi-guy](https://github.com/hi-guy) 贡献）:  
```objc
DTMessage *message = DTMessage()
// ...
message.userInfo = @{kTencentQQSceneTypeKey: @(TencentSceneZone)}
// TencentSceneQQ: 通过 QQ 客户端分享（默认，包含了分享到 QZone 选项）, 
// TencentSceneZone: 通过 Safari 只分享到 QZone （有 QQ 客户端时不推荐使用）。
```


### 扩展第三方 SDK （详见实现逻辑）  
1. 实现协议 *DiplomatProxyProtocol* 。
2. 添加将 *DTMessage* 转换到第三方 SDK 的方法。
3. 将实现的自定义扩展注册到 *Diplomat* 中。
