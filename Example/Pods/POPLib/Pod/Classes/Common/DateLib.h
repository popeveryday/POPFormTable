//
//  DateLib.h
//  PopLibPreview
//
//  Created by Trung Pham on 8/31/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateObject.h"

@interface DateLib : NSObject

+(DateObject *) convertSolar2LunarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone;
+(DateObject*) convertLunar2SolarWithYear:(NSInteger) year month:(NSInteger)month day:(NSInteger)day timeZone: (double) timeZone lunarLeap:(double)lunarLeap;

+(NSInteger)DaysBetweenDate:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime;
+(NSDateComponents*)DateDiff:(DateObject*)fromDateTime andDate:(DateObject*)toDateTime;
+ (BOOL)CheckDate:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;
+ (BOOL)CheckDateObject:(DateObject*)date isBetweenDate:(DateObject*)beginDate andDate:(DateObject*)endDate;
+ (NSDate*) ConvertToUTCDate:(NSDate*)date;

@end
