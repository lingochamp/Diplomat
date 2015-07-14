//
//  UIImage+DiplomatResize.h
//  Diplomat
//
//  Created by Cloud Dai on 14/7/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (DiplomatResize)
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
@end
