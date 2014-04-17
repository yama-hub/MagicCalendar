//
//  CalendarCollectionCell.m
//  Calendar
//
//  Created by yamamoto on 2014/03/27.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import "MagicCalendarCollectionCell.h"
#import "NSDate+UsefulKit.h"

@interface MagicCalendarCollectionCell()
@property (strong, nonatomic) NSDate *date;
@end

@implementation MagicCalendarCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _date = nil;
        _isToday = NO;
        
        CGFloat circleSize = 30.0;
        self.dayLabel = [[UILabel alloc] init];
        self.dayLabel.font = [UIFont fontWithName:@"Noteworthy-Light" size:15];
        self.dayLabel.textAlignment = NSTextAlignmentCenter;
        self.dayLabel.backgroundColor = self.circleDefaultColor;
        self.dayLabel.layer.cornerRadius = circleSize/2;
        self.dayLabel.layer.masksToBounds = YES;
        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:self.dayLabel];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:circleSize]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dayLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:circleSize]];
        
        //schelde
        circleSize = 6.0;
        self.scheduleLabel = [[UILabel alloc] init];
        self.scheduleLabel.backgroundColor = [UIColor clearColor];
        self.scheduleLabel.layer.cornerRadius = circleSize/2;
        self.scheduleLabel.layer.masksToBounds = YES;
        self.scheduleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:self.scheduleLabel];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scheduleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scheduleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scheduleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:circleSize]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.scheduleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:circleSize]];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self.contentView addGestureRecognizer:singleTap];
        [self.contentView addGestureRecognizer:doubleTap];
        [self.contentView addGestureRecognizer:longPress];
    }
    return self;
}

#pragma mark - public Methods
- (void)setDate:(NSDate *)date today:(NSDate *)today
{
    self.date = date;
    if (!date) {
        self.isToday = false;
        self.dayLabel.text = nil;
        self.isSchedule = false;
    } else {
        self.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)date.day];
        self.isToday = [date isEqualToDate:today];
        if (!self.isToday) self.isSaturday = date.weekday == 7;
        if (!self.isToday && !self.isSaturday) self.isSunday = date.weekday == 1;
    }
}
- (void)setupColor:(NSDate *)today
{
    [self setDate:self.date today:today];
}
- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected) {
        self.dayLabel.backgroundColor = self.circleSelectedColor;
        self.dayLabel.textColor = self.textSelectedColor;
    } else {
        self.dayLabel.backgroundColor = self.circleDefaultColor;
        self.dayLabel.textColor = self.textDefaultColor;
    }
}
- (void)setIsToday:(BOOL)isToday
{
    if (isToday) {
        self.dayLabel.backgroundColor = self.circleTodayColor;
        self.dayLabel.textColor = self.textTodayColor;
    } else {
        self.dayLabel.backgroundColor = self.circleDefaultColor;
        self.dayLabel.textColor = self.textDefaultColor;
    }
    _isToday = isToday;
}
- (void)setIsSaturday:(BOOL)isSaturday
{
    self.dayLabel.textColor = isSaturday ? self.textSaturdayColor: self.textDefaultColor;
    _isSaturday = isSaturday;
}
- (void)setIsSunday:(BOOL)isSunday
{
    self.dayLabel.textColor = isSunday ? self.textHolidayColor: self.textDefaultColor;
    _isSunday = isSunday;
}

- (void)setIsSchedule:(BOOL)isSchedule
{
    _isSchedule = isSchedule;
    if (isSchedule) {
        self.scheduleLabel.backgroundColor = self.eventMarkColor;
    } else {
        self.scheduleLabel.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - Circle Color Customization Methods

- (UIColor *)circleDefaultColor
{
    if(_circleDefaultColor == nil) {
        _circleDefaultColor = [[[self class] appearance] circleDefaultColor];
    }
    
    if(_circleDefaultColor != nil) {
        return _circleDefaultColor;
    }
    
    return [UIColor clearColor];
}

- (UIColor *)circleTodayColor
{
    if(_circleTodayColor == nil) {
        _circleTodayColor = [[[self class] appearance] circleTodayColor];
    }
    
    if(_circleTodayColor != nil) {
        return _circleTodayColor;
    }
    
    return [UIColor grayColor];
}

- (UIColor *)circleSelectedColor
{
    if(_circleSelectedColor == nil) {
        _circleSelectedColor = [[[self class] appearance] circleSelectedColor];
    }
    
    if(_circleSelectedColor != nil) {
        return _circleSelectedColor;
    }
    
    return [UIColor redColor];
}

#pragma mark - Text Label Customizations Color

- (UIColor *)textDefaultColor
{
    if(_textDefaultColor == nil) {
        _textDefaultColor = [[[self class] appearance] textDefaultColor];
    }
    
    if(_textDefaultColor != nil) {
        return _textDefaultColor;
    }
    
    return [UIColor blackColor];
}

- (UIColor *)textTodayColor
{
    if(_textTodayColor == nil) {
        _textTodayColor = [[[self class] appearance] textTodayColor];
    }
    
    if(_textTodayColor != nil) {
        return _textTodayColor;
    }
    
    return [UIColor whiteColor];
}

- (UIColor *)textSaturdayColor
{
    if(_textSaturdayColor == nil) {
        _textSaturdayColor = [[[self class] appearance] textSaturdayColor];
    }
    
    if(_textSaturdayColor != nil) {
        return _textSaturdayColor;
    }
    
    return [UIColor blueColor];
}

- (UIColor *)textHolidayColor
{
    if(_textHolidayColor == nil) {
        _textHolidayColor = [[[self class] appearance] textHolidayColor];
    }
    
    if(_textHolidayColor != nil) {
        return _textHolidayColor;
    }
    
    return [UIColor redColor];
}

- (UIColor *)textSelectedColor
{
    if(_textSelectedColor == nil) {
        _textSelectedColor = [[[self class] appearance] textSelectedColor];
    }
    
    if(_textSelectedColor != nil) {
        return _textSelectedColor;
    }
    
    return [UIColor whiteColor];
}

- (UIColor *)eventMarkColor
{
    if(_eventMarkColor == nil) {
        _eventMarkColor = [[[self class] appearance] eventMarkColor];
    }
    
    if(_eventMarkColor != nil) {
        return _eventMarkColor;
    }
    
    return [UIColor colorWithRed:1 green:0.765 blue:0.824 alpha:1.0];
}

#pragma mark - private Methods
- (void)singleTapped:(UIGestureRecognizer *)sender
{
    if (self.date && self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarCellSingleTapped:date:)]) {
        [self.delegate magicCalendarCellSingleTapped:self date:self.date];
    }
}
- (void)doubleTapped:(UIGestureRecognizer *)sender
{
    if (self.date && self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarCellDoubleTapped:date:)]) {
        [self.delegate magicCalendarCellDoubleTapped:self date:self.date];
    }
}
- (void)longPressed:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.date && self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarCellLongPressTapped:date:)]) {
            [self.delegate magicCalendarCellLongPressTapped:self date:self.date];
        }
    }
}

@end
