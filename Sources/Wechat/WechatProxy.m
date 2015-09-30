//
//  WechatProxy.m
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "WechatProxy.h"

#import <UIKit/UIKit.h>
#import "UIImage+DiplomatResize.h"

static NSString * const kWechatErrorDomain = @"wechat_error_domain";
NSString * const kDiplomatTypeWechat = @"diplomat_wechat";
NSString * const kWechatSceneTypeKey = @"wechat_scene_type_key";

@interface WechatProxy () <WXApiDelegate>
@property (copy, nonatomic) NSString *wechatAppId;
@property (copy, nonatomic) NSString *wechatSecret;
@property (copy, nonatomic) DiplomatCompletedBlock block;
@end

@implementation WechatProxy

+ (id<DiplomatProxyProtocol> __nonnull)proxy
{
  return [[WechatProxy alloc] init];
}

+ (void)load
{
  [[Diplomat sharedInstance] registerProxyObject:[[WechatProxy alloc] init] withName:kDiplomatTypeWechat];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration
{
  self.wechatAppId = configuration[kDiplomatAppIdKey];
  self.wechatSecret = configuration[kDiplomatAppSecretKey];
  [WXApi registerApp:self.wechatAppId];
}

- (void)auth:(DiplomatCompletedBlock __nullable)completedBlock
{
  self.block = completedBlock;

  SendAuthReq *request = [[SendAuthReq alloc] init];
  request.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
  request.state = @"wechat_auth_login_liulishuo";

  [WXApi sendReq:request];
}

- (void)share:(DTMessage * __nonnull)message completed:(DiplomatCompletedBlock __nullable)compltetedBlock
{
  self.block = compltetedBlock;
  
  SendMessageToWXReq *wxReq = [[SendMessageToWXReq alloc] init];
  if ([message isKindOfClass:[DTMediaMessage class]])
  {
    wxReq.text = nil;
    wxReq.bText = NO;
    wxReq.message = [(DTMediaMessage *)message wechatMessage];
  }
  else
  {
    wxReq.text = [(DTTextMessage *)message text];
    wxReq.bText = YES;
  }

  // 微信分享场景的选择：朋友圈（WXSceneTimeline）、好友（WXSceneSession）、收藏（WXSceneFavorite）
  wxReq.scene = WXSceneTimeline;
  if (message.userInfo)
  {
    if (message.userInfo[kWechatSceneTypeKey])
    {
      int scence = [message.userInfo[kWechatSceneTypeKey] intValue];
      if (scence >= 0 && scence <= 2)
      {
        wxReq.scene = scence;
      }
    }
  }

  [WXApi sendReq:wxReq];
}

- (void)pay:(id<DTWechatPaymentOrder> __nonnull)order completed:(DiplomatCompletedBlock __nullable)completedBlock
{
  self.block = completedBlock;

  PayReq *payReq = [[PayReq alloc] init];
  payReq.openID = [order openId];
  payReq.partnerId = [order partnerId];
  payReq.prepayId = [order prepayId];
  payReq.nonceStr = [order nonceString];
  payReq.timeStamp = [order timestamp];
  payReq.package = [order package];
  payReq.sign = [order sign];

  [WXApi sendReq:payReq];
}

- (BOOL)isInstalled
{
  return [WXApi isWXAppInstalled];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - Wechat SDK Delegate

- (void)onReq:(BaseReq*)req
{
  // TODO: wechat request
}

- (void)onResp:(BaseResp*)resp
{
  DiplomatCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (resp.errCode != WXSuccess)
  {
    if (doneBlock)
    {
      doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: resp.errStr ?: @"取消"}]);
    }

    return;
  }

  if([resp isKindOfClass:[SendMessageToWXResp class]])
  {
    if (doneBlock)
    {
      doneBlock(nil, nil);
    }
  }
  else if([resp isKindOfClass:[SendAuthResp class]])
  {
    SendAuthResp *temp = (SendAuthResp*)resp;
    if (temp.code)
    {
      [self getWechatUserInfoWithCode:temp.code completed:doneBlock];
    }
    else
    {
      if (doneBlock)
      {
        doneBlock(nil, [NSError errorWithDomain:kWechatErrorDomain
                                           code:temp.errCode
                                       userInfo:@{NSLocalizedDescriptionKey: @"微信授权失败"}]);
      }
    }
  }
  else if ([resp isKindOfClass:[PayResp class]])
  {
    if (doneBlock)
    {
        doneBlock(nil, nil);
    }
  }
}

