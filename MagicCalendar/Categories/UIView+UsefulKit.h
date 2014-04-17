//
//  UIView+UsefulKit.h
//  UsefulKit
//
//  Created by yamamoto on 2014/03/17.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UsefulKit)
@property (assign, nonatomic) CGSize size, boundsSize;
@property (assign, nonatomic) CGPoint origin, boundsOrigin;

@property (assign, nonatomic) CGFloat x, y, width, height;
@property (assign, readonly, nonatomic) CGFloat boundsX, boundsY, boundsWidth, boundsHeight;

@property (assign, nonatomic) CGFloat left, top, right, bottom;
@property (assign, readonly, nonatomic) CGFloat boundsLeft, boundsTop, boundsRight, boundsBottom;

@end
