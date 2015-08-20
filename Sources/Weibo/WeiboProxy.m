//
//  WeiboProxy.m
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "WeiboProxy.h"
#import "WeiboUser.h"

static NSString * const kWeiboTokenKey = @"weibo_token";
static NSString * const kWeiboUserIdKey = @"weibo_user_id";
static NSString * const kWeiboErrorDomain = @"weibo_error_domain";

NSString * const kDiplomatTypeWeibo = @"diplomat_weibo";

@interface WeiboProxy () <WeiboSDKDelegate>

@property (copy, nonatomic) DiplomatCompletedBlock block;
@property (copy, nonatomic) NSString * redirectUrl;

@end

@implementation WeiboProxy

+ (void)load
{
  [[Diplomat sharedInstance] registerProxyObject:[[WeiboProxy alloc] init] withName:kDiplomatTypeWeibo];
}

+ (id<DiplomatProxyProtocol> __nonnull)proxy
{
  return [[WeiboProxy alloc] init];
}

- (void)registerWithConfiguration:(NSDictionary * __nonnull)configuration
{
  [WeiboSDK registerApp:configuration[kDiplomatAppIdKey]];
  [WeiboSDK enableDebugMode:[configuration[kDiplomatAppDebugModeKey] boolValue]];
  self.redirectUrl = configuration[kDiplomatAppRedirectUrlKey];
}

- (void)auth:(DiplomatCompletedBlock)completedBlock
{
  self.block = completedBlock;
  
  WBAuthorizeRequest *request = [WBAuthorizeRequest request];
  request.redirectURI = self.redirectUrl;
  request.scope = @"all";
  request.userInfo = @{@"request_from": @"auth"};
  request.shouldShowWebViewForAuthIfCannotSSO = YES;

  [WeiboSDK sendRequest:request];
}

- (BOOL)isInstalled
{
  return [WeiboSDK isWeiboAppInstalled];
}

- (void)share:(DTMessage *)message completed:(DiplomatCompletedBlock)compltetedBlock
{
  self.block = compltetedBlock;

  WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
  authRequest.redirectURI = self.redirectUrl;
  authRequest.scope = @"all";
  authRequest.userInfo = @{@"request_from": @"share_auth"};
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kWeiboTokenKey];

  WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[message weiboMessage]
                                                                                authInfo:authRequest
                                                                            access_token:accessToken];
  request.userInfo = @{@"request_from": @"share"};
  [WeiboSDK sendRequest:request];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
  return [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark - Weibo SDK Delegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
  // TODO: weibo reqeust
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
  DiplomatCompletedBlock doneBlock = self.block;
  self.block = nil;

  if (response.statusCode != WeiboSDKResponseStatusCodeSuccess)
  {
    if (doneBlock)
    {
      doneBlock(nil, [NSError errorWithDomain:kWeiboErrorDomain
                                         code:response.statusCode
                                     userInfo:@{NSLocalizedDescriptionKey: @"微博请求失败"}]);
    }

    return;
  }

  if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]])
  {
    WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
    NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
    NSString* userID = [sendMessageToWeiboResponse.authResponse userID];

    if (accessToken && userID)
    {
      [self updateWeiboToken:accessToken userId:userID];
    }

    if (doneBlock)
    {
      doneBlock(sendMessageToWeiboResponse.requestUserInfo, nil);
    }
  }
  else if ([response isKindOfClass:[WBAuthorizeResponse class]])
  {
    NSString *token = [(WBAuthorizeResponse *)response accessToken];
    NSString *userID = [(WBAuthorizeResponse *)response userID];
    [self updateWeiboToken:token userId:userID];
    [self getWeiboUserInfoWithUserId:userID accessToken:token completed:doneBlock];
  }
}

- (void)updateWeiboToken:(NSString *)token userId:(NSString *)userId
{
  [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kWeiboUserIdKey];
  [[NSUserDefaults standardUserDefaults] setObject:token forKey:kWeiboTokenKey];
}

- (void)getWeiboUserInfoWithUserId:(NSString *)userId
                       accessToken:(NSString *)token
                         completed:(DiplomatCompletedBlock)completedBlock
{
  [WBHttpRequest requestForUserProfile:userId
                       withAccessToken:token
                    andOtherProperties:nil
                                 queue:nil
                 withCompletionHandler:^(WBHttpRequest *httpRequest,  WeiboUser *user, NSError *error) {
                   DTUser *dtUser = nil;
                   if (user.userID)
                   {
                     dtUser = [[DTUser alloc] init];
                     dtUser.uid = user.userID;
                     dtUser.nick = user.screenName;
                     dtUser.avatar = user.avatarHDUrl;
                     dtUser.gender = [user.gender isEqualToString:@"m"] ?  @"male" : @"female";
                     dtUser.provider = @"weibo";
                     dtUser.rawData = user.originParaDict;
                   }

                   if (completedBlock)
                   {
                     completedBlock(dtUser, error);
                   }
                 }];
}

@end


@implementation DTTextMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
  WBMessageObject *weiboMessage = [WBMessageObject message];
  weiboMessage.text = self.text;

  return weiboMessage;
}
@end


@implementation DTMediaMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage;
{
  WBMessageObject *weiboMessage = [WBMessageObject message];
  weiboMessage.text = self.desc;
  if (self.thumbnailableImage)
  {
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = UIImageJPEGRepresentation(self.thumbnailableImage, 0.75);
    weiboMessage.imageObject = imageObject;
  }

  return weiboMessage;
}
@end


@implementation DTImageMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
  WBMessageObject *weiboMessage = [WBMessageObject message];
  weiboMessage.text = self.desc;
  if (self.imageData)
  {
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.imageData = self.imageData;
    weiboMessage.imageObject = imageObject;
  }

  return weiboMessage;
}
@end


@implementation DTAudioMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
  WBMessageObject *weiboMessage = [super weiboMessage];
  weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.audioUrl];

  return weiboMessage;
}
@end


@implementation DTVideoMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
  WBMessageObject *weiboMessage = [super weiboMessage];
  weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.videoUrl];

  return weiboMessage;
}
@end


@implementation DTPageMessage (Weibo)
- (WBMessageObject * __nonnull)weiboMessage
{
  WBMessageObject *weiboMessage = [super weiboMessage];
  weiboMessage.text = [NSString stringWithFormat:@"%@ %@", weiboMessage.text, self.webPageUrl];

  return weiboMessage;
}
@end
