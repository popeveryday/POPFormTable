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

+(BOOL)createThumbnailImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize;
+(BOOL)createScaleImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize;
+(BOOL)createPreviewImageFromPath:(NSString *)fromPath toPath:(NSString *)toPath screenSize:(CGSize)screenSize;

+(BOOL)saveImageToPath:(NSString*) toPath image:(UIImage*) image qualityRatio:(CGFloat) ratio;
+(UIImage*)imageScaleAspectToMaxSize:(CGFloat)newSize image:(UIImage*) image;
+(UIImage*)imageScaleAndCropToMaxSize:(CGSize)newSize image:(UIImage*) image;
+(UIImage*)resizeImage:(UIImage*)image newSize:(CGSize)newSize;

+(void)setImageScale:(UIImageView*) image scale:(float) scale;
+(CGRect)calculateScaleImage: (UIImage*) sourceImage scaledToWidth: (float) width;
+(NSString*)getTypeFromImageData:(NSData *)data;
+(Hashtable*)getImageMetadata:(NSString*) imagePath;
+(UIImage*)createVideoSnapshotFromMP4File:(NSString*) mp4file atSecond:(Float64) second;
+(NSMutableArray*)createVideoSnapshotsFromMP4File:(NSString*)mp4file;
+(Float64)getDurationFromMP4File:(NSString*) mp4file;

+(UIImage*)drawImage:(UIImage*) fgImage inImage:(UIImage*) bgImage atRect:(CGRect)rect;
+(UIImage*)cropImage:(UIImage*) bgImage atRect:(CGRect)rect;

+(UIImage*)getDefaultFileTypeIcon:(NSString*) filename;
+(UIImage*)getDefaultFileTypeIcon:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad;
+(NSString*)getDefaultFileTypeString:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad;

+(UIImage*)createCanvasImageWithColor:(UIColor*)color size:(CGSize)size isTransparent:(BOOL)isTransparent;
+(UIImage*)drawText:(NSString*) text font:(UIFont*)font color:(UIColor*)color inImage:(UIImage*) image atPoint:(CGPoint) point;

+(UIImage*)imageNamed:(NSString*)name fromBundleName:(NSString*)bundleName;
+(UIImage*)imageMaskedWithColor:(UIColor *)maskColor image:(UIImage*)image;

+(UIImage*)fixOrientation:(UIImage*)image;

//blur view bg for example
+(UIImage *)blurImage:(UIImage *)sourceImage blurValue:(NSInteger)blurValue destinationSize:(CGSize)size;
@end
