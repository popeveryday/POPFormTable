//
//  ImageLib.m
//  PhotoLib
//
//  Created by popeveryday on 11/23/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "ImageLib.h"
#import <ImageIO/ImageIO.h>
@import AVFoundation;

@implementation ImageLib

+(BOOL)createThumbnailImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fromPath];
    UIImage *thumb = [self imageScaleAndCropToMaxSize:maxSize image:image];
    return [self saveImageToPath:toPath image:thumb qualityRatio:0.8];
}

+(BOOL)createScaleImageFromPath:(NSString*) fromPath toPath:(NSString*) toPath maxSize:(CGSize) maxSize{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fromPath];
    UIImage *thumb = [self imageScaleAspectToMaxSize: maxSize.width > maxSize.height ? maxSize.width : maxSize.height  image:image];
    return [self saveImageToPath:toPath image:thumb qualityRatio:1.0];
}

+(BOOL)createPreviewImageFromPath:(NSString *)fromPath toPath:(NSString *)toPath screenSize:(CGSize)screenSize{
    if (![FileLib checkPathExisted:fromPath]) return NO;
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fromPath];
    if (image == nil) return NO;
    
    UIImage* thumb;
    
    CGFloat imageLong = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat imageShort = image.size.width < image.size.height ? image.size.width : image.size.height;
    
    CGFloat screenLong = screenSize.width > screenSize.height ? screenSize.width : screenSize.height;
    
    //too small image do nothing -> copy file only
    if (imageLong < screenLong || imageLong < screenLong*3) {
        return [self saveImageToPath:toPath image:image qualityRatio:0.8];
    }
    //for long image imageShort -> screenLong
    else if (image.size.width > 2 * image.size.height || 2 * image.size.width < image.size.height )
    {
        if (imageShort < screenLong) {
            return [FileLib copyFileFromPath:fromPath toPath:toPath];
        }else{
            thumb = [self imageScaleAspectToMaxSize: (((CGFloat)screenLong / (CGFloat)imageShort) * (CGFloat)imageLong)*2  image:image];
        }
    }
    else{ //for normal image size
        thumb = [self imageScaleAspectToMaxSize: screenLong*3  image:image];
    }
    
    return [self saveImageToPath:toPath image:thumb qualityRatio:0.8];
}



+(BOOL)saveImageToPath:(NSString*) toPath image:(UIImage*) image qualityRatio:(CGFloat) ratio{
    if (![toPath.pathExtension.uppercaseString isEqualToString:@"PNG"]) {
        NSData* jpg = UIImageJPEGRepresentation(image, ratio);  // 0.8 = least compression, best quality
        return [jpg writeToFile:toPath atomically:NO];
    }else{
        NSData* png = UIImagePNGRepresentation(image);  // 0.8 = least compression, best quality
        return [png writeToFile:toPath atomically:NO];
    }
}

