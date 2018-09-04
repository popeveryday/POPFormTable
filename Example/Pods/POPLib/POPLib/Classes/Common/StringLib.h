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
+(Hashtable*)deparseString:(NSString*)content;

+(Hashtable*)deparseString:(NSString*)content autoTrimKeyValue:(BOOL)isTrimContent;

+(NSString*)parseString:(Hashtable*)hash;

+(NSString*)parseStringFromDictionary:(NSDictionary*)dictionary;

+(NSString*)parseStringValidate:(id) value isParseString:(BOOL)isParseString;

+(NSString*)getHashtableValueWithKey:(NSString*)key fromHashString:(NSString*)hashString;

+(NSString*)formatDouble:(double) number decimalLength:(int) decimalLength;

+(NSString*)formatNumber:(NSNumber*) number decimalLength:(int) decimalLength;

+(NSString*)formatFileSizeWithByteValue:(double)number;

+(NSString*)formatDate:(NSDate*) date format:(NSString*) format;

+(NSString*)formatVideoDurationWithSeconds:(double) duration splitString:(NSString*)splitString;

+(NSString*)formatTimeAgo:(NSDate*) date;

+(BOOL)isValid:(NSString*)str;

+(NSString*)trim:(NSString*) str;

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr;

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr fromIndex:(NSInteger) fromIndex;

+(NSInteger)lastIndexOf:(NSString*)searchStr inString:(NSString*)srcString;

+(BOOL)contains:(NSString*) str inString:(NSString*) scr;

+(BOOL)isValidEmail:(NSString *)str;

+(BOOL)isEqualString:(NSString*) str1 withString:(NSString*) str2;

+(NSString*)subStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr;
+(NSString*)subStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd;

+(NSArray*)allSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr;
+(NSArray*)allSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd;

+(NSDictionary*)buildTreeSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr;

+(NSString*)lastSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd;

+(NSDictionary*)deparseJson:(NSString*)jsonString;

+(NSString*) convertUnicodeEncoding:(NSString*)string;

+(NSString*) convertUnicodeToASCII:(NSString*) string;

+(NSString*) genCodeFromNumber:(NSInteger)num maxLength:(NSInteger)maxLength dictionaryString:(NSString*) dictionaryString;

+(NSInteger) genNumberFromCode:(NSString*)code dictionaryString:(NSString*) dictionaryString;

+(NSString*) md5:(NSString*)str;

+(NSString*) md5_2:(NSString*)str;

+ (NSString*)sha256:(NSString*)input;

+(NSString*) replaceOneTimeWithContent:(NSString*)content original:(NSString*)original replacement:(NSString*)replacement;
@end

