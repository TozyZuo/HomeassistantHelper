//
//  NSView+Extensions.m
//
//  Created by Elmar Tampe && Kristijan Šimić on 28.04.13.
//  Copyright (c) 2013 Elmar Tampe. All rights reserved.
//

#import "NSView+Extensions.h"

BOOL flipped = YES;

@implementation NSView (Extensions)

// ------------------------------------------------------------------------------------------
#pragma mark - Left
// ------------------------------------------------------------------------------------------
- (CGFloat)left
{
	return self.frame.origin.x;	
}


- (void)setLeft:(CGFloat)left
{
	NSRect rect = self.frame;
	rect.origin.x = left;
	self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Right
// ------------------------------------------------------------------------------------------
- (CGFloat)right
{
	return self.frame.origin.x + self.frame.size.width;	
}


- (void)setRight:(CGFloat)right
{
	NSRect rect = self.frame;
	rect.origin.x = right - rect.size.width;
	self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Top
// ------------------------------------------------------------------------------------------
- (CGFloat)top
{
    if (flipped) {
        return self.frame.origin.y;
    } else {
        return self.frame.origin.y + self.frame.size.height;
    }
}


- (void)setTop:(CGFloat)top
{
	NSRect rect = self.frame;
    if (flipped) {
        rect.origin.y = top;
    } else {
        rect.origin.y = top - rect.size.height;
    }
	self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Bottom
// ------------------------------------------------------------------------------------------
- (CGFloat)bottom
{
    if (flipped) {
        return self.frame.origin.y + self.frame.size.height;
    } else {
        return self.frame.origin.y;
    }
}


- (void)setBottom:(CGFloat)bottom
{
	NSRect rect = self.frame;
    if (flipped) {
        rect.origin.y = bottom - rect.size.height;
    } else {
        rect.origin.y = bottom;
    }
	self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Width
// ------------------------------------------------------------------------------------------
- (CGFloat)width
{
    return self.frame.size.width;
}


- (void)setWidth:(CGFloat)width
{
    NSRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Height
// ------------------------------------------------------------------------------------------
- (CGFloat)height
{
    return self.frame.size.height;
}


- (void)setHeight:(CGFloat)height
{
    NSRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Origin
// ------------------------------------------------------------------------------------------
- (CGPoint)origin
{
    return self.frame.origin;
}


- (void)setOrigin:(CGPoint)origin
{
    NSRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Center
// ------------------------------------------------------------------------------------------
- (CGSize)size
{
    return self.frame.size;
}


- (void)setSize:(CGSize)size
{
    NSRect rect = self.frame;
    rect.size = size;
    self.frame = rect;
}


// ------------------------------------------------------------------------------------------
#pragma mark - Center
// ------------------------------------------------------------------------------------------
- (NSPoint)center
{
    return CGPointMake(self.centerX, self.centerY);
}


- (void)setCenter:(CGPoint)center
{
    CGFloat originX = center.x - (self.frame.size.width * .5);
	CGFloat originY = center.y - (self.frame.size.height * .5);
	
	self.frame = NSMakeRect(originX, originY, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)centerX
{
    return self.frame.origin.x + (self.frame.size.width * .5);
}

- (void)setCenterX:(CGFloat)centerX
{
    self.center = NSMakePoint(centerX, self.centerY);
}

- (CGFloat)centerY
{
    return self.frame.origin.y + (self.frame.size.height * .5);
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = NSMakePoint(self.centerX, centerY);
}


// ------------------------------------------------------------------------------------------
#pragma mark - Corner Coordinate
// ------------------------------------------------------------------------------------------
- (NSPoint)cornerCoordinateForType:(NSViewCornerCoordinateType)cornerType
{
    switch (cornerType)
    {
        case NSViewCornerCoordinateTypeTopLeft:
        {
            return NSMakePoint(self.bounds.origin.x, self.bounds.size.height);
        }
        case NSViewCornerCoordinateTypeTopRight:
        {
            return NSMakePoint(self.bounds.size.width, self.bounds.size.height);
        }
        case NSViewCornerCoordinateTypeBottomLeft:
        {
            return NSMakePoint(self.bounds.origin.x, self.bounds.origin.y);
        }
        case NSViewCornerCoordinateTypeBottomRight:
        {
            return NSMakePoint(self.bounds.size.width, self.bounds.origin.y);
        }
        default:
		{
			return NSZeroPoint;
		}
    }
}


@end
