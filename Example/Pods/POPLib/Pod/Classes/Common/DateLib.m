//
//  DateLib.m
//  PopLibPreview
//
//  Created by Trung Pham on 8/31/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//


#import "CommonLib.h"
#import "DateLib.h"

@implementation DateLib

+(DateObject *) convertSolar2LunarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone
{
    DateObject* date = [DateObject initWithYear:(int)year month:(int)month day:(int)day];
    return [date ToLunarDateWithTimeZone:timeZone];
}

+(DateObject*) convertLunar2SolarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone lunarLeap:(double)lunarLeap
{
    DateObject* date = [DateObject initWithYear:(int)year month:(int)month day:(int)day];
    return [date ToSolarDateWithLunarLeap:lunarLeap timeZone:timeZone];
}


+(NSInteger)DaysBetweenDate:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime
{
    return [[self DateDiff:fromDateTime andDate:toDateTime] day];
}

+(NSDateComponents*)DateDiff:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:[fromDateTime ToNSDate]];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:[toDateTime ToNSDate]];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return difference;
}


+ (BOOL)CheckDate:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

+ (BOOL)CheckDateObject:(DateObject*)date isBetweenDate:(DateObject*)beginDate andDate:(DateObject*)endDate
{
    return [self CheckDate:date.ToNSDate isBetweenDate:beginDate.ToNSDate andDate:endDate.ToNSDate];
}


+ (NSDate*) ConvertToUTCDate:(NSDate*)date{
    return [[DateObject initWithNSDate:date] ToNSDateUTC];
}




@end
