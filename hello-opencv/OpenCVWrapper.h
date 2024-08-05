//
//  OpenCVWrapper.h
//  hello-opencv
//
//  Created by hyonsoo han on 8/3/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)getOpenCVVersion;
+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height;
+ (UIImage *)bilateralBlur:(UIImage *)image :(double)sigmaColor :(double)sigmaSpace;

@end

NS_ASSUME_NONNULL_END
