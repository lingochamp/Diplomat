//
//  QQProxy.h
//  Diplomat
//
//  Created by Cloud Dai on 10/6/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Diplomat.h"

#import "TencentOAuth.h"
#import "QQApiInterface.h"

extern NSString * __nonnull const kDiplomatTypeQQ;
extern NSString * __nonnull const kDiplomatTencentQQShareType;

/**
 *   分享请求发送场景
 */
typedef NS_ENUM(NSUInteger, TencentShareScene){
    /**
     *  QQ分享类型
     */
    TencentSceneQQ,
    /**
     *  QZone分享类型
     */
    TencentSceneZone
};

@interface QQProxy : NSObject <DiplomatProxyProtocol>
@end

@interface DTMessage (QQ)
/** @brief 生成 QQ 或 QZone 对应的分享对象。  */
- (QQApiObject * __nonnull)qqMessage;
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
