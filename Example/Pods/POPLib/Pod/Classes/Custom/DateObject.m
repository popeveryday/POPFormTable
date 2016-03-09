//
//  DateObject.m
//  Chapter6
//
//  Created by Trung Pham on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateObject.h"
#import "StringLib.h"
#import "NSDate+NVTimeAgo.h"

@implementation DateObject

@synthesize Year = _Year;
@synthesize Month = _Month;
@synthesize Day = _Day;

@synthesize Hour = _Hour;
@synthesize Minute = _Minute;
@synthesize Second = _Second;

-(void) dealloc{
    
}

+(id) initWithYMDString:(NSString*)ymdStr{
    return [self initWithYMDHMSString:[NSString stringWithFormat:@"%@ %02d:%02d:%02d",ymdStr, 0,0,0]];
}

+(id) initWithYMDHMSString:(NSString*)ymdhmsStr{
    DateObject* date = [[DateObject alloc] init];
    
    ymdhmsStr = [ymdhmsStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    ymdhmsStr = [ymdhmsStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    ymdhmsStr = [ymdhmsStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
    ymdhmsStr = [ymdhmsStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    ymdhmsStr = [ymdhmsStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    date.Year = [[ymdhmsStr substringToIndex:4] intValue];
    date.Month = [[[ymdhmsStr substringFromIndex:4] substringToIndex:2] intValue];
    date.Day = [[[ymdhmsStr substringFromIndex:6] substringToIndex:2] intValue];
    
    date.Hour = [[[ymdhmsStr substringFromIndex:8] substringToIndex:2] intValue];
    date.Minute = [[[ymdhmsStr substringFromIndex:10] substringToIndex:2] intValue];
    date.Second = [[[ymdhmsStr substringFromIndex:12] substringToIndex:2] intValue];
    
    return date;
}

+(id) initWithYear: (int) year month: (int) month day:(int) day{
    return [self initWithYMDString:[NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day]];
}

+(id) initWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second
{
    return [self initWithYMDHMSString:[NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second]];
}

+(DateObject*) initWithNSDate:(NSDate*) date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];
    
    return [self initWithYear:(int)components.year
                          month:(int)components.month
                            day:(int)components.day
                           hour:(int)components.hour
                         minute:(int)components.minute
                         second:(int)components.second];
}

+(DateObject*) initToday
{
    return [self initWithNSDate:[NSDate date]];
}

//============================================================================================================

-(NSString*) ToDMYString{
    return [self ToDMYStringWithFormat:@"%02d/%02d/%d"];
}

-(NSString*) ToDMYStringWithFormat:(NSString*) format{
    return [NSString stringWithFormat:format, _Day, _Month, _Year];
}

-(NSString*) ToYMDString{
    return [self ToYMDStringWithFormat:@"%d-%02d-%02d"];
}

-(NSString*) ToYMDStringWithFormat:(NSString*) format{
    return [NSString stringWithFormat:format, _Year, _Month, _Day];
}

-(NSString*) ToYMDHMSLogFormatString{
    return [self ToYMDHMSStringWithFormat:@"%d-%02d-%02d %d:%02d:%02d"];
}

-(NSString*) ToYMDHMSFileFormatString{
    return [self ToYMDHMSStringWithFormat:@"%d%02d%02d_%d%02d%02d"];
}

-(NSString*) ToYMDHMSStringWithFormat:(NSString*) format{
    return [NSString stringWithFormat:format, _Year, _Month, _Day, _Hour, _Minute, _Second];
}

-(NSString*) ToDMonYString{
    return [NSString stringWithFormat:@"%02ld %@ %ld", (long)_Day, [self GetMonthName:YES], (long)_Year];
}

-(NSString*) ToTimeAgoString
{
    return [[self ToNSDate] formattedAsTimeAgo];
}

-(BOOL) EqualDate:(DateObject*)date{
    return [self.ToYMDString isEqualToString:date.ToYMDString];
}

-(BOOL) EqualExactDate:(DateObject*)date{
    return [self.ToYMDHMSLogFormatString isEqualToString:date.ToYMDHMSLogFormatString];
}


-(NSDate*) ToNSDate
{
    NSDateComponents * date = [[NSDateComponents alloc] init] ;
    date.timeZone = [NSTimeZone defaultTimeZone];
    
    [date setDay:[self Day]];
    [date setMonth:[self Month]];
    [date setYear:[self Year]];
    [date setHour:[self Hour]];
    [date setMinute:[self Minute]];
    [date setSecond:[self Second]];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    
    NSDate *today = [gregorian dateFromComponents:date];
    
    return today;
}

-(NSDate*) ToNSDateUTC
{
    return [[self AddTimeWithYear:0 month:0 day:0 hour:0 minute:0 second:(int)[[NSTimeZone localTimeZone] secondsFromGMT]] ToNSDate];
}

-(DateObject*) AddTimeWithYear: (int) year month: (int) month day:(int) day hour:(int) hour minute:(int) minute second:(int) second
{
    // set up date components
    NSDateComponents *date = [[NSDateComponents alloc] init];
    [date setDay:day];
    [date setMonth:month];
    [date setYear:year];
    [date setHour:hour];
    [date setMinute:minute];
    [date setSecond:second];
    
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *result = [gregorian dateByAddingComponents:date toDate:[self ToNSDate] options:0];
    
    return [DateObject initWithNSDate:result];
}

-(DateObject*) AddTimeWithYear: (int) year month: (int) month day:(int) day
{
    return [self AddTimeWithYear:year month:month day:day hour:0 minute:0 second:0];
}

-(int) GetWeekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit) fromDate:[self ToNSDate]];
    
    int weekday = (int)[weekdayComponents weekday];
    
    return weekday;
}

