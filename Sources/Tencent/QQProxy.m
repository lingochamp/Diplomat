//
//  QQProxy.m
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "QQProxy.h"

#import "UIImage+DiplomatResize.h"

static NSString * const kQQErrorDomain = @"qq_error_domain";
NSString * const kDiplomatTypeQQ = @"diplomat_qq";
NSString * const kTencentQQSceneTypeKey = @"tencent_qq_scene_type_key";

@interface QQProxy () <QQApiInterfaceDelegate, TencentSessionDelegate>
@property (copy, nonatomic) DiplomatCompletedBlock block;
@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@end

@implementation QQProxy

+ (id<DiplomatProxyProtocol> __nonnull)proxy
{
  return [[QQProxy alloc] init];
}

+ (void)load
{
  [[Diplomat sharedInstance] registerProxyObject:[[QQProxy alloc] init] withName:kDiplomatTypeQQ];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration
{
  self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:configuration[kDiplomatAppIdKey] andDelegate:self];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  BOOL qq = [QQApiInterface handleOpenURL:url delegate:self];
  BOOL tencent = [TencentOAuth HandleOpenURL:url];

  return qq || tencent;
}

- (void)auth:(DiplomatCompletedBlock __nullable)completedBlock
{
  self.block = completedBlock;

  [self.tencentOAuth authorize:@[kOPEN_PERMISSION_GET_USER_INFO,
                                 kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                 kOPEN_PERMISSION_ADD_ALBUM,
                                 kOPEN_PERMISSION_ADD_IDOL,
                                 kOPEN_PERMISSION_ADD_ONE_BLOG,
                                 kOPEN_PERMISSION_ADD_PIC_T,
                                 kOPEN_PERMISSION_ADD_SHARE,
                                 kOPEN_PERMISSION_ADD_TOPIC,
                                 kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                 kOPEN_PERMISSION_DEL_IDOL,
                                 kOPEN_PERMISSION_DEL_T,
                                 kOPEN_PERMISSION_GET_FANSLIST,
                                 kOPEN_PERMISSION_GET_IDOLLIST,
                                 kOPEN_PERMISSION_GET_INFO,
                                 kOPEN_PERMISSION_GET_OTHER_INFO,
                                 kOPEN_PERMISSION_GET_REPOST_LIST,
                                 kOPEN_PERMISSION_LIST_ALBUM,
                                 kOPEN_PERMISSION_UPLOAD_PIC,
                                 kOPEN_PERMISSION_GET_VIP_INFO,
                                 kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                                 kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                                 kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO]
                      inSafari:YES];
}

- (void)share:(DTMessage * __nonnull)message completed:(DiplomatCompletedBlock __nullable)compltetedBlock
{
    self.block = compltetedBlock;
    
    QQApiObject *apiObject = [message qqMessage];
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:apiObject];
    
    //区别手机QQ和QZone请求
    QQApiSendResultCode status;
    if (message.userInfo &&
        message.userInfo[kTencentQQSceneTypeKey] &&
        [message.userInfo[kTencentQQSceneTypeKey] intValue] == TencentSceneZone
        )
    {
        if ([message isMemberOfClass:[DTTextMessage class]] || [message isMemberOfClass:[DTImageMessage class]])
        {
            apiObject.cflag = kQQAPICtrlFlagQZoneShareOnStart;
            status = [QQApiInterface sendReq:request];
        }
        else
        {
            status = [QQApiInterface SendReqToQZone:request];
        }
    }
    else
    {
        apiObject.cflag = kQQAPICtrlFlagQQShare;
        status = [QQApiInterface sendReq:request];
    }
    
    NSString *errorMessage = [self handleQQSendResult:status];
    
    if (errorMessage)
    {
        self.block = nil;
        compltetedBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: errorMessage}]);
    }
}


- (BOOL)isInstalled
{
  return [TencentOAuth iphoneQQInstalled]; // 只判断 QQ 没有安装，不判断 QQZone 因为 QQZone 没有支持 SSO 。
}

#pragma mark - QQ SDK Delegate

