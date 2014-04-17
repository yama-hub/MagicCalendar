//
//  CalendarCollectionCell.h
//  Calendar
//
//  Created by yamamoto on 2014/03/27.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MagicCalendarCollectionCellDelegate;
@interface MagicCalendarCollectionCell : UICollectionViewCell

@property (assign, nonatomic) BOOL isToday;
@property (assign, nonatomic) BOOL isSchedule;
@property (assign, nonatomic) BOOL isSaturday;
@property (assign, nonatomic) BOOL isSunday;
@property (assign, nonatomic) BOOL isSelected;
@property (strong, nonatomic) UILabel *dayLabel, *scheduleLabel;
@property (assign, nonatomic) id <MagicCalendarCollectionCellDelegate>delegate;

@property (readonly, nonatomic) NSDate *date;

- (void)setDate:(NSDate *)date today:(NSDate *)today;
- (void)setupColor:(NSDate *)today;

/**
 *  Customize the circle behind the day's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleDefaultColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color of the circle for today's cell using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleTodayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color of the circle when cell is selected using UIAppearance.
 */
@property (nonatomic, strong) UIColor *circleSelectedColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textDefaultColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize today's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textTodayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize saturday's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textSaturdayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize holiday's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textHolidayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize sunday's number color using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textSundayColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the day's number color when cell is selected using UIAppearance.
 */
@property (nonatomic, strong) UIColor *textSelectedColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the event's number color when exist  using UIAppearance.
 */
@property (nonatomic, strong) UIColor *eventMarkColor UI_APPEARANCE_SELECTOR;

@end

@protocol MagicCalendarCollectionCellDelegate <NSObject>

@optional
- (void)magicCalendarCellSingleTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date;
- (void)magicCalendarCellDoubleTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date;
- (void)magicCalendarCellLongPressTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date;

@end
