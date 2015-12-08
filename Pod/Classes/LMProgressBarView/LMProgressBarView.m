//
//  TYMProgressBarView.m
//  TYMProgressBarView
//
//  Created by Yiming Tang on 6/7/13.
//  Copyright (c) 2013 - 2015 Yiming Tang. All rights reserved.
//

#import "LMProgressBarView.h"

void strokeRectInContext(CGContextRef context, CGRect rect, CGFloat lineWidth, CGFloat radius);
void fillRectInContext(CGContextRef context, CGRect rect, CGFloat radius);
void setRectPathInContext(CGContextRef context, CGRect rect, CGFloat radius);


@implementation LMProgressBarView

#pragma mark - Accessors

@synthesize progress = _progress;
@synthesize barBorderWidth = _barBorderWidth;
@synthesize barBorderColor = _barBorderColor;
@synthesize barInnerBorderWidth = _barInnerBorderWidth;
@synthesize barInnerBorderColor = _barInnerBorderColor;
@synthesize barInnerPadding = _barInnerPadding;
@synthesize barFillColor = _barFillColor;
@synthesize barBackgroundColor = _barBackgroundColor;
@synthesize usesRoundedCorners = _usesRoundedCorners;


- (void)setProgress:(CGFloat)newProgress {
    _progress = fmaxf(0.0, fminf(1.0, newProgress));
    [self setNeedsDisplay];
}

- (void)setCurrentProgress:(CGFloat)newProgress {
    _currentProgress = fmaxf(0.0, fminf(1.0, newProgress));
    [self setNeedsDisplay];
}

- (void)setBarBorderWidth:(CGFloat)barBorderWidth {
    _barBorderWidth = barBorderWidth;
    [self setNeedsDisplay];
}



- (void)setBarBorderColor:(UIColor *)barBorderColor {
    _barBorderColor = barBorderColor;
    [self setNeedsDisplay];
}


- (void)setBarInnerBorderWidth:(CGFloat)barInnerBorderWidth {
    _barInnerBorderWidth = barInnerBorderWidth;
    [self setNeedsDisplay];
}


- (void)setBarInnerBorderColor:(UIColor *)barInnerBorderColor {
    _barInnerBorderColor = barInnerBorderColor;
    [self setNeedsDisplay];
}


- (void)setBarInnerPadding:(CGFloat)barInnerPadding {
    _barInnerPadding = barInnerPadding;
    [self setNeedsDisplay];
}


- (void)setBarFillColor:(UIColor *)barFillColor {
    _barFillColor = barFillColor;
    [self setNeedsDisplay];
}

- (void)setBarMinimumTrackFillColor:(UIColor *)barMinimumTrackFillColor {
    _barMinimumTrackFillColor = barMinimumTrackFillColor;
    [self setNeedsDisplay];
}

- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor {
    _barBackgroundColor = barBackgroundColor;
    [self setNeedsDisplay];
}


- (void)setUsesRoundedCorners:(NSInteger)usesRoundedCorners {
    _usesRoundedCorners = usesRoundedCorners;
    [self setNeedsDisplay];
}


#pragma mark - Class Methods

+ (UIColor *)defaultBarColor {
    return [UIColor darkGrayColor];
}


+ (void)initialize {
    if (self == [LMProgressBarView class]) {
        LMProgressBarView *appearance = [LMProgressBarView appearance];
        [appearance setUsesRoundedCorners:YES];
        [appearance setProgress:0];
        [appearance setBarBorderWidth:2.0];
        [appearance setBarBorderColor:[self defaultBarColor]];
        [appearance setBarInnerBorderWidth:0];
        [appearance setBarInnerBorderColor:nil];
        [appearance setBarInnerPadding:2.0];
        [appearance setBarFillColor:[self defaultBarColor]];
        [appearance setBarBackgroundColor:[UIColor whiteColor]];
        [appearance setBarMinimumTrackFillColor:[UIColor whiteColor]];
    }
}



#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        [self initialize];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, TRUE);
    
    CGRect currentRect = rect;
    CGFloat radius = 0;
    CGFloat halfLineWidth = 0;
    
    // Background
    if (self.backgroundColor) {
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        [self.barBackgroundColor setFill];
        fillRectInContext(context, currentRect, radius);
    }
    
    // Border
    if (self.barBorderColor && self.barBorderWidth > 0.0) {
        // Inset, because a stroke is centered on the path
        // See http://stackoverflow.com/questions/10557157/drawing-rounded-rect-in-core-graphics
        halfLineWidth = self.barBorderWidth / 2.0;
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        [self.barBorderColor setStroke];
        strokeRectInContext(context, currentRect, self.barBorderWidth, radius);
        
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
    }
    
    // Padding
    currentRect = CGRectInset(currentRect, self.barInnerPadding, self.barInnerPadding);
    
    BOOL hasInnerBorder = NO;
    // Inner border
    if (self.barInnerBorderColor && self.barInnerBorderWidth > 0.0) {
        hasInnerBorder = YES;
        halfLineWidth = self.barInnerBorderWidth / 2.0;
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        // progress
        currentRect.size.width *= self.progress;
        currentRect.size.width = fmaxf(currentRect.size.width, 2 * radius);
        
        [self.barInnerBorderColor setStroke];
        strokeRectInContext(context, currentRect, self.barInnerBorderWidth, radius);
        
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
    }
    
    // Fill
    if (self.barFillColor) {
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2;
        
        // recalculate width
        if (!hasInnerBorder) {
            currentRect.size.width *= self.progress;
            currentRect.size.width = fmaxf(currentRect.size.width, 2 * radius);
        }
        
        [self.barFillColor setFill];
        fillRectInContext(context, currentRect, radius);
    }
    
    if (self.barMinimumTrackFillColor) {
        
        CGRect progressFillRect = currentRect;
        progressFillRect.size.width = CGRectInset(rect, self.barInnerPadding, self.barInnerPadding).size.width;
        progressFillRect.size.width = CGRectInset(progressFillRect, halfLineWidth, halfLineWidth).size.width;
        progressFillRect.size.width = CGRectInset(progressFillRect, halfLineWidth, halfLineWidth).size.width;
        
        if (self.usesRoundedCorners) radius = progressFillRect.size.height / 2;
        
        progressFillRect.size.width *= self.currentProgress;
        progressFillRect.size.width = fmaxf(progressFillRect.size.width, 2 * radius);
        
        [self.barMinimumTrackFillColor setFill];
        fillRectInContext(context, progressFillRect, radius);
    }
    
    // Restore the context
    CGContextRestoreGState(context);
}


#pragma mark - Private

- (void)initialize {
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}

@end

#pragma mark - Drawing Functions

void strokeRectInContext(CGContextRef context, CGRect rect, CGFloat lineWidth, CGFloat radius) {
    CGContextSetLineWidth(context, lineWidth);
    setRectPathInContext(context, rect, radius);
    CGContextStrokePath(context);
}


void fillRectInContext(CGContextRef context, CGRect rect, CGFloat radius) {
    setRectPathInContext(context, rect, radius);
    CGContextFillPath(context);
}


void setRectPathInContext(CGContextRef context, CGRect rect, CGFloat radius) {
    CGContextBeginPath(context);
    if (radius > 0.0) {
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    } else {
        CGContextAddRect(context, rect);
    }
    CGContextClosePath(context);
}