- (NSString *)handleQQSendResult:(QQApiSendResultCode)sendResult
{
  NSString *errorMessage = nil;
  switch (sendResult)
  {
    case EQQAPIAPPNOTREGISTED:
    {
      errorMessage = @"App 未注册";

      break;
    }

    case EQQAPIMESSAGECONTENTINVALID:
    case EQQAPIMESSAGECONTENTNULL:
    case EQQAPIMESSAGETYPEINVALID:
    {
      errorMessage = @"发送参数错误";

      break;
    }

    case EQQAPIQQNOTINSTALLED:
    {
      errorMessage = @"未安装手机 QQ";

      break;
    }

    case EQQAPIQQNOTSUPPORTAPI:
    {
      errorMessage = @"API 接口不支持";

      break;
    }

    case EQQAPISENDFAILD:
    {
      errorMessage = @"发送失败";

      break;
    }

    default:
    {
      break;
    }
  }

  return errorMessage;
}


- (void)tencentDidLogin
{
  [self.tencentOAuth getUserInfo];
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
  DiplomatCompletedBlock doneBlock = self.block;
  self.block = nil;
  if (doneBlock)
  {
    doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"QQ 登录被取消"}]);
  }
}

- (void)tencentDidNotNetWork
{
  DiplomatCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (doneBlock)
  {
    doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"网络链接错误"}]);
  }
}

- (void)getUserInfoResponse:(APIResponse *)response
{
  DiplomatCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (doneBlock)
  {
    if (response.retCode == URLREQUEST_SUCCEED)
    {
      NSDictionary *userInfo = response.jsonResponse;
      DTUser *dtUser = nil;
      if (self.tencentOAuth.openId && userInfo[@"nickname"])
      {
        dtUser = [[DTUser alloc] init];
        dtUser.uid = self.tencentOAuth.openId;
        dtUser.nick = userInfo[@"nickname"];
        dtUser.gender = [userInfo[@"gender"] isEqualToString:@"男"] ? @"male" : @"female";
        dtUser.avatar = userInfo[@"figureurl_qq_2"];
        dtUser.provider = @"qqspace";
        dtUser.rawData = userInfo;

        doneBlock(dtUser, nil);
      }
      else
      {
        doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"获取的授权数据错误"}]);
      }
    }
    else
    {
      doneBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: response.errorMsg}]);
    }
  }
}

- (void)onReq:(QQBaseReq *)req
{
  // ...
}

- (void)onResp:(QQBaseResp *)resp
{
  DiplomatCompletedBlock completedBlock = self.block;
  self.block = nil;

  if (completedBlock)
  {
    if (resp.errorDescription)
    {
      completedBlock(nil, [NSError errorWithDomain:kQQErrorDomain code:-1024 userInfo:@{NSLocalizedDescriptionKey: resp.errorDescription}]);
    }
    else
    {
      completedBlock(resp.result, nil);
    }
  }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
  
}

@end

@implementation DTTextMessage (QQ)
- (QQApiObject *)qqMessage
{
  QQApiTextObject *textObject = [QQApiTextObject objectWithText:self.text];

  return textObject;
}
@end


@implementation DTMediaMessage (QQ)
- (NSData *)thumbnailImageData
{
  NSData *imageData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImage:CGSizeMake(120, 120)
                                                                 interpolationQuality:kCGInterpolationMedium], 0.65);

  return imageData;
}

- (QQApiObject *)qqMessage
{
  NSAssert(false, @"Should implement this method.");

  return nil;
}
@end


@implementation DTImageMessage (QQ)
- (QQApiObject *)qqMessage
{
  return [QQApiImageObject objectWithData:self.imageData
                         previewImageData:[self thumbnailImageData]
                                    title:self.title
                              description:self.desc];
}
@end


@implementation DTAudioMessage (QQ)
- (QQApiObject *)qqMessage
{
  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.audioUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:[self thumbnailImageData]];

  return newsObject;
}
@end


@implementation DTVideoMessage (QQ)
- (QQApiObject *)qqMessage
{
  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.videoUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:[self thumbnailImageData]];

  return newsObject;
}
@end


@implementation DTPageMessage (QQ)
- (QQApiObject *)qqMessage
{

  QQApiNewsObject *newsObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.webPageUrl]
                                                         title:self.title
                                                   description:self.desc
                                              previewImageData:[self thumbnailImageData]];
  return newsObject;
}

@end
