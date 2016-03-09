//
//  ImageLib.h
//  PhotoLib
//
//  Created by popeveryday on 11/23/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileLib.h"
#import "Hashtable.h"
#import "StringLib.h"
#import "GlobalConfig.h"

@interface ImageLib : NSObject

+(BOOL) CreateThumbnailImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize;
+(BOOL) CreateScaleImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize;
+(BOOL) CreatePreviewImageFromPath:(NSString *)fromPath toPath:(NSString *)toPath screenSize:(CGSize)screenSize;

+(BOOL) SaveImageToPath:(NSString*) toPath image:(UIImage*) image qualityRatio:(CGFloat) ratio;
+ (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize image:(UIImage*) image;
+ (UIImage *)imageScaleAndCropToMaxSize:(CGSize)newSize image:(UIImage*) image;

+(void) SetImageScale:(UIImageView*) image scale:(float) scale;
+(CGRect)calculateScaleImage: (UIImage*) sourceImage scaledToWidth: (float) width;
+(NSString *)GetTypeFromImageData:(NSData *)data;
+(Hashtable*) GetImageMetadata:(NSString*) imagePath;
+ (UIImage*) CreateVideoSnapshootFromMP4File:(NSString*) mp4file atSecond:(Float64) second;
+(Float64) GetDurationFromMP4File:(NSString*) mp4file;

+(UIImage*) DrawImage:(UIImage*) fgImage inImage:(UIImage*) bgImage atRect:(CGRect)rect;
+(UIImage*) CropImage:(UIImage*) bgImage atRect:(CGRect)rect;

+(UIImage*) GetDefaultFileTypeIcon:(NSString*) filename;
+(UIImage*) GetDefaultFileTypeIcon:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad;
+(NSString*) GetDefaultFileTypeString:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad;

+(UIImage*) CreateCanvasImageWithColor:(UIColor*)color size:(CGSize)size;
+(UIImage*) drawText:(NSString*) text font:(UIFont*)font color:(UIColor*)color inImage:(UIImage*) image atPoint:(CGPoint) point;

+ (UIImage*)imageNamed:(NSString*)name fromBundleName:(NSString*)bundleName;
+ (UIImage *)imageMaskedWithColor:(UIColor *)maskColor image:(UIImage*)image;

+ (UIImage *)fixOrientation:(UIImage*)image;
@end
