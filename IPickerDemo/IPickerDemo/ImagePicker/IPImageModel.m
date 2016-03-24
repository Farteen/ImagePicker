//
//  IPImageModel.m
//  IPickerDemo
//
//  Created by Wangjianlong on 16/2/27.
//  Copyright © 2016年 JL. All rights reserved.
//

#import "IPImageModel.h"
#import "IPImageReaderViewController.h"
#import "IPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
/**弹出样式*/
typedef NS_ENUM(NSUInteger,  LoadImage) {
    /**由上到下*/
    LoadImageThumibal,
    /**由左到右*/
    LoadImageFullScreen
};

@interface IPImageModel ()

@end

@implementation IPImageModel
- (void)asynLoadThumibImage{
    if (self.thumbnail) {
        return;
    }
    if (iOS8Later) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        PHAsset *phAsset = self.imageAsset;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = self.imageSize.width * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        [[PHImageManager defaultManager] requestImageForAsset:self.imageAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined) {
                self.thumbnail = result;
                [self postCompleteNotification:LoadImageThumibal];
            }
        }];
    }else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                    [assetslibrary assetForURL:self.assetUrl
                                   resultBlock:^(ALAsset *asset){
                                       
                                       self.thumbnail = [UIImage imageWithCGImage:asset.thumbnail];
                                       [self postCompleteNotification:LoadImageThumibal];
                                   }
                                  failureBlock:^(NSError *error) {
                                      [self postCompleteNotification:LoadImageThumibal];
                                      
                                  }];
                } @catch (NSException *e) {
                }
            }
        });
    }
}
- (void)asynLoadFullScreenImage{
    if (self.fullRorationImage) {
        return;
    }
    if (iOS8Later) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        PHAsset *phAsset = self.imageAsset;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        [[PHImageManager defaultManager] requestImageForAsset:self.imageAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined) {
                self.fullRorationImage = result;
                [self postCompleteNotification:LoadImageFullScreen];
            }
        }];
    }else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                @try {
                    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                    [assetslibrary assetForURL:self.assetUrl
                                   resultBlock:^(ALAsset *asset){
                                       
                                       ALAssetRepresentation *rep = [asset defaultRepresentation];
                                       CGImageRef iref = [rep fullScreenImage];
                                       if (iref) {
                                           self.fullRorationImage = [UIImage imageWithCGImage:iref];
                                           [self postCompleteNotification:LoadImageFullScreen];
                                       }
                                       
                                   }
                                  failureBlock:^(NSError *error) {
                                      self.fullRorationImage = nil;
                                      [self postCompleteNotification:LoadImageFullScreen];
                                      
                                  }];
                } @catch (NSException *e) {
                    
                }
            }
        });
    }
}
- (void)stopAsyncLoadFullImage{
    if (self.fullRorationImage) {
        self.fullRorationImage = nil;
    }else {
        
    }
}
- (void)postCompleteNotification:(LoadImage)imagStyle {
    if (imagStyle == LoadImageFullScreen) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IPICKER_LOADING_DID_END_NOTIFICATION
                                                            object:self];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:IPICKER_LOADING_DID_END_Thumbnail_NOTIFICATION
                                                            object:self];
    }
    
}

@end
