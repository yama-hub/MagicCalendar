//
//  ViewController.m
//  MagicCalendar
//
//  Created by yamamoto on 2014/04/08.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import "ViewController.h"
#import "MagicCalendarController.h"
#import "MagicCalendarCollectionCell.h"
#import <EventKit/EventKit.h>

@interface ViewController () <MagicCalendarControllerDelegate, MagicCalendarCollectionCellDataSource>
@property (strong, nonatomic) MagicCalendarController *calendarController;
@property (assign, nonatomic) NSInteger displayMonth;

@property (strong, nonatomic) EKEventStore *eventStore;
@property (assign, nonatomic) EKAuthorizationStatus status;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.eventStore = [EKEventStore new];
    self.calendarController = [MagicCalendarController new];
    self.calendarController.delegate = self;
    self.calendarController.dataSource = self;
    [self addChildViewController:self.calendarController];
    [self.view addSubview:self.calendarController.view];
    [self.calendarController setSelectedDate:[NSDate mkToday:false] animated:true];
    [self.calendarController didMoveToParentViewController:self];
    
    __weak typeof(self) wk_vc = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:EKEventStoreChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (wk_vc.calendarController) [wk_vc.calendarController.collectionView reloadData];
    }];
    
//    [MagicCalendarCollectionCell appearance].textDefaultColor = [UIColor greenColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (self.status == EKAuthorizationStatusNotDetermined) {
        __weak typeof(self) wk_vc = self;
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    wk_vc.eventStore = [EKEventStore new];
                    wk_vc.status = EKAuthorizationStatusAuthorized;
                    [wk_vc.calendarController setSelectedDate:[NSDate mkToday:false] animated:true];
                    [wk_vc.calendarController.collectionView reloadData];
                });
            }
        }];
    }
}


#pragma mark - calendar delegate
- (void)magicCalendarController:(MagicCalendarController *)controller newEvent:(NSDate *)date
{
    //Add New Event !!
}
- (NSArray *)magicCalendarController:(MagicCalendarController *)controller selectedDay:(NSDate *)date
{
    NSArray *array = [NSMutableArray array];
    if (self.status == EKAuthorizationStatusAuthorized) {
        NSDate *start = [date dateByAddingTimeInterval:-0.001];
        NSDate *end = [date dateByAddingTimeInterval:24*60*60];
        
        NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:start endDate:end calendars:nil];
        NSArray *events = [_eventStore eventsMatchingPredicate:predicate];
        array = [events sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    }
    
    return array;
}
- (void)magicCalendarController:(MagicCalendarController *)controller selectedEvent:(EKEvent *)event
{
    NSLog(@"selected EKEvent: %@", event);
}
- (void)magicCalendarController:(MagicCalendarController *)controller decrementYear:(NSInteger)decrementYear
{
    [self _newMagicCalendarControllerWithYear:--decrementYear month:12];
}

- (void)calendarController:(MagicCalendarController *)controller incrementYear:(NSInteger)incrementYear
{
    [self _newMagicCalendarControllerWithYear:++incrementYear month:1];
}
- (void)calendarController:(MagicCalendarController *)controller changeMonth:(NSInteger)month
{
    self.displayMonth = month;
}

#pragma mark - calendar datasource
- (BOOL)calendarControllerIsHoliday:(MagicCalendarController *)controller date:(NSDate *)date
{
    return false;
}
- (BOOL)MagicCalendarControllerIsSchedule:(MagicCalendarController *)controller date:(NSDate *)date
{
    BOOL isSchedule = false;
    
    return isSchedule;
}


#pragma mark - private Methods
- (void)_newMagicCalendarControllerWithYear:(NSInteger)year month:(NSInteger)month
{
    [self.calendarController.view removeFromSuperview];
    [self.calendarController removeFromParentViewController];
    self.calendarController = nil;
    
    self.calendarController = [MagicCalendarController new];
    [self addChildViewController:self.calendarController];
    self.calendarController.delegate = self;
    self.calendarController.dataSource = self;
    self.calendarController.displayYear = year;
    [self.view addSubview:self.calendarController.view];
    if (month == 1) {
        CGFloat y = self.calendarController.view.center.y;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        animation.values = @[@(y + self.calendarController.view.bounds.size.height), @(y - 20), @(y + 10), @(y)];
        animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = .6;
        [self.calendarController.view.layer addAnimation:animation forKey:@"dropup"];
    } else {
        CGFloat y = self.calendarController.view.center.y;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        animation.values = @[@(y - self.calendarController.view.bounds.size.height), @(y + 20), @(y - 10), @(y)];
        animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = .6;
        [self.calendarController.view.layer addAnimation:animation forKey:@"dropdown"];
    }
    
    [self.calendarController scrollToMonth:month animated:false];
    [self.calendarController didMoveToParentViewController:self];
    self.displayMonth = month;
}

@end
