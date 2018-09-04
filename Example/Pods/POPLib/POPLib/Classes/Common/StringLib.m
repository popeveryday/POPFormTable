//
//  StringLib.m
//  PhotoLib
//
//  Created by popeveryday on 11/22/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "StringLib.h"
#import "NSDate+NVTimeAgo.h"
#import <Foundation/NSNull.h>
#import "GlobalConfig.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation StringLib

+(Hashtable*)deparseString:(NSString*)content
{
    return [self deparseString:content autoTrimKeyValue:YES];
}

+(Hashtable*)deparseString:(NSString*)content autoTrimKeyValue:(BOOL)isTrimContent
{
    if (![self isValid:content]) {
        return nil;
    }
    
    Hashtable* result = [[Hashtable alloc] init];
    result.autoTrimKeyValue = isTrimContent;
    
    NSArray* params = [content componentsSeparatedByString:@"&"];
    NSArray* parts = nil;
    for (NSString* param in params) {
        if ([param isEqualToString:@""] || [param rangeOfString:@"="].location == NSNotFound) {
            continue;
        }
        
        parts = [param componentsSeparatedByString:@"="];
        [result addValue:[self parseStringValidate:parts[1] isParseString:NO] forKey:[self parseStringValidate:parts[0] isParseString:NO]];
    }
    
    return result;
}

+(NSString*)parseString:(Hashtable*)hash
{
    NSString* result = @"[@]";
    
    for (NSString* key in hash.keys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self parseStringValidate:key isParseString:YES], [self parseStringValidate:[hash hashtable_GetValueForKey:key] isParseString:YES] ];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

+(NSString*)parseStringFromDictionary:(NSDictionary*)dictionary
{
    NSString* result = @"[@]";
    
    for (NSString* key in dictionary.allKeys) {
        result = [result stringByAppendingFormat:@"&%@=%@", [self parseStringValidate:key isParseString:YES], [self parseStringValidate:[dictionary objectForKey:key] isParseString:YES]];
    }
    
    return [[result stringByReplacingOccurrencesOfString:@"[@]&" withString:@""] stringByReplacingOccurrencesOfString:@"[@]" withString: @""];
}

// & => [AnD] ; [AnD] => [AnD2] ; = => [EqL] ; [EqL] => [EqL2] ...[EqL9]
// & <= [AnD] ; [AnD] <= [AnD2] ; = <= [EqL] ; [EqL] <= [EqL2] ...[EqL9]
+(NSString*)parseStringValidate:(id) value isParseString:(BOOL)isParseString{
    
    NSString* andStr = @"[AnD]", *equalStr = @"[EqL]";
    NSString* andStr2 = @"[AnD%@]",*equalStr2 = @"[EqL%@]";
    NSString* valueStr = [NSString stringWithFormat:@"%@",value];
    
    if (isParseString) {
        
        
        for (int i = 9 ; i >=2 ; i--)
        {
            valueStr = [valueStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:andStr2, i == 2 ? @"" : @(i-1)] withString:[NSString stringWithFormat:andStr2, @(i)]];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:equalStr2, i == 2 ? @"" : @(i-1)] withString:[NSString stringWithFormat:equalStr2, @(i)]];
        }
        
        return [[valueStr stringByReplacingOccurrencesOfString:@"&" withString:andStr] stringByReplacingOccurrencesOfString:@"=" withString:equalStr];
    }else{
        
        valueStr = [[valueStr stringByReplacingOccurrencesOfString:andStr withString:@"&"] stringByReplacingOccurrencesOfString:equalStr withString:@"="];
        
        
        for (int i = 2 ; i < 10 ; i++)
        {
            valueStr = [valueStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:andStr2, @(i)] withString:[NSString stringWithFormat:andStr2, i == 2 ? @"" : @(i-1)]];
            valueStr = [valueStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:equalStr2, @(i)] withString:[NSString stringWithFormat:equalStr2, i == 2 ? @"" : @(i-1)]];
        }
        
        return valueStr;
    }
}

+(NSString*)getHashtableValueWithKey:(NSString*)key fromHashString:(NSString*)hashString{
    Hashtable* hash = [self deparseString:hashString];
    return [hash hashtable_GetValueForKey:key];
}








+(NSString*)formatDouble:(double) number decimalLength:(int) decimalLength
{
    return [StringLib formatNumber:[NSNumber numberWithDouble:number] decimalLength:decimalLength];
}

