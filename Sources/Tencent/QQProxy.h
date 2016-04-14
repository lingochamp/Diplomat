//
//  QQProxy.h
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Diplomat.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * const kDiplomatTypeQQ;
extern NSString * const kTencentQQSceneTypeKey;

/**
 *   分享请求发送场景
 */
typedef NS_ENUM(NSUInteger, TencentShareScene)
{
    /**
     *  QQ 分享类型（默认）。
     */
    TencentSceneQQ = 1,
    /**
     *  QZone 分享类型。
     */
    TencentSceneZone
};

@interface QQProxy : NSObject <DiplomatProxyProtocol>
@end

@interface DTMessage (QQ)

/** @brief 生成 QQ 或 QZone 对应的分享对象。  */
- (QQApiObject *)qqMessage;

@end

@interface DTTextMessage (QQ)
@end

@interface DTMediaMessage (QQ)
@end

@interface DTImageMessage (QQ)
@end

@interface DTAudioMessage (QQ)
@end

@interface DTVideoMessage (QQ)
@end

@interface DTPageMessage (QQ)
@end
NS_ASSUME_NONNULL_END