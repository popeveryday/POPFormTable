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

+(DateObject*)convertSolar2LunarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone
{
    DateObject* date = [DateObject initWithYear:(int)year month:(int)month day:(int)day];
    return [date toLunarDateWithTimeZone:timeZone];
}

+(DateObject*)convertLunar2SolarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone lunarLeap:(double)lunarLeap
{
    DateObject* date = [DateObject initWithYear:(int)year month:(int)month day:(int)day];
    return [date toSolarDateWithLunarLeap:lunarLeap timeZone:timeZone];
}


+(NSInteger)daysBetweenDate:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime
{
    return [[self dateDiff:fromDateTime andDate:toDateTime] day];
}

+(NSDateComponents*)dateDiff:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:[fromDateTime toNSDate]];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:[toDateTime toNSDate]];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return difference;
}


+(BOOL)checkDate:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

+(BOOL)checkDateObject:(DateObject*)date isBetweenDate:(DateObject*)beginDate andDate:(DateObject*)endDate
{
    return [self checkDate:date.toNSDate isBetweenDate:beginDate.toNSDate andDate:endDate.toNSDate];
}


+(NSDate*)convertToUTCDate:(NSDate*)date{
    return [[DateObject initWithNSDate:date] toNSDateUTC];
}

+(NSTimeInterval)toTimeStamp:(NSDate *)date
{
    return (long)[date timeIntervalSince1970];
}

+(NSTimeInterval)toTimeStamp:(NSDate *)date miliSecond:(BOOL)miliSecond
{
    return [self toTimeStamp:date] * (miliSecond?1000:1);
}

+(NSDate*)fromTimeStamp:(NSTimeInterval)timestamp miliSecond:(BOOL)miliSecond
{
    return [NSDate dateWithTimeIntervalSince1970: timestamp/(miliSecond?1000:1)];
}

@end




