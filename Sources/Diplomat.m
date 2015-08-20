//
//  Diplomat.m
//  Diplomat
//
//  Created by Cloud Dai on 11/5/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "Diplomat.h"

NSString * __nonnull const kDiplomatAppIdKey = @"diplomat_app_id";
NSString * __nonnull const kDiplomatAppSecretKey = @"diplomat_app_secret";
NSString * __nonnull const kDiplomatAppRedirectUrlKey = @"diplomat_app_redirect_url";
NSString * __nonnull const kDiplomatAppDebugModeKey = @"diplomat_app_debug_mode";

@interface Diplomat ()

@property (strong, nonatomic) NSMutableDictionary *proxyObjects;

@end

@implementation Diplomat

+ (instancetype)sharedInstance
{
  static Diplomat * _diplomat = nil;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _diplomat = [[Diplomat alloc] init];
  });

  return _diplomat;
}

- (instancetype)init
{
  self = [super init];

  if (self)
  {
    self.proxyObjects = [NSMutableDictionary dictionary];
  }

  return self;
}

- (void)registerProxyObject:(id<DiplomatProxyProtocol> __nonnull)object withName:(NSString * __nonnull)name
{
  self.proxyObjects[name] = object;
}

-(id __nullable)proxyForName:(NSString * __nonnull)name
{
  return self.proxyObjects[name];
}

- (void)registerWithConfigurations:(NSDictionary * __nonnull)configurations
{
  [configurations enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSDictionary *configuration, BOOL *stop) {
    id<DiplomatProxyProtocol> proxy = [self proxyForName:name];
    [proxy registerWithConfiguration:configuration];
  }];
}

- (BOOL)isInstalled:(NSString * __nonnull)name
{
  id<DiplomatProxyProtocol> proxy = [self proxyForName:name];

  return [proxy isInstalled];
}

- (BOOL)handleOpenURL:(NSURL * __nullable)url
{
  BOOL success = NO;
  for (id<DiplomatProxyProtocol> proxy in self.proxyObjects.allValues)
  {
    success = success || [proxy handleOpenURL:url];
  }

  return success;
}

- (void)authWithName:(NSString * __nonnull)name completed:(DiplomatCompletedBlock __nullable)completedBlock
{
  id<DiplomatProxyProtocol> proxy = [self proxyForName:name];
  if (proxy)
  {
    [proxy auth:completedBlock];
  }
  else
  {
    if (completedBlock)
    {
      completedBlock(nil, [NSError errorWithDomain:@"com.liulishuo.diplomat.error" code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"未知应用"}]);
    }
  }
}

- (void)share:(DTMessage * __nonnull)message name:(NSString * __nonnull)name completed:(DiplomatCompletedBlock __nullable)completedBlock
{
  id<DiplomatProxyProtocol> proxy = [self proxyForName:name];
  if (proxy)
  {
    [proxy share:message completed:completedBlock];
  }
  else
  {
    if (completedBlock)
    {
      completedBlock(nil, [NSError errorWithDomain:@"com.liulishuo.diplomat.error" code:-1024 userInfo:@{NSLocalizedDescriptionKey: @"未知应用"}]);
    }
  }
}

@end


@implementation DTUser
- (NSString *)description
{
  return [NSString stringWithFormat:@"uid: %@ \n nick: %@ \n avatar: %@ \n gender: %@ \n provider: %@", self.uid, self.nick, self.avatar, self.gender, self.provider];
}

@end

#pragma mark - Message

@implementation DTMessage
- (NSString *)description
{
  return @"No custom property.";
}
@end


@implementation DTTextMessage
- (NSString *)description
{
  return [NSString stringWithFormat:@"text: %@ \n", self.text];
}
@end


@implementation DTMediaMessage
- (NSString *)description
{
  return [NSString stringWithFormat:@"message Id: %@ \n title: %@ \n desc: %@ \n thumb data: %@ \n", self.messageId, self.title, self.desc, self.thumbnailableImage];
}
@end

@implementation DTImageMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"image url: %@ \n image data: %@ \n", self.imageUrl, self.imageData];
}
@end


@implementation DTAudioMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"audio url: %@ \n audio data url: %@ \n", self.audioUrl, self.audioDataUrl];
}
@end


@implementation DTVideoMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"video url: %@ \n video data url: %@ \n", self.videoUrl, self.videoDataUrl];
}
@end


@implementation DTPageMessage
- (NSString *)description
{
  return [[super description] stringByAppendingFormat:@"web page url: %@", self.webPageUrl];
}

@end
