//
//  OpenCVWrapper.m
//  hello-opencv
//
//  Created by hyonsoo han on 8/3/24.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/gapi.hpp>
#import <opencv2/photo.hpp>
#import "OpenCVWrapper.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}

@end

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    if (mat.channels() == 4) {
        [image convertToMat: &mat :true];
    }
    
    NSLog(@"resizeImg source shape = (%d, %d)", mat.cols, mat.rows);
    
    cv::Mat resized;
    
    //    cv::INTER_NEAREST = 0,
    //    cv::INTER_LINEAR = 1,
    //    cv::INTER_CUBIC = 2,
    //    cv::INTER_AREA = 3,
    //    cv::INTER_LANCZOS4 = 4,
    //    cv::INTER_LINEAR_EXACT = 5,
    //    cv::INTER_NEAREST_EXACT = 6,
    //    cv::INTER_MAX = 7,
    //    cv::WARP_FILL_OUTLIERS = 8,
    //    cv::WARP_INVERSE_MAP = 16
    
    cv::Size size = {width, height};
    
    cv::resize(mat, resized, size, 0, 0, cv::INTER_LINEAR);
    
    NSLog(@"resizeImg dst shape = (%d, %d)", resized.cols, resized.rows);
    
    UIImage *resizedImg = MatToUIImage(resized);
    
    return resizedImg;
    
}

+ (UIImage *)bilateralBlur:(UIImage *)image :(double)sigmaColor :(double)sigmaSpace {
    cv::Mat mat;
    [image convertToMat:&mat :false];
    
    cv::cvtColor(mat, mat, cv::COLOR_BGRA2BGR);
//
//    if (mat.channels() == 4) {
//        [image convertToMat:&mat :true];
//    }
    NSLog(@"bilateralBlur source shape = (%d, %d)", mat.cols, mat.rows);
    cv::Mat blurred;
    mat.copyTo(blurred);
    // d: 필터링에 사용될 이웃 픽셀의 거리(지름), 음수이면 sigmaSpace 값에 의헤 자동 설정
    // sigmaColor: 색공간에서 필터의 표준 편차
    // sigmaSpace: 좌표 공간에서 필터의 표준 편차
    //cv::bilateralFilter(InputArray src, OutputArray dst, int d, double sigmaColor, double sigmaSpace)
    cv::bilateralFilter(mat, blurred, -1, sigmaColor, sigmaSpace);
    
    UIImage *img = MatToUIImage(blurred);
    return img;
}

@end