-(NSString*) GetWeekdayName{
    NSArray* daynames = @[ @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    return daynames[ self.GetWeekday - 1 ];
}

-(NSString*) GetMonthName:(BOOL) isInShortName{
    NSArray* months = @[@"January", @"Febuary", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    return isInShortName? [months[_Month-1] substringToIndex:3] : months[_Month-1];
}

-(double) GetYMDInterval{
    NSString* str = [NSString stringWithFormat:@"%ld",(long)_Year];
    str = [str stringByAppendingFormat: @"%02ld" ,(long)_Month];
    str = [str stringByAppendingFormat: @"%02ld" ,(long)_Day];
    str = [str stringByAppendingFormat: @"%02ld" ,(long)_Hour];
    str = [str stringByAppendingFormat: @"%02ld" ,(long)_Minute];
    str = [str stringByAppendingFormat: @"%02ld" ,(long)_Second];
    
    return [str doubleValue];
}







#pragma mark - LUNAR FUNCTION==========================================================


-(DateObject *) ToLunarDateWithTimeZone: (double) timeZone{
    
    double k = 0, dayNumber = 0, monthStart = 0, a11 = 0, b11 = 0, lunarDay = 0, lunarMonth = 0, lunarYear = 0, lunarLeap = 0, leapMonthDiff = 0, diff = 0;
    
    dayNumber = [self jdFromDate:_Day mm:_Month yy:_Year];
    
    k = floor((dayNumber - 2415021.076998695) / 29.530588853);
    monthStart = [self getNewMoonDay:(k+1) timeZone: timeZone];
    
    if (monthStart > dayNumber) {
        monthStart = [self getNewMoonDay:k timeZone: timeZone];
    }
    
    a11 = [self getLunarMonth11:_Year timeZone:timeZone];
    b11 = a11;
    
    if (a11 >= monthStart) {
        lunarYear = _Year;
        a11 = [self getLunarMonth11:(_Year-1) timeZone:timeZone];
    } else {
        lunarYear = _Year+1;
        b11 = [self getLunarMonth11:(_Year+1) timeZone:timeZone];
    }
    
    
    
    lunarDay = dayNumber-monthStart+1;
    diff = floor((monthStart - a11)/29);
    lunarLeap = 0;
    lunarMonth = diff+11;
    
    if (b11 - a11 > 365) {
        leapMonthDiff = [self getLeapMonthOffset:a11 timeZone:timeZone];
        if (diff >= leapMonthDiff) {
            lunarMonth = diff + 10;
            if (diff == leapMonthDiff) {
                lunarLeap = 1;
            }
        }
    }
    if (lunarMonth > 12) {
        lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
        lunarYear -= 1;
    }
    
    return [DateObject initWithYear:lunarYear month:lunarMonth day:lunarDay];
}


-(DateObject*) ToSolarDateWithLunarLeap:(double)lunarLeap timeZone:(double) timeZone
{
    double k, a11, b11, off, leapOff, leapMonth, monthStart;
    if (_Month < 11) {
        
        a11 = [self getLunarMonth11:_Year-1 timeZone:timeZone];
        b11 = [self getLunarMonth11:_Year timeZone: timeZone];
    } else {
        a11 = [self getLunarMonth11:_Year timeZone: timeZone];
        b11 = [self getLunarMonth11:_Year+1 timeZone: timeZone];
    }
    
    off = _Month - 11;
    
    if (off < 0) {
        off += 12;
    }
    if (b11 - a11 > 365) {
        leapOff = [self getLeapMonthOffset:a11 timeZone: timeZone];
        leapMonth = leapOff - 2;
        if (leapMonth < 0) {
            leapMonth += 12;
        }
        if (lunarLeap != 0 && _Month != leapMonth) {
            return nil;
        } else if (lunarLeap != 0 || off >= leapOff)
        {
            off += 1;
        }
    }
    k = floor(0.5 + (a11 - 2415021.076998695) / 29.530588853);
    monthStart = [self getNewMoonDay:k+off timeZone:timeZone];
    return [self jdToDate:monthStart+_Day-1];
}

-(DateObject*) jdToDate: (double) jd
{
    double a, b, c, d, e, m, day, month, year;
    if (jd > 2299160) { // After 5/10/1582, Gregorian calendar
        a = jd + 32044;
        b = floor((4*a+3)/146097);
        c = a - floor((b*146097)/4);
    } else {
        b = 0;
        c = jd + 32082;
    }
    
    d = floor((4*c+3)/1461);
    e = c - floor((1461*d)/4);
    m = floor((5*e+2)/153);
    day = e - floor((153*m+2)/5) + 1;
    month = m + 3 - 12*floor(m/10);
    year = b*100 + d - 4800 + floor(m/10);
    
    return [DateObject initWithYear:year month:month day:day];
}

-(double) jdFromDate: (double) dd mm:(double) mm yy:(double) yy
{
    double a = 0, y = 0, m = 0, jd = 0;
    a = floor((14 - mm) / 12);
    
    y = yy+4800-a;
    m = mm+12*a-3;
    jd = dd + floor((153*m+2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045;
    if (jd < 2299161) {
        jd = dd + floor((153*m+2)/5) + 365*y + floor(y/4) - 32083;
    }
    return jd;
}

-(double) getNewMoonDay:(double)k timeZone:(double)timeZone
{
    
    double T, T2, T3, dr, Jd1, M, Mpr, F, C1, deltat, JdNew;
    T = k/1236.85; // Time in Julian centuries from 1900 January 0.5
    T2 = T * T;
    T3 = T2 * T;
    dr = M_PI /180;
    Jd1 = 2415020.75933 + 29.53058868*k + 0.0001178*T2 - 0.000000155*T3;
    Jd1 = Jd1 + 0.00033*sin((166.56 + 132.87*T - 0.009173*T2)*dr); // Mean new moon
    M = 359.2242 + 29.10535608*k - 0.0000333*T2 - 0.00000347*T3; // Sun's mean anomaly
    Mpr = 306.0253 + 385.81691806*k + 0.0107306*T2 + 0.00001236*T3; // Moon's mean anomaly
    F = 21.2964 + 390.67050646*k - 0.0016528*T2 - 0.00000239*T3; // Moon's argument of latitude
    C1=(0.1734 - 0.000393*T)*sin(M*dr) + 0.0021*sin(2*dr*M);
    C1 = C1 - 0.4068*sin(Mpr*dr) + 0.0161*sin(dr*2*Mpr);
    C1 = C1 - 0.0004*sin(dr*3*Mpr);
    C1 = C1 + 0.0104*sin(dr*2*F) - 0.0051*sin(dr*(M+Mpr));
    C1 = C1 - 0.0074*sin(dr*(M-Mpr)) + 0.0004*sin(dr*(2*F+M));
    C1 = C1 - 0.0004*sin(dr*(2*F-M)) - 0.0006*sin(dr*(2*F+Mpr));
    C1 = C1 + 0.0010*sin(dr*(2*F-Mpr)) + 0.0005*sin(dr*(2*Mpr+M));
    
    
    if (T < -11) {
        deltat= 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3;
    } else {
        deltat= -0.000278 + 0.000265*T + 0.000262*T2;
    };
    
    
    
    JdNew = Jd1 + C1 - deltat;
    
    return floor(JdNew + 0.5 + timeZone/24);
}

-(double) getLunarMonth11: (double) yy timeZone: (double) timeZone
{
    double k, off, nm, sunLong;
    off = [self jdFromDate:31 mm:12 yy:yy] - 2415021;
    
    k = floor(off / 29.530588853);
    
    nm = [self getNewMoonDay:k timeZone:timeZone];
    
    sunLong = [self getSunLongitude:nm timeZone:timeZone]; // sun longitude at local midnight
    
    
    if (sunLong >= 9) {
        nm = [self getNewMoonDay:(k-1) timeZone:timeZone];
    }
    return nm;
}


-(double) getSunLongitude:(double)jdn timeZone: (double) timeZone
{
    double T, T2, dr, M, L0, DL, L;
    T = (jdn - 2451545.5 - timeZone/24) / 36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    T2 = T*T;
    dr = M_PI/180; // degree to radian
    M = 357.52910 + 35999.05030*T - 0.0001559*T2 - 0.00000048*T*T2; // mean anomaly, degree
    L0 = 280.46645 + 36000.76983*T + 0.0003032*T2; // mean longitude, degree
    DL = (1.914600 - 0.004817*T - 0.000014*T2)*sin(dr*M);
    DL = DL + (0.019993 - 0.000101*T)*sin(dr*2*M) + 0.000290*sin(dr*3*M);
    L = L0 + DL; // true longitude, degree
    L = L*dr;
    L = L - M_PI*2*(floor(L/(M_PI*2))); // Normalize to (0, 2*PI)
    return floor(L / M_PI * 6);
}

-(double) getLeapMonthOffset:(double) a11 timeZone: (double)timeZone
{
    double k, last, arc, i;
    k = floor((a11 - 2415021.076998695) / 29.530588853 + 0.5);
    last = 0;
    i = 1; // We start with the month following lunar month 11
    arc = [self getSunLongitude: [self getNewMoonDay:(k+i) timeZone:timeZone] timeZone:timeZone];
    do {
        last = arc;
        i++;
        arc = [self getSunLongitude:[self getNewMoonDay:(k+i) timeZone:timeZone] timeZone:timeZone];
    } while (arc != last && i < 14);
    return i-1;
}


@end
