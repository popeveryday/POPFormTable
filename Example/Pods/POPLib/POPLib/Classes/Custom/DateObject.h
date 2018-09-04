//
//  DateObject.h
//  Chapter6
//
//  Created by Trung Pham on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateObject : NSObject

@property (nonatomic) NSInteger Year;
@property (nonatomic) NSInteger Month;
@property (nonatomic) NSInteger Day;

@property (nonatomic) NSInteger Hour;
@property (nonatomic) NSInteger Minute;
@property (nonatomic) NSInteger Second;
@property (nonatomic) NSInteger MiliSecond;

+(id)initWithYMDString:(NSString*)ymdStr;
+(id)initWithYMDHMSString:(NSString*)ymdhmsStr;
+(id)initWithYear: (NSInteger) year month: (NSInteger) month day:(NSInteger) day;
+(id)initWithYear: (NSInteger) year month: (NSInteger) month day:(NSInteger) day hour:(NSInteger) hour minute:(NSInteger) minute second:(NSInteger) second;
+(id)initWithYear: (NSInteger) year month: (NSInteger) month day:(NSInteger) day hour:(NSInteger) hour minute:(NSInteger) minute second:(NSInteger) second milisecond:(NSInteger)milisecond;
+(DateObject*)initWithNSDate:(NSDate*) date;
+(DateObject*)initToday;

-(NSString*)toTimeAgoString;

-(NSString*)toHMSTimeString;
-(NSString*)toHMSTimeStringWithFormat:(NSString*) format;

-(NSString*)toHMTimeString;
-(NSString*)toHMTimeStringWithFormat:(NSString*) format;

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
-(DateObject*)addTimeWithYear: (NSInteger) year month: (NSInteger) month day:(NSInteger) day hour:(NSInteger) hour minute:(NSInteger) minute second:(NSInteger) second;
-(DateObject*)addTimeWithYear: (NSInteger) year month: (NSInteger) month day:(NSInteger) day;

-(double)getYMDInterval;
-(int)getWeekday;
-(NSString*)getWeekdayName;
-(NSString*)getMonthName:(BOOL) isInShortName;

-(DateObject*)toSolarDateWithLunarLeap:(double)lunarLeap timeZone:(double) timeZone;
-(DateObject*)toLunarDateWithTimeZone: (double) timeZone;

@end
