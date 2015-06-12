//
//  WeiboProxy.h
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WeiboSDK.h"
#import "Diplomat.h"

extern NSString * __nonnull const kDiplomatTypeWeibo;

@interface WeiboProxy : NSObject <DiplomatProxyProtocol>

@end

@interface DTMessage (Weibo)

/** @brief 生成微博对应的分享的内容对象。 */
- (WBMessageObject * __nonnull)weiboMessage;

@end

@interface DTTextMessage (Weibo)
@end

@interface DTMediaMessage (Weibo)
@end

@interface DTImageMessage (Weibo)
@end

@interface DTAudioMessage (Weibo)
@end

@interface DTVideoMessage (Weibo)
@end

@interface DTPageMessage (Weibo)
@end