+(NSString*)formatNumber:(NSNumber*) number decimalLength:(int) decimalLength{
    NSNumberFormatter * formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:decimalLength];
    return [formatter stringFromNumber:number];
}

+(NSString*)formatFileSizeWithByteValue:(double)number{
    NSArray* subfix = @[ @"B", @"KB", @"MB", @"TB" ];
    NSInteger subfixIndex = 0;
    
    while (true) {
        if (number < 1024 || subfixIndex == subfix.count-1) {
            return [NSString stringWithFormat:@"%@ %@", [self formatDouble:number decimalLength:2], subfix[subfixIndex] ];
        }
        
        number = number / 1024.0;
        subfixIndex++;
    }
}

+(NSString*)formatDate:(NSDate*) date format:(NSString*) format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

+(NSString*)formatVideoDurationWithSeconds:(double) duration splitString:(NSString*)splitString
{
    BOOL isNegative = duration < 0;
    if(duration < 0) duration = duration * -1;
    int minutes = duration/60;
    int seconds = duration - (minutes*60);
    return [NSString stringWithFormat:@"%@%d%@%@%d", isNegative?@"-":@"", minutes, [StringLib isValid:splitString] ? splitString : @":" ,seconds>9?@"":@"0",seconds ];
}

+(NSString*)formatTimeAgo:(NSDate*) date
{
    return [date formattedAsTimeAgo];
}







+(BOOL)isValid:(NSString*)str{
    if (str == nil || [str isEqual:[NSNull null]] || [str isKindOfClass:[NSNull class]]) return NO;
    str = [self trim:str];
    return str.length > 0;
}

+(NSString*)trim:(NSString*) str{
    return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr{
    return  [self indexOf:str inString:sourcestr fromIndex:0];
}

+(NSInteger)indexOf:(NSString*) str inString:(NSString*) sourcestr fromIndex:(NSInteger) fromIndex
{
    NSString* _sourcestr = [sourcestr substringFromIndex:fromIndex];
    
    NSRange rs = [_sourcestr rangeOfString:str];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return fromIndex + rs.location;
}

+(NSInteger)lastIndexOf:(NSString*)searchStr inString:(NSString*)srcString{
    NSRange rs = [srcString rangeOfString:searchStr options:NSBackwardsSearch];
    if (rs.location == NSNotFound) {
        return -1;
    }
    return rs.location;
}


+(BOOL)contains:(NSString*) str inString:(NSString*) scr{
    return [self indexOf:str inString:scr] >= 0;
}

+(BOOL)isValidEmail:(NSString *)str
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:str];
}

+(BOOL)isEqualString:(NSString*) str1 withString:(NSString*) str2{
    
    if ([str1 isEqualToString:str2]) return YES;
    if (str1 == nil || str2 == nil) return NO;
    
    str1 = [[self trim:str1] uppercaseString];
    str2 = [[self trim:str2] uppercaseString];
    
    return [str1 isEqualToString:str2];
}


+(NSString*)subStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr{
    return [self subStringBetween:source startStr:startStr endStr:endStr includeStartEnd:NO];
}

+(NSString*)subStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd
{
    source = [NSString stringWithFormat:@" %@", source];
    NSInteger index = [self indexOf:startStr inString:source];
    if (index == -1) return nil;
    
    index += startStr.length;
    
    NSInteger endIndex = [self indexOf:endStr inString:source fromIndex:index];
    
    if (endIndex == -1) return nil;
    
    NSString* rs = [[source substringFromIndex:index] substringToIndex:endIndex - index];
    if (includeStartEnd) rs = [NSString stringWithFormat:@"%@%@%@",startStr, rs, endStr];
    return rs;
}

+(NSArray*)allSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr
{
    return [self allSubStringBetween:source startStr:startStr endStr:endStr includeStartEnd:NO];
}

+(NSArray*)allSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd
{
    NSMutableArray* rs = [NSMutableArray new];
    
    NSString* obj, *nstr = source;
    NSInteger start, end;
    while (YES)
    {
        obj = [self subStringBetween:nstr startStr:startStr endStr:endStr includeStartEnd:includeStartEnd];
        if (!obj) break;
        
        [rs addObject:obj];
        start = [StringLib indexOf:startStr inString:nstr] + startStr.length;
        end = [StringLib indexOf:endStr inString:nstr fromIndex:start];
        end += endStr.length;
        nstr = [nstr substringFromIndex:end];
    }
    
    return rs;
}