- (void)getWechatUserInfoWithCode:(NSString *)code completed:(DiplomatCompletedBlock)completedBlock
{
  [self wechatAuthRequestWithPath:@"oauth2/access_token"
                           params:@{@"appid": self.wechatAppId,
                                    @"secret": self.wechatSecret,
                                    @"code": code,
                                    @"grant_type": @"authorization_code"}
                        complated:^(NSDictionary *result, NSError *error) {
                          if (result)
                          {
                            NSString *openId = result[@"openid"];
                            NSString *accessToken = result[@"access_token"];
                            if (openId && accessToken)
                            {
                              [self wechatAuthRequestWithPath:@"userinfo"
                                                       params:@{@"openid": openId,
                                                                @"access_token": accessToken}
                                                    complated:^(NSDictionary *result, NSError *error) {
                                                      DTUser *dtUser = nil;
                                                      if (result[@"unionid"])
                                                      {
                                                        dtUser = [[DTUser alloc] init];
                                                        dtUser.uid = result[@"unionid"];
                                                        dtUser.gender = [result[@"sex"] integerValue] == 1 ? @"male" : @"female";
                                                        dtUser.nick = result[@"nickname"];
                                                        dtUser.avatar = result[@"headimgurl"];
                                                        dtUser.provider = @"wechat";
                                                        dtUser.rawData = result;
                                                      }

                                                      if (completedBlock)
                                                      {
                                                        completedBlock(dtUser, error);
                                                      }
                                                    }];
                              return;
                            }
                          }

                          if (completedBlock)
                          {
                            completedBlock(result, error);
                          }
                        }];
}

#pragma mark - Http Request

- (void)wechatAuthRequestWithPath:(NSString *)path
                           params:(NSDictionary *)params
                        complated:(DiplomatCompletedBlock)completedBlock
{
  NSURL *baseURL = [NSURL URLWithString:@"https://api.weixin.qq.com/sns"];
  [self requestWithUrl:[baseURL URLByAppendingPathComponent:path]
                mehtod:@"GET"
                params:params
             complated:completedBlock];
}

- (NSURLSessionTask *)requestWithUrl:(NSURL *)url
                              mehtod:(NSString *)method
                              params:(NSDictionary *)params
                           complated:(DiplomatCompletedBlock)completedBlock
{
  NSURL *completedURL = url;
  if (params && ![@[@"PUT", @"POST"] containsObject:method])
  {
    completedURL = [self url:url appendWithQueryDictionary:params];
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:completedURL];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"application/json; charset=utf8" forHTTPHeaderField:@"Accept"];
  [request setHTTPMethod:method];
  [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
  if (params && [@[@"PUT", @"POST"] containsObject:method])
  {
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    if (data)
    {
      [request setHTTPBody:data];
    }
  }

  NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                             id result = nil;
                                                             if (data != nil)
                                                             {
                                                               result = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingAllowFragments
                                                                                                           error:&error];
                                                             }

                                                             if (completedBlock)
                                                             {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                 completedBlock(result, error);
                                                               });
                                                             }
                                                           }];

  [task resume];

  return task;
}

static NSString *urlEncode(id object)
{
  return [[NSString stringWithFormat:@"%@", object] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)url:(NSURL *)url appendWithQueryDictionary:(NSDictionary *)params;
{
  if (params.count <= 0)
  {
    return url;
  }

  NSMutableArray *parts = [NSMutableArray array];
  for (id key in params)
  {
    id value = params[key];
    NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
    [parts addObject: part];
  }

  NSString *queryString = [parts componentsJoinedByString: @"&"];
  NSString *sep = @"?";
  if (url.query)
  {
    sep = @"&";
  }

  return [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"%@%@", sep, queryString]];
}

@end


@implementation DTMediaMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [WXMediaMessage message];
  message.title = self.title;
  message.description = self.desc;
  message.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImage:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationMedium], 0.65);

  return message;
}
@end


@implementation DTImageMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];
  message.thumbData = UIImageJPEGRepresentation([self.thumbnailableImage resizedImage:CGSizeMake(240, 240) interpolationQuality:kCGInterpolationMedium], 0.65);
  WXImageObject *imageObect = [WXImageObject object];
  imageObect.imageData = self.imageData;
  imageObect.imageUrl = self.imageUrl;

  message.mediaObject = imageObect;

  return message;
}
@end


@implementation DTAudioMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *mesage = [super wechatMessage];

  WXMusicObject *musicObject = [WXMusicObject object];
  musicObject.musicUrl = self.audioUrl;
  musicObject.musicDataUrl = self.audioDataUrl;

  mesage.mediaObject = musicObject;

  return mesage;
}
@end


@implementation DTVideoMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];

  WXVideoObject *videoObject = [WXVideoObject object];
  videoObject.videoUrl = self.videoUrl;
  videoObject.videoLowBandUrl = self.videoDataUrl;

  message.mediaObject = videoObject;

  return message;
}
@end


@implementation DTPageMessage (Wechat)
- (WXMediaMessage *)wechatMessage
{
  WXMediaMessage *message = [super wechatMessage];

  WXWebpageObject *webPageObject = [WXWebpageObject object];
  webPageObject.webpageUrl = self.webPageUrl;

  message.mediaObject = webPageObject;
  
  return message;
}

@end
