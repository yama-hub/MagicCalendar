//
//  CalendarController.h
//  Calendar
//
//  Created by yamamoto on 2014/03/27.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagicCalendarCollectionCell.h"
#import "UIView+UsefulKit.h"
#import "NSDate+UsefulKit.h"

@protocol MagicCalendarControllerDelegate;
@protocol MagicCalendarCollectionCellDataSource;
@class EKEvent;
@interface MagicCalendarController : UICollectionViewController <UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

/**
 Year of calendar you want to display
 */
@property (assign, nonatomic) NSUInteger displayYear;

/**
 Selected date
 */
@property (readonly, nonatomic) NSDate *selectedDate;

/**
 Start day of the week
 */
@property (assign, nonatomic) NSInteger startWeekday;

/**
 Background color of the calendar
 */
@property (nonatomic, strong) UIColor *backgroundColor;


@property (assign, nonatomic) id <MagicCalendarControllerDelegate>delegate;
@property (assign, nonatomic) id <MagicCalendarCollectionCellDataSource>dataSource;

- (void)scrollToMonth:(NSInteger)month animated:(BOOL)animated;
- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated;
- (void)reloadWeekday:(NSInteger)weekday;

@end

@protocol MagicCalendarControllerDelegate <NSObject>

@optional
- (void)magicCalendarController:(MagicCalendarController *)controller decrementYear:(NSInteger)decrementYear;
- (void)magicCalendarController:(MagicCalendarController *)controller incrementYear:(NSInteger)incrementYear;
- (void)magicCalendarController:(MagicCalendarController *)controller changeMonth:(NSInteger)month;

- (void)magicCalendarController:(MagicCalendarController *)controller newEvent:(NSDate *)date;
- (NSArray *)magicCalendarController:(MagicCalendarController *)controller selectedDay:(NSDate *)date;
- (void)magicCalendarController:(MagicCalendarController *)controller selectedEvent:(EKEvent *)event;
@end

@protocol MagicCalendarCollectionCellDataSource <NSObject>

@optional
- (BOOL)magicCalendarControllerIsHoliday:(MagicCalendarController *)controller date:(NSDate *)date;
- (BOOL)magicCalendarControllerIsSchedule:(MagicCalendarController *)controller date:(NSDate *)date;
@end