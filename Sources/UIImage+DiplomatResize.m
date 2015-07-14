//
//  UIImage+DiplomatResize.m
//  Diplomat
//
//  Created by Cloud Dai on 14/7/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "UIImage+DiplomatResize.h"

@implementation UIImage (DiplomatResize)

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality
{
  BOOL drawTransposed;
  switch ( self.imageOrientation )
  {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
    {
      drawTransposed = YES;
      break;
    }

    default:
    {
      drawTransposed = NO;
    }
  }

  CGAffineTransform transform = [self transformForOrientation:newSize];

  return [self resizedImage:newSize transform:transform drawTransposed:drawTransposed interpolationQuality:quality];
}

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality
{
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio;

  switch (contentMode)
  {
    case UIViewContentModeScaleAspectFill:
    {
      ratio = MAX(horizontalRatio, verticalRatio);
      break;
    }

    case UIViewContentModeScaleAspectFit:
    {
      ratio = MIN(horizontalRatio, verticalRatio);
      break;
    }

    default:
    {
      [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", (long)contentMode];
    }
  }

  CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);

  return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark -
#pragma mark Private helper methods

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
  CGFloat scale = MAX(1.0f, self.scale);
  CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width*scale, newSize.height*scale));
  CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
  CGImageRef imageRef = self.CGImage;

  // Fix for a colorspace / transparency issue that affects some types of
  // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef bitmap = CGBitmapContextCreate(
                                              NULL,
                                              newRect.size.width,
                                              newRect.size.height,
                                              8, /* bits per channel */
                                              (newRect.size.width * 4), /* 4 channels per pixel * numPixels/row */
                                              colorSpace,
                                              (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                              );
  CGColorSpaceRelease(colorSpace);

  // Rotate and/or flip the image if required by its orientation
  CGContextConcatCTM(bitmap, transform);

  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(bitmap, quality);

  // Draw into the context; this scales the image
  CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);

  // Get the resized image from the context and a UIImage
  CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
  UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];

  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(newImageRef);

  return newImage;
}


- (CGAffineTransform)transformForOrientation:(CGSize)newSize
{
  CGAffineTransform transform = CGAffineTransformIdentity;

  switch (self.imageOrientation)
  {
    case UIImageOrientationDown:           // EXIF = 3
    case UIImageOrientationDownMirrored:   // EXIF = 4
    {
      transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
    }

    case UIImageOrientationLeft:           // EXIF = 6
    case UIImageOrientationLeftMirrored:   // EXIF = 5
    {
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
    }

    case UIImageOrientationRight:          // EXIF = 8
    case UIImageOrientationRightMirrored:  // EXIF = 7
    {
      transform = CGAffineTransformTranslate(transform, 0, newSize.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    }

    default:
    {
      break;
    }
  }

  switch (self.imageOrientation)
  {
    case UIImageOrientationUpMirrored:     // EXIF = 2
    case UIImageOrientationDownMirrored:   // EXIF = 4
    {
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    }

    case UIImageOrientationLeftMirrored:   // EXIF = 5
    case UIImageOrientationRightMirrored:  // EXIF = 7
    {
      transform = CGAffineTransformTranslate(transform, newSize.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    }

    default:
    {
      break;
    }
  }

  return transform;
}

@end
