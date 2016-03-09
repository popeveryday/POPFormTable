//
//  StringLib.h
//  PhotoLib
//
//  Created by popeveryday on 11/22/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hashtable.h"

@interface StringLib : NSObject
+(Hashtable*) DeparseString:(NSString*)content;
+(Hashtable*) DeparseString:(NSString*)content autoTrimKeyValue:(BOOL)isTrimContent;
+(NSString*) ParseString:(Hashtable*)hash;
+(NSString*) ParseStringFromDictionary:(NSDictionary*)dictionary;
+(NSString*) ParseStringValidate:(id) value isParseString:(BOOL)isParseString;
+(NSString*) GetHashtableValueWithKey:(NSString*)key fromHashString:(NSString*)hashString;

+(NSString*) FormatNumber:(NSNumber*) number decimalLength:(int) decimalLength;
+(NSString*) FormatDouble:(double) number decimalLength:(int) decimalLength;
+(NSString*) FormatDate:(NSDate*) date format:(NSString*) format;
+(NSString*) FormatFileSizeWithByteValue:(double)number;
+(NSString*) FormatVideoDurationWithSeconds:(double) duration splitString:(NSString*)splitString;
+(NSString*) FormatTimeAgo:(NSDate*) date;

+(BOOL) IsValid:(NSString*)str;
+(NSString*) Trim:(NSString*) str;
+(NSInteger) IndexOf:(NSString*) str inString:(NSString*) sourcestr;
+(NSInteger) IndexOf:(NSString*) str inString:(NSString*) sourcestr fromIndex:(NSInteger) fromIndex;
+(NSInteger) LastIndexOf:(NSString*)searchStr inString:(NSString*)srcString;
+(BOOL) Contains:(NSString*) str inString:(NSString*) scr;
+(BOOL) IsValidEmail:(NSString *)str;
+(BOOL) IsEqualString:(NSString*) str1 withString:(NSString*) str2;
+(NSString*) SubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr;

+(NSDictionary*) DeparseJson:(NSString*)jsonString;

@end
