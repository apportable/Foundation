#import <Foundation/NSCalendar.h>
#import <Foundation/NSString.h>

static NSCalendar* currentCalendar;

@implementation NSCalendar

+(id) currentCalendar
{
  if (currentCalendar == nil)
  {
    currentCalendar = [[NSCalendar alloc] init];
  }

  return currentCalendar;
}

-(NSDateComponents *) components:(NSUInteger)unitFlags fromDate:(NSDate *)date
{
  NSDateComponents *dc = [[[NSDateComponents alloc] init] autorelease];
  NSString *theDate = [date descriptionWithCalendarFormat:nil timeZone:nil locale:nil];
  // theDate should be in the format of: “%Y-%m-%d %H:%M:%S %z”
  NSInteger year, month, day, hour, minute, second;
  sscanf([theDate UTF8String], "%d-%d-%d %d:%d:%d", &year, &month, &day, &hour, &minute, &second);
  dc.year = year;
  dc.month = month;
  dc.day = day;
  dc.hour = hour;
  dc.minute = minute;
  dc.second = second;
  return dc;
}


@end

@implementation NSDateComponents

@synthesize day;
@synthesize month;
@synthesize year;
@synthesize hour;
@synthesize minute;
@synthesize second;

@end
