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

+(id) initWithYMDString:(NSString*)ymdStr;
+(id) initWithYMDHMSString:(NSString*)ymdhmsStr;
+(id) initWithYear: (int) year month: (int) month day:(int) day;
+(id) initWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second;
+(DateObject*) initWithNSDate:(NSDate*) date;
+(DateObject*) initToday;

-(NSString*) ToTimeAgoString;

-(NSString*) ToDMYString;
-(NSString*) ToDMYStringWithFormat:(NSString*) format;
-(NSString*) ToDMonYString;

-(NSString*) ToYMDString;
-(NSString*) ToYMDStringWithFormat:(NSString*) format;

-(NSString*) ToYMDHMSLogFormatString;
-(NSString*) ToYMDHMSFileFormatString;
-(NSString*) ToYMDHMSStringWithFormat:(NSString*) format;

-(BOOL) EqualDate:(DateObject*)date;
-(BOOL) EqualExactDate:(DateObject*)date;

-(NSDate*) ToNSDate;
-(NSDate*) ToNSDateUTC;
-(DateObject*) AddTimeWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second;
-(DateObject*) AddTimeWithYear: (int) year month: (int) month day:(int) day;

-(double) GetYMDInterval;
-(int) GetWeekday;
-(NSString*) GetWeekdayName;
-(NSString*) GetMonthName:(BOOL) isInShortName;

-(DateObject*) ToSolarDateWithLunarLeap:(double)lunarLeap timeZone:(double) timeZone;
-(DateObject *) ToLunarDateWithTimeZone: (double) timeZone;


@end
