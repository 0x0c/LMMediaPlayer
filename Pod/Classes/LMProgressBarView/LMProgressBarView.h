//
//  TYMProgressBarView.h
//  TYMProgressBarView
//
//  Created by Yiming Tang on 6/7/13.
//  Copyright (c) 2013 - 2015 Yiming Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Class name is renamed to avoid conflicts e.g someone is using any other version of the same class
 */

/**
 Progress bar similar to the one in iOS's launching screen.
 */
@interface LMProgressBarView : UIView


///---------------------------
///@name Managing the Progress
///---------------------------

/**
 The current progress shown by the receiver.
 
 The current progress is represented by a floating-point value between `0.0` and `1.0`, inclusive, where `1.0` indicates
 the completion of the task. Values less than `0.0` and greater than `1.0` are pinned to those limits.
 
 The default value is `0.0`.
 */
@property (nonatomic) CGFloat progress;

@property (nonatomic) CGFloat currentProgress;


///-------------------------------------
/// @name Configuring the Appearance
///-------------------------------------

/**
 The outer border width.
 
 The default is `2.0`.
 */
@property (nonatomic) CGFloat barBorderWidth UI_APPEARANCE_SELECTOR;

/**
 The outer border color.
 
 @see defaultBarColor
 */
@property (nonatomic, strong) UIColor *barBorderColor UI_APPEARANCE_SELECTOR;

/**
 The inner border width.
 
 The default is `0.0`.
 */
@property (nonatomic) CGFloat barInnerBorderWidth UI_APPEARANCE_SELECTOR;

/**
 The inner border color.
 
 The default is nil.
 */
@property (nonatomic, strong) UIColor *barInnerBorderColor UI_APPEARANCE_SELECTOR;

/**
 The inner padding.
 
 The default is `2.0`.
 */
@property (nonatomic) CGFloat barInnerPadding UI_APPEARANCE_SELECTOR;

/**
 The fill color.
 
 @see defaultBarColor
 */
@property (nonatomic, strong) UIColor *barFillColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *barMinimumTrackFillColor UI_APPEARANCE_SELECTOR;
/**
 The bar background color.
 
 The default is white.
 */
@property (nonatomic, strong) UIColor *barBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 It determines whether use rounded corners.
 
 The default is `YES`.
 
 @discussion We can't set `BOOL` type through the `UIAppearance` API, so we use `NSInteger` instead.
 */
@property (nonatomic) NSInteger usesRoundedCorners UI_APPEARANCE_SELECTOR;


///---------------
/// @name Defaults
///---------------

/**
 The default value of `barBorderColor` and `barFillColor`.
 */
+ (UIColor *)defaultBarColor;

@end
