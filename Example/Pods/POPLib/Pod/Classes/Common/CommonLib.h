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
@import MessageUI;
@import AssetsLibrary;


@protocol AppSettingsDelegate <NSObject>
@optional
-(void) appSettingsDidFinishAction:(BOOL)isRequireReload;
-(void) appSettingsDidViewItemAtIndex:(NSInteger)currentIndex;

-(void) appSettingsDidFinishActionWithObject:(ReturnSet*)object;
@end



@interface CommonLib : NSObject
+(void)alertWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;
+(void)alertWithTitle:(NSString*) title message:(NSString*) message;
+(void)alert:(NSString*) message;
+(UIAlertView*)alertLoginBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;
+(UIAlertView*)alertInputBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;
+(UIAlertView*)alertSecureInputBoxWithTitle:(NSString*) title message:(NSString*) message container:(id)container cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;
+(void)actionSheetWithTitle:(NSString*) title container:(id) container cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;
+(void)actionSheetWithTitle:(NSString*) title container:(id) container cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitlesArray:(NSArray*)otherButtonTitles;
+(void)actionSheetWithTitle:(NSString*) title container:(UIView*) container delegate:(id)delegate cancelButtonTitle:(NSString*) cancelButtonTitle destructiveButtonTitle:(NSString*)destructiveButtonTitle otherButtonTitlesArray:(NSArray*)otherButtonTitles;
+(void)setAppPreference:(NSString*) key value:(id)value;
+(void)setAppPreference:(NSString*) key boolValue:(BOOL)value;
+(id)getAppPreference:(NSString*)key defaultValue:(id)defaultValue;
+(NSInteger)randomFromInt:(NSInteger) from toInt:(NSInteger) to;
+(id)popRandomItemFromArray:(NSMutableArray*) array;
+(id)popFirstItemFromArray:(NSMutableArray*) array;
+(void)shufflingArray:(NSMutableArray *) array;
+(UIColor*)colorFromHexString:(NSString *)hexString alpha:(float) alpha;
+(void)addObserverBecomeActiveForObject:(id) container activeSelector:(SEL)activeSelector;
+(BOOL)alertInternetConnectionStatusWithTitle:(NSString*) title message:(NSString*)message;
+(BOOL)alertInternetConnectionStatus;
+(NSArray*)alertUpgrageFeaturesWithContainer:(id)container isIncludeRestoreButton:(BOOL)isIncludeRestoreButton;
+(NSArray*)alertUpgrageFeaturesUnlimitWithContainer:(id)container limitMessage:(NSString*)limitMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton;
+(NSArray*)alertUpgrageProVersionWithContainer:(id)container featuresMessage:(NSString*)featuresMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton;
+(NSArray*)sortArrayIndexPath:(NSArray*) arr ascending:(BOOL) ascending;
+(NSString*)simulatorAppDirectoryPath;
+(void)boldFontIOS7ForLabel:(UILabel *)label;
+(NSString*)deviceModelType;
+(NSString*)localizedText:(NSString*)text languageCode:(NSString*)code;
+(void)localizedDefaulLanguageCode:(NSString*)code;
@end
