//
//  UIView+UsefulKit.m
//  UsefulKit
//
//  Created by yamamoto on 2014/03/17.
//  Copyright (c) 2014年 G.Yamamoto. All rights reserved.
//

#import "UIView+UsefulKit.h"

@implementation UIView (UsefulKit)
- (void)setSize:(CGSize)size
{
    CGRect f = self.frame;
    f.size = size;
    self.frame = f;
}
- (void)setBoundsSize:(CGSize)boundsSize
{
    CGRect f = self.bounds;
    f.size = boundsSize;
    self.bounds = f;
}
- (CGSize)size
{
    return self.frame.size;
}
- (CGSize)boundsSize
{
    return self.bounds.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect f = self.frame;
    f.origin = origin;
    self.frame = f;
}
- (void)setBoundsOrigin:(CGPoint)boundsOrigin
{
    CGRect f = self.bounds;
    f.origin = boundsOrigin;
    self.bounds = f;
}

- (CGPoint)origin
{
    return self.frame.origin;
}
- (CGPoint)boundsOrigin
{
    return self.bounds.origin;
}

- (void)setX:(CGFloat)x
{
    self.origin = (CGPoint){x, self.y};
}
- (void)setY:(CGFloat)y
{
    self.origin = (CGPoint){self.x, y};
}
- (void)setWidth:(CGFloat)width
{
    self.size = (CGSize){width, self.height};
}
- (void)setHeight:(CGFloat)height
{
    self.size = (CGSize){self.width, height};
}
- (void)setLeft:(CGFloat)left
{
    self.x = left;
}
- (void)setRight:(CGFloat)right
{
    self.x = right - self.width;
}
- (void)setTop:(CGFloat)top
{
    self.y = top;
}
- (void)setBottom:(CGFloat)bottom
{
    self.y = bottom - self.height;
}
- (CGFloat)x
{
    return self.frame.origin.x;
}
- (CGFloat)y
{
    return self.frame.origin.y;
}
- (CGFloat)width
{
    return self.frame.size.width;
}
- (CGFloat)height
{
    return self.frame.size.height;
}
- (CGFloat)left
{
    return self.x;
}
- (CGFloat)right
{
    return self.x + self.width;
}
- (CGFloat)top
{
    return self.y;
}
- (CGFloat)bottom
{
    return self.y + self.height;
}

- (CGFloat)boundsX
{
    return self.bounds.origin.x;
}
- (CGFloat)boundsY
{
    return self.bounds.origin.y;
}
- (CGFloat)boundsWidth
{
    return self.bounds.size.width;
}
- (CGFloat)boundsHeight
{
    return self.bounds.size.height;
}

- (CGFloat)boundsLeft
{
    return self.boundsX;
}
- (CGFloat)boundsRight
{
    return self.boundsX + self.boundsWidth;
}
- (CGFloat)boundsTop
{
    return self.boundsY;
}
- (CGFloat)boundsBottom
{
    return self.boundsY + self.boundsHeight;
}

@end