+(UIImage*)imageScaleAspectToMaxSize:(CGFloat)newSize image:(UIImage*) image {
    CGSize size = [image size];
    
    if (size.width < newSize && size.height < newSize) {
        return image;
    }
    
    CGFloat ratio;
    if (size.width > size.height) {
        ratio = (CGFloat)newSize / (CGFloat)size.width;
    } else {
        ratio = (CGFloat)newSize / (CGFloat)size.height;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(UIImage*)imageScaleAndCropToMaxSize:(CGSize)newSize image:(UIImage*) image {
    CGFloat largestSize = (newSize.width > newSize.height) ? newSize.width : newSize.height;
    CGSize imageSize = [image size];
    
    // Scale the image while mainting the aspect and making sure the
    // the scaled image is not smaller then the given new size. In
    // other words we calculate the aspect ratio using the largest
    // dimension from the new size and the small dimension from the
    // actual size.
    CGFloat ratio;
    if (imageSize.width > imageSize.height) {
        ratio = (CGFloat)largestSize / (CGFloat)imageSize.height;
    } else {
        ratio = (CGFloat)largestSize / (CGFloat)imageSize.width;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio * imageSize.width, ratio * imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Crop the image to the requested new size maintaining
    // the inner most parts of the image.
    CGFloat offsetX = 0;
    CGFloat offsetY = 0;
    imageSize = [scaledImage size];
    if (imageSize.width < imageSize.height) {
        offsetY = ((CGFloat)imageSize.height / 2) - ((CGFloat)imageSize.width / 2);
    } else {
        offsetX = ((CGFloat)imageSize.width / 2) - ((CGFloat)imageSize.height / 2);
    }
    
    CGRect cropRect = CGRectMake(offsetX, offsetY,
                                 (CGFloat)imageSize.width - (offsetX * 2),
                                 (CGFloat)imageSize.height - (offsetY * 2));
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([scaledImage CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    return newImage;
}

+(void)setImageScale:(UIImageView*) image scale:(float) scale{
    image.frame = CGRectMake(image.frame.origin.x ,image.frame.origin.y ,image.image.size.width*scale, image.image.size.height*scale);
}

+(CGRect)calculateScaleImage: (UIImage*) sourceImage scaledToWidth: (float) width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = (CGFloat)width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    return CGRectMake(0, 0, newWidth, newHeight);
}

+(NSString*)getTypeFromImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg"; // @"image/jpeg";
        case 0x89:
            return @"png"; //@"image/png";
        case 0x47:
            return @"gif";//    @"image/gif";
        case 0x49:
        case 0x4D:
            return @"tif"; //@"image/tiff";
        case 0x42:
            return @"bmp"; // @"image/bmp";
    }
    return nil;
}

+(Hashtable*)getImageMetadata:(NSString*) imagePath{
    Hashtable* result = [[Hashtable alloc] init];
    
    NSURL *imageFileURL = [NSURL fileURLWithPath:imagePath];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageFileURL, NULL);
    
    if (imageSource == NULL) {
        return result;
    }
    
    
    [result hashtable_AddValue:imagePath.lastPathComponent forKey:@"File Name"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        [result hashtable_AddValue:CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) forKey:@"Width"];
        [result hashtable_AddValue:CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) forKey:@"Height"];
        [result hashtable_AddValue:CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) forKey:@"File Size"];
        
        CFDictionaryRef exif = CFDictionaryGetValue(imageProperties, kCGImagePropertyExifDictionary);
        if (exif) {
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifDateTimeOriginal) forKey:@"DateTime"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifExposureMode) forKey:@"Exposure Mode"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifExposureTime) forKey:@"Exposure Time"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifISOSpeedRatings) forKey:@"ISO Speed"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifFocalLength) forKey:@"Focal Length"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifFNumber) forKey:@"F-Number"];
            [result hashtable_AddValue:CFDictionaryGetValue(exif, kCGImagePropertyExifMeteringMode) forKey:@"Metering Mode"];
        }
        
        CFDictionaryRef tiff = CFDictionaryGetValue(imageProperties, kCGImagePropertyTIFFDictionary);
        if (tiff) {
            [result hashtable_AddValue:CFDictionaryGetValue(tiff, kCGImagePropertyTIFFModel) forKey:@"Camera Mode"];
        }
        
        CFDictionaryRef gps = CFDictionaryGetValue(imageProperties, kCGImagePropertyGPSDictionary);
        if (gps) {
            [result hashtable_AddValue:CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitude) forKey:@"GPSLatitude"];
            [result hashtable_AddValue:CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitudeRef) forKey:@"GPSLatitudeRef"];
            [result hashtable_AddValue:CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitude) forKey:@"GPSLongitude"];
            [result hashtable_AddValue:CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitudeRef) forKey:@"GPSLongitudeRef"];
        }
        
        CFRelease(imageProperties);
    }
    CFRelease(imageSource);
    
    return result;
}

+(UIImage*)createVideoSnapshootFromMP4File:(NSString*) mp4file atSecond:(Float64) second{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:mp4file] options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    //fix image orientation
    generate.appliesPreferredTrackTransform = YES;
    
    NSError *err = NULL;
    CMTime time = CMTimeMakeWithSeconds(second, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    
    if(!err) return [[UIImage alloc] initWithCGImage:imgRef];
    return nil;
}

