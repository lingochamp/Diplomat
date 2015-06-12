## Diplomat

统一第三方 SDKs 的登录和分享接口。目前支持**微信**、 **QQ** 、**微博**。  
P.S: 其中除支持 OAuth ，其它只支持 SSO ，只能安装相应的客户端才能使用。


### 使用

1. 通过 CocoaPods 安装。  
``` pod 'Diplomat' ```  
	选择性安装  
``` pod 'Diplomat/Wechat' ```  
```	pod 'Diplomat/QQ' ```  

2. 导入需要使用的第三方 SDK。  
``` #import <Diplomat/WechatProxy.h> ```  
``` #import <Diplomat/QQProxy.h> ```  

3. 在 ```application:didFinishLaunchingWithOptions:``` 添加  

```
[[Diplomat sharedInstance] registerWithConfigurations:@{kDiplomatTypeWechat: @{kDiplomatAppIdKey: @"wxd930ea5d5a258f4f",
                                                                                                                                                              kDiplomatAppSecretKey: @"db426a9829e4b49a0dcac7b4162da6b6"},
                                                         kDiplomatTypeQQ: @{kDiplomatAppIdKey: @"222222"}}];
```  

4. 授权登录。

```
[[Diplomat sharedInstance] authWithName:thirdPartyName
                              completed:^(id result, NSError *error) {
                                 // ...
                            }];
```  

5. 分享。

```
 // Create
 [[Diplomat sharedInstance] share:message
                             name:name
                        completed:^(id result, NSError *error) {
                          [self showText:result];
                        }];
```


### 扩展  
...