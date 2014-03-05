//
//  LMMediaPlayerView.h
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/10.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMMediaPlayer.h"

extern NSString *LMMediaPlayerViewPlayButtonImageKey;
extern NSString *LMMediaPlayerViewPlayButtonSelectedImageKey;
extern NSString *LMMediaPlayerViewStopButtonImageKey;
extern NSString *LMMediaPlayerViewStopButtonSelectedImageKey;
extern NSString *LMMediaPlayerViewFullscreenButtonImageKey;
extern NSString *LMMediaPlayerViewFullscreenButtonSelectedImageKey;
extern NSString *LMMediaPlayerViewUnfullscreenButtonImageKey;
extern NSString *LMMediaPlayerViewUnfullscreenButtonSelectedImageKey;
extern NSString *LMMediaPlayerViewShuffleButtonShuffledImageKey;
extern NSString *LMMediaPlayerViewShuffleButtonShuffledSelectedImageKey;
extern NSString *LMMediaPlayerViewShuffleButtonUnshuffledImageKey;
extern NSString *LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatOneImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatOneSelectedImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatAllImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatAllSelectedImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatNoneImageKey;
extern NSString *LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey;

@class LMPlayerLayerView;
@class LMMediaPlayerView;

@protocol LMMediaPlayerViewDelegate <NSObject>

@required
- (BOOL)mediaPlayerViewWillStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media;

@optional
- (void)mediaPlayerViewWillChangeState:(LMMediaPlayerView *)playerView state:(LMMediaPlaybackState)state;
- (void)mediaPlayerViewDidStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media;
- (void)mediaPlayerViewDidFinishPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media;
- (void)mediaPlayerViewDidChangeRepeatMode:(LMMediaRepeatMode)mode playerView:(LMMediaPlayerView *)playerView;
- (void)mediaPlayerViewDidChangeShuffleMode:(BOOL)enabled playerView:(LMMediaPlayerView *)playerView;

@end

@interface LMMediaPlayerView : UIView <LMMediaPlayerDelegate>

@property (nonatomic, assign) id<LMMediaPlayerViewDelegate> delegate;
@property (nonatomic, readonly) LMMediaPlayer *mediaPlayer;
@property (nonatomic, readwrite) IBOutlet UISlider *currentTimeSlider;

+ (id)sharedPlayerView;
+ (id)create;
- (void)setUserInterfaceHidden:(BOOL)hidden;
- (void)setHeaderViewHidden:(BOOL)hidden;
- (void)setFooterViewHidden:(BOOL)hidden;
- (void)setButtonImages:(NSDictionary *)info;

@end