+(Float64)getDurationFromMP4File:(NSString*) mp4file{
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:mp4file];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    return CMTimeGetSeconds(sourceAsset.duration);
}

+(UIImage*)drawImage:(UIImage*) fgImage inImage:(UIImage*) bgImage atRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)cropImage:(UIImage*) bgImage atRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions( rect.size , FALSE, 0.0);
    
    [bgImage drawInRect:CGRectMake( -rect.origin.x, -rect.origin.y, bgImage.size.width, bgImage.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*)getDefaultFileTypeIcon:(NSString*) filename{
    return [self getDefaultFileTypeIcon:filename isFolder:NO isIpad:GC_Device_IsIpad];
}

+(UIImage*)getDefaultFileTypeIcon:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad{
    return [UIImage imageNamed:[self getDefaultFileTypeString:filename isFolder:isFolder isIpad:isIpad]];
}

+(NSString*)getDefaultFileTypeString:(NSString*) filename isFolder:(BOOL)isFolder isIpad:(BOOL)isIpad{
    if (isFolder) {
        return isIpad ? @"CommonLib.bundle/FileExplorerFolderIpad" : @"CommonLib.bundle/FileExplorerFolder";
    }
    
    if(IsImageFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadImage" : @"CommonLib.bundle/FileExplorerFileImage";
    }
    
    if(IsVideoFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadVideo" : @"CommonLib.bundle/FileExplorerFileVideo";
    }
    
    if(IsTextFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadText" : @"CommonLib.bundle/FileExplorerFileText";
    }
    
    if(IsOfficeFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadOffice" : @"CommonLib.bundle/FileExplorerFileOffice";
    }
    
    if(IsSoundFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadSound" : @"CommonLib.bundle/FileExplorerFileSound";
    }
    
    if(IsArchiveFile(filename)){
        return isIpad ? @"CommonLib.bundle/FileExplorerFileIpadArchive" : @"CommonLib.bundle/FileExplorerFileArchive";
    }
    
    return isIpad ? @"CommonLib.bundle/FileExplorerFileIpad" : @"CommonLib.bundle/FileExplorerFile";
}

+(UIImage*)createCanvasImageWithColor:(UIColor*)color size:(CGSize)size{
    CGSize imageSize = size;
    UIColor *fillColor = color == nil ? [UIColor clearColor] : color;
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage*)drawText:(NSString*) text font:(UIFont*)font color:(UIColor*)color inImage:(UIImage*) image atPoint:(CGPoint) point
{
    
    if(font == nil) font = [UIFont boldSystemFontOfSize:12];
    if(color == nil) color = [UIColor whiteColor];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [image drawInRect:rect];
    
    NSDictionary *attributes = @{  NSFontAttributeName: font
                                   , NSForegroundColorAttributeName : color
                                   };
    [text drawAtPoint:point withAttributes:attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



//get image from .xcassets inside .bundle
+(UIImage*)imageNamed:(NSString*)name fromBundleName:(NSString*)bundleName
{
    bundleName = [NSString stringWithFormat:@"%@.bundle", bundleName];
    bundleName = [bundleName stringByReplacingOccurrencesOfString:@".bundle.bundle" withString:@".bundle"];
    
    if (GC_Device_iOsVersion < 8) {
        UIImage *image;
        
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", bundleName, name]];
        if (image) {
            return image;
        }
        
        
        NSURL *bundleUrl = [FileLib getEmbedResourceURLWithFilename: bundleName];
        if(bundleUrl == nil) return nil;
        NSBundle *bundle = [NSBundle bundleWithURL:bundleUrl];
        
        image = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:name]];
        
        return image;
    }else{
        NSURL *bundleUrl = [FileLib getEmbedResourceURLWithFilename: bundleName];
        if(bundleUrl == nil) return nil;
        NSBundle *bundle = [NSBundle bundleWithURL:bundleUrl];
        
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    }
}

+(UIImage*)imageMaskedWithColor:(UIColor *)maskColor image:(UIImage*)image
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, image.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, image.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(UIImage*)fixOrientation:(UIImage*)image
{
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
