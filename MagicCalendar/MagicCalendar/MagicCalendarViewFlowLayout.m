//
//  CalendarViewFlowLayout.m
//  Calendar
//
//  Created by yamamoto on 2014/03/28.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import "MagicCalendarViewFlowLayout.h"

@implementation MagicCalendarViewFlowLayout
- (id)init
{
    self = [super init];
    if (self) {
        self.minimumInteritemSpacing = 0.0;
        self.minimumLineSpacing = 0.0;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
    
    return self;
}
@end
