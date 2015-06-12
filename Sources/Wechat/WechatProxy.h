//
//  WechatProxy.h
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WXApi.h"
#import "Diplomat.h"

extern NSString * __nonnull const kDiplomatTypeWechat;
extern NSString * __nonnull const kWechatSceneTypeKey;

@interface WechatProxy : NSObject <DiplomatProxyProtocol>

@end

@interface DTMediaMessage (Wechat)
/** @brief 生成微信的多媒体分享内容对象 */
- (WXMediaMessage * __nonnull)wechatMessage;
@end

@interface DTImageMessage (Wechat)
@end

@interface DTAudioMessage (Wechat)
@end

@interface DTVideoMessage (Wechat)
@end

@interface DTPageMessage (Wechat)
@end