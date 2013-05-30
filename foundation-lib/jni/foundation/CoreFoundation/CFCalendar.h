//
// CFCalendar.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFCALENDAR_H_
#define _CFCALENDAR_H_

typedef enum {
    kCFCalendarUnitEra               = (1 << 1),
    kCFCalendarUnitYear              = (1 << 2),
    kCFCalendarUnitMonth             = (1 << 3),
    kCFCalendarUnitDay               = (1 << 4),
    kCFCalendarUnitHour              = (1 << 5),
    kCFCalendarUnitMinute            = (1 << 6),
    kCFCalendarUnitSecond            = (1 << 7),
    kCFCalendarUnitWeek              = (1 << 8),
    kCFCalendarUnitWeekday           = (1 << 9),
    kCFCalendarUnitWeekdayOrdinal    = (1 << 10),
    kCFCalendarUnitQuarter           = (1UL << 11),
    kCFCalendarUnitWeekOfMonth       = (1UL << 12),
    kCFCalendarUnitWeekOfYear        = (1UL << 13),
    kCFCalendarUnitYearForWeekOfYear = (1UL << 14),
} CFCalendarUnit;

#endif /* _CFCALENDAR_H_ */