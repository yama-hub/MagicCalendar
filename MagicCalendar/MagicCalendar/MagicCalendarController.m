//
//  CalendarController.m
//  Calendar
//
//  Created by yamamoto on 2014/03/27.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import "MagicCalendarController.h"
#import "MagicCalendarCollectionCell.h"
#import "MagicCalendarViewFlowLayout.h"
#import <EventKit/EventKit.h>

#define Format(fmt,...) [NSString stringWithFormat:fmt, ##__VA_ARGS__]

typedef struct {
    NSUInteger start;
    NSUInteger end;
} MagicCalendarMonthRange;

const NSString *weekdaylist[7] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"};
static NSString *CalendarCollectionCellIdentifier = @"calendar.collection.cell.identifier";

@interface MagicCalendarController () <MagicCalendarCollectionCellDelegate>
@property (strong, nonatomic) NSCalendar *calendar;
@property (assign, nonatomic) NSUInteger daysPerWeek, daysLineNumber;
@property (assign, nonatomic) CGFloat itemWidth;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *today;
@property (strong, nonatomic) UIView *scheduleBackgroundView;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UITableView *scheduleTableView;

@property (strong, nonatomic) NSArray *schedules;
@property (strong, nonatomic) NSDate *selectedDate;
@end

@implementation MagicCalendarController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super initWithCollectionViewLayout:[MagicCalendarViewFlowLayout new]];
    if (self) {
        // Custom initialization
        [self initSetup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super initWithCollectionViewLayout:[MagicCalendarViewFlowLayout new]];
    if (self) {
        // Custom initialization
        [self initSetup];
    }
    
    return self;
}

- (void)initSetup
{
    self.today = [NSDate mkToday:false];
    self.displayYear = self.today.year;
    self.startWeekday = 1;
    self.calendar = [NSCalendar currentCalendar];
    self.daysPerWeek = 7;
    self.daysLineNumber = 6;
    
    MagicCalendarMonthRange range = [self setupStartDate:[NSIndexPath indexPathForItem:0 inSection:self.today.month-1]];
    self.selectedIndexPath = [NSIndexPath indexPathForItem:range.start + self.today.day - 2 inSection:self.today.month-1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.y = 0;
    self.view.height+= 20;
    
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.itemWidth = floorf(CGRectGetWidth(self.collectionView.bounds) / self.daysPerWeek);    
    
    self.headerLabel = [[UILabel alloc] initWithFrame:(CGRect){0, -20, self.view.boundsWidth, 20}];
    self.headerLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.headerLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:13];
    self.headerLabel.alpha = .0;
    [self.view addSubview:self.headerLabel];
    
    [self reloadWeekday:self.startWeekday];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = true;
    self.collectionView.y = 36;
    self.collectionView.height = self.itemWidth * self.daysLineNumber;
    [self.collectionView registerClass:[MagicCalendarCollectionCell class] forCellWithReuseIdentifier:CalendarCollectionCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = false;

    if (self.selectedDate) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.selectedDate.month-1]
                                    atScrollPosition:UICollectionViewScrollPositionTop animated:false];
    }
    
    self.scheduleBackgroundView = [[UIView alloc] initWithFrame:(CGRect){0, self.collectionView.bottom, self.view.boundsWidth, self.view.boundsHeight-self.collectionView.height}];
    self.scheduleBackgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scheduleBackgroundView];
    
    self.scheduleTableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0, self.scheduleBackgroundView.width, self.scheduleBackgroundView.height} style:UITableViewStylePlain];
    self.scheduleTableView.delegate = self;
    self.scheduleTableView.dataSource = self;
    self.scheduleTableView.backgroundColor = [UIColor clearColor];
    self.scheduleTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scheduleBackgroundView addSubview:self.scheduleTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showHeaderLabel:abs(self.collectionView.contentOffset.y/self.collectionView.height)+1];
}


#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.daysPerWeek * self.daysLineNumber;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //one year
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MagicCalendarCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CalendarCollectionCellIdentifier
                                                                                     forIndexPath:indexPath];
    cell.delegate = self;
    
    MagicCalendarMonthRange range = [self setupStartDate:indexPath];
    if (indexPath.item + 1 >= range.start && indexPath.item + 1 < range.end) {
        NSInteger day = indexPath.item - range.start+1+1;
        NSDate *date = [NSDate dateWithYear:self.displayYear month:indexPath.section+1 day:day];
        [cell setDate:date today:self.today];
        
        if (!cell.isToday) {
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(magicCalendarControllerIsHoliday:date:)]) {
                if ([self.dataSource magicCalendarControllerIsHoliday:self date:cell.date]) {
                    cell.isSunday = true;
                }
            }
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(magicCalendarControllerIsSchedule:date:)]) {
            cell.isSchedule = [self.dataSource magicCalendarControllerIsSchedule:self date:cell.date];
        }
        
        if (self.selectedDate && [self.selectedDate isEqualToDate:date]) {
            [self selectedCalenderCell:cell indexPath:indexPath date:date];
        }
        if (self.selectedDate.month != date.month && date.day == 1) {
            [self selectedCalenderCell:cell indexPath:indexPath date:date];
        }
    } else {
        [cell setDate:nil today:nil];
    }
    
    return cell;
}

#pragma mark - collection view delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.itemWidth, self.itemWidth);
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) return;
    self.scheduleTableView.alpha = .0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([scrollView isKindOfClass:[UITableView class]]) return;
    
	if (scrollView.contentOffset.y < -40) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:decrementYear:)]) {
            [UIView animateWithDuration:.3 animations:^{
                self.view.y = self.collectionView.bottom;
                self.view.alpha = .0;
            } completion:^(BOOL finished) {
                [self.delegate magicCalendarController:self decrementYear:self.displayYear];
            }];
        }
    }
    if (scrollView.contentOffset.y > self.collectionView.contentSize.height-self.collectionView.height+50) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:incrementYear:)]) {
            [UIView animateWithDuration:.3 animations:^{
                self.view.y = -self.view.height;
                self.view.alpha = .0;
            } completion:^(BOOL finished) {
                [self.delegate magicCalendarController:self incrementYear:self.displayYear];
            }];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]) return;
    NSInteger month = abs(scrollView.contentOffset.y/self.collectionView.height)+1;
    [self showHeaderLabel:month];
    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:changeMonth:)]) {
        [self.delegate magicCalendarController:self changeMonth:month];
    }
    //画面サイズを調整
    [UIView animateWithDuration:.3 animations:^{
        MagicCalendarMonthRange range = [self setupStartDate:[self.collectionView indexPathForItemAtPoint:scrollView.contentOffset]];
        self.scheduleBackgroundView.y = fabs(range.end/self.daysLineNumber) * self.itemWidth +  self.collectionView.y;
        self.scheduleBackgroundView.height = self.view.boundsHeight - self.scheduleBackgroundView.y;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            self.scheduleTableView.alpha = 1.0;
        }];
    }];
}

#pragma mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.schedules.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"Noteworthy-Light" size:13.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:11.0];
    }
    
    EKEvent *event = self.schedules[indexPath.row];
    cell.textLabel.text = event.title?:@"No title";
    cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    if (event.isAllDay) {
        cell.detailTextLabel.text = @"Allday";
    } else if ([event.startDate isSameYearAsDate:event.endDate] && [event.startDate isSameMonthAsDate:event.endDate] && event.startDate.day == event.endDate.day) {
        cell.detailTextLabel.text = Format(@"%02ld:%02ld 〜 %02ld:%02ld", (long)event.startDate.hour, (long)event.startDate.minute, (long)event.endDate.hour, (long)event.endDate.minute);
    } else {
        cell.detailTextLabel.text = Format(@"%02ld:%02ld 〜 %ld.%02ld.%02ld %02ld0%02ld",
                                           (long)event.startDate.hour, (long)event.startDate.minute,
                                           (long)event.endDate.year, (long)event.endDate.month, (long)event.endDate.day, (long)event.endDate.hour, (long)event.endDate.minute);
    }
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:selectedEvent:)]) {
        [self.delegate magicCalendarController:self selectedEvent:self.schedules[indexPath.row]];
    }
}

#pragma mark - cell delegate
- (void)magicCalendarCellSingleTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self selectedCalenderCell:cell indexPath:indexPath date:date];
}
- (void)magicCalendarCellDoubleTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:newEvent:)]) {
        [self.delegate magicCalendarController:self newEvent:date];
    }
}
- (void)magicCalendarCellLongPressTapped:(MagicCalendarCollectionCell *)cell date:(NSDate *)date
{
    NSLog(@"long pressed !! %@", [date formatString]);
}

#pragma mark - public Methods
- (void)scrollToMonth:(NSInteger)month animated:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:month-1]
                                atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    self.scheduleTableView.alpha = 1.0;
}

- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
    if (selectedDate.month != self.selectedDate.month) {
        self.selectedDate = selectedDate;
        [self scrollToMonth:self.selectedDate.month animated:true];
    } else {
        MagicCalendarMonthRange range = [self setupStartDate:[NSIndexPath indexPathForItem:0 inSection:selectedDate.month-1]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:range.start + selectedDate.day - 2 inSection:selectedDate.month-1];
        MagicCalendarCollectionCell *cell = (MagicCalendarCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self magicCalendarCellSingleTapped:cell date:selectedDate];
    }
    [self showHeaderLabel:selectedDate.month];
}
- (void)reloadWeekday:(NSInteger)weekday
{
    self.startWeekday = weekday;
    NSMutableArray *weekdays = [NSMutableArray array];
    for (NSInteger i = self.startWeekday; i < 7; i++) [weekdays addObject:weekdaylist[i]];
    for (NSInteger i = 0; i < self.startWeekday; i++) [weekdays addObject:weekdaylist[i]];
    
    for (NSInteger i = 0; i < 7; i++) [[self.view viewWithTag:1000+i] removeFromSuperview];
    for (NSInteger i = 0; i < 7; i++) {
        UILabel *lb = [[UILabel alloc] initWithFrame:(CGRect){i*self.itemWidth, 16, self.itemWidth, 20}];
        lb.backgroundColor = [UIColor clearColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.font = [UIFont fontWithName:@"Noteworthy-Light" size:15];
        lb.text = weekdays[i];
        lb.tag = 1000+i;
        [self.view addSubview:lb];
    }
}
#pragma mark - private Methods
- (void)selectedCalenderCell:(MagicCalendarCollectionCell *)cell indexPath:(NSIndexPath *)indexPath date:(NSDate *)date
{
    if (self.selectedIndexPath) {
        MagicCalendarCollectionCell *_cell = (MagicCalendarCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        _cell.isSelected = false;
        [_cell setupColor:self.today];
        if (!_cell.isToday) {
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(magicCalendarControllerIsHoliday:date:)]) {
                if ([self.dataSource magicCalendarControllerIsHoliday:self date:_cell.date]) {
                    _cell.isSunday = true;
                }
            }
        }
    }
    self.selectedDate = date;
    self.selectedIndexPath = indexPath;
    cell.isSelected = true;
    if (self.scheduleTableView.alpha == .0) {
        self.scheduleTableView.alpha = 1.0;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCalendarController:selectedDay:)]) {
        self.schedules = [self.delegate magicCalendarController:self selectedDay:cell.date];
        [self.scheduleTableView reloadData];
    }
}
- (MagicCalendarMonthRange)setupStartDate:(NSIndexPath *)indexPath
{
    NSDate *date = [NSDate dateWithYear:self.displayYear month:indexPath.section+1 day:1];
    //曜日を取得し前月分の書き出し数をだす
    NSInteger prevDays = [date weekday]-self.startWeekday;
    if (prevDays <= 0) prevDays += 7;
    
    NSRange range = [self.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return (MagicCalendarMonthRange){prevDays, range.length+prevDays};
}

- (void)showHeaderLabel:(NSInteger)month
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.view bringSubviewToFront:self.headerLabel];
    [UIView animateWithDuration:.3 animations:^{
        self.headerLabel.text = [NSString stringWithFormat:@"  %lu.%02ld", (unsigned long)self.displayYear, (long)month];
        self.headerLabel.alpha = 1.0;
        self.headerLabel.y = 20;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideHeaderLabel) withObject:nil afterDelay:2];
    }];
}
- (void)hideHeaderLabel
{
    [UIView animateWithDuration:.3 animations:^{
        self.headerLabel.alpha = .0;
        self.headerLabel.y = -20;
    }];
}

#pragma mark - setter
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;
}

@end