+(NSDictionary*)buildTreeSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr
{
    NSMutableDictionary* rs = [NSMutableDictionary new];
    
    NSString* obj, *nstr = source, *key;
    NSInteger counter = 1;
    while (YES)
    {
        obj = [self lastSubStringBetween:nstr startStr:startStr endStr:endStr includeStartEnd:YES];
        if (!obj) break;
        key = [NSString stringWithFormat:@"[ObJeCt%@]",@(counter)];
        [rs setObject:obj forKey:key];
        nstr = [nstr stringByReplacingOccurrencesOfString:obj withString:key];
        counter++;
    }
    
    [rs setObject:nstr forKey:@"content"];
    
    return rs;
}

+(NSString*)lastSubStringBetween:(NSString*) source startStr:(NSString*) startStr endStr:(NSString*)endStr includeStartEnd:(BOOL)includeStartEnd
{
    source = [NSString stringWithFormat:@" %@", source];
    NSInteger index = [StringLib  lastIndexOf:startStr inString:source];
    if (index == -1) return nil;
    
    index += startStr.length;
    
    NSInteger endIndex = [StringLib indexOf:endStr inString:source fromIndex:index];
    
    if (endIndex == -1) return nil;
    
    NSString* rs = [[source substringFromIndex:index] substringToIndex:endIndex - index];
    if (includeStartEnd) rs = [NSString stringWithFormat:@"%@%@%@",startStr, rs, endStr];
    return rs;
}

+(NSDictionary*)deparseJson:(NSString*)jsonString{
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return json;
}

+(NSString*) convertUnicodeEncoding:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodevalue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    return [decodevalue stringByRemovingPercentEncoding];
}

+(NSString*) convertUnicodeToASCII:(NSString*) string
{
    NSString *standard = [string stringByReplacingOccurrencesOfString:@"đ" withString:@"d"];
    standard = [standard stringByReplacingOccurrencesOfString:@"Đ" withString:@"D"];
    NSData *decode = [standard dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[NSString alloc] initWithData:decode encoding:NSASCIIStringEncoding];
}


//gen code base on dictionary of string ex: 0 -> AAAA, 1 -> AAAB
+(NSString*) genCodeFromNumber:(NSInteger)num maxLength:(NSInteger)maxLength dictionaryString:(NSString*) dictionaryString
{
    NSString* val = @"";
    NSInteger stotal = dictionaryString.length;
    
    if (num < stotal) {
        val = SubString(dictionaryString, num, num+1);
    }else{
        NSMutableArray* parts = [NSMutableArray new];
        NSInteger time = 0, surplus = 0, tempNum = num;
        
        while (tempNum >= stotal) {
            time = tempNum /stotal;
            surplus = tempNum % stotal;
            tempNum = time;
            [parts addObject: @(surplus)];
        }
        
        for (NSNumber* item in parts) {
            val = [NSString stringWithFormat:@"%@%@", SubString(dictionaryString, item.integerValue, item.integerValue+1), val];
        }
        
        val = [NSString stringWithFormat:@"%@%@", SubString( dictionaryString, time, time+1), val];
    }
    
    for (int i = 0; i < maxLength - val.length; i++) {
        val = [NSString stringWithFormat:@"%@%@", SubString(dictionaryString, 0, 1), val];
    }
    
    return val;
}
//gen number from code: AAAA -> 0
+(NSInteger) genNumberFromCode:(NSString*)code dictionaryString:(NSString*) dictionaryString
{
    NSInteger num = 0, val = 0;
    NSInteger total = dictionaryString.length;
    
    for (int i = 0; i < code.length; i++)
    {
        NSString* letter = SubString(code, (code.length - i - 1), (code.length - i - 1)+1);
        NSInteger index = IndexOf( letter, dictionaryString );
        
        val = index;
        for (int time = 0; time < i; time++) {
            val *= total;
        }
        
        num += val;
    }
    
    return num;
}

+(NSString*) md5:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString*) md5_2:(NSString*)str
{
    // Create pointer to the string as UTF8
    const char *ptr = [str UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int) strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString*)sha256:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSString*) replaceOneTimeWithContent:(NSString*)content original:(NSString*)original replacement:(NSString*)replacement
{
    NSRange rOriginal = [content rangeOfString:original];
    if (NSNotFound != rOriginal.location) {
        return [content stringByReplacingCharactersInRange:rOriginal withString:replacement];
    }
    return content;
}

@end















