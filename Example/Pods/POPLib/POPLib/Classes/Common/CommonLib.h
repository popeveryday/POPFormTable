//
//  CommonLib.h
//  CommonLib
//
//  Created by popeveryday on 11/6/13.
//  Copyright (c) 2013 Lapsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DateObject.h"
#import "StringLib.h"
#import "NetLib.h"
#import "GlobalConfig.h"
#import <MessageUI/MessageUI.h>
#import <AssetsLibrary/AssetsLibrary.h>


@protocol AppSettingsDelegate <NSObject>
@optional
-(void) appSettingsDidFinishAction:(BOOL)isRequireReload;
-(void) appSettingsDidViewItemAtIndex:(NSInteger)currentIndex;

-(void) appSettingsDidFinishActionWithObject:(ReturnSet*)object;
@end



@interface CommonLib : NSObject

+(void)setAppPreference:(NSString*) key value:(id)value;

+(void)setAppPreference:(NSString*) key boolValue:(BOOL)value;

+(id)getAppPreference:(NSString*)key defaultValue:(id)defaultValue;

+(NSInteger)randomFromInt:(NSInteger) from toInt:(NSInteger) to;

+(id)popRandomItemFromArray:(NSMutableArray*) array;

+(id)popFirstItemFromArray:(NSMutableArray*) array;

+(void)shufflingArray:(NSMutableArray *) array;

+(UIColor*)colorFromHexString:(NSString *)hexString alpha:(float) alpha;

+(void)addObserverBecomeActiveForObject:(id) container activeSelector:(SEL)activeSelector;



+(NSArray*)sortArrayIndexPath:(NSArray*) arr ascending:(BOOL) ascending;

+(NSString*)simulatorAppDirectoryPath;

+(UIFont*)boldFont:(UIFont *)font;

+(NSString*)deviceModelType;

+(NSString*)deviceModelTypeCode;

+(NSString*)getDeviceByResolution;

+(NSString*)localizedText:(NSString*)text languageCode:(NSString*)code;

+(void)localizedDefaultLanguageCode:(NSString*)code;
+(NSString*)getLocalizedWithDefaultLanguageCode:(NSString*)code;

+(UIDeviceOrientation)deviceOrientation;

+(NSString*) genJsonFromObject:(id)obj;

+(id) serializationObject:(id) obj;

+(NSDictionary*) serializationDictionaryFromObject:(id) obj;

+(BOOL) saveObject:(id)obj toFilePath:(NSString*)filePath allowSafeBackup:(BOOL)allowSafeBackup;

+(id) loadObjectFromFile:(NSString*) filePath allowSafeBackup:(BOOL)allowSafeBackup;
+(id) loadObjectFromFile:(NSString*) filePath allowSafeBackup:(BOOL)allowSafeBackup validateBlock:(BOOL (^)(id obj)) validateBlock;
@end
