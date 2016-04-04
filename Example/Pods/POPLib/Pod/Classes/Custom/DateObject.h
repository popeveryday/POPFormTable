//
//  DateObject.h
//  Chapter6
//
//  Created by Trung Pham on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateObject : NSObject

@property (nonatomic) int Year;
@property (nonatomic) int Month;
@property (nonatomic) int Day;

@property (nonatomic) int Hour;
@property (nonatomic) int Minute;
@property (nonatomic) int Second;

+(id)initWithYMDString:(NSString*)ymdStr;
+(id)initWithYMDHMSString:(NSString*)ymdhmsStr;
+(id)initWithYear: (int) year month: (int) month day:(int) day;
+(id)initWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second;
+(DateObject*)initWithNSDate:(NSDate*) date;
+(DateObject*)initToday;

-(NSString*)toTimeAgoString;

-(NSString*)toDMYString;
-(NSString*)toDMYStringWithFormat:(NSString*) format;
-(NSString*)toDMonYString;

-(NSString*)toYMDString;
-(NSString*)toYMDStringWithFormat:(NSString*) format;

-(NSString*)toYMDHMSLogFormatString;
-(NSString*)toYMDHMSFileFormatString;
-(NSString*)toYMDHMSStringWithFormat:(NSString*) format;

-(BOOL)equalDate:(DateObject*)date;
-(BOOL)equalExactDate:(DateObject*)date;

-(NSDate*)toNSDate;
-(NSDate*)toNSDateUTC;
-(DateObject*)addTimeWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second;
-(DateObject*)addTimeWithYear: (int) year month: (int) month day:(int) day;

-(double)getYMDInterval;
-(int)getWeekday;
-(NSString*)getWeekdayName;
-(NSString*)getMonthName:(BOOL) isInShortName;

-(DateObject*)toSolarDateWithLunarLeap:(double)lunarLeap timeZone:(double) timeZone;
-(DateObject*)toLunarDateWithTimeZone: (double) timeZone;

@end
