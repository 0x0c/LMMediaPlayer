//
//  LMMediaPlayerView.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/10.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMMediaPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import "LMPlayerLayerView.h"

static const CGFloat kFullscreenTransitionDuration = 0.2;
static const NSString *kLMMediaPlayerPrefersStatusBarHidden = @"com.akira.matsuda.LMMediaPlayerPrefersStatusBarHidden";

NSString *LMMediaPlayerViewPlayButtonImageKey = @"playButtonImageKey";
NSString *LMMediaPlayerViewPlayButtonSelectedImageKey = @"playButtonSelectedImageKey";
NSString *LMMediaPlayerViewStopButtonImageKey = @"stopButtonImageKey";
NSString *LMMediaPlayerViewStopButtonSelectedImageKey = @"stopButtonSelectedImageKey";
NSString *LMMediaPlayerViewFullscreenButtonImageKey = @"fullscreenButtonImageKey";
NSString *LMMediaPlayerViewFullscreenButtonSelectedImageKey = @"fullscreenButtonSelectedImageKey";
NSString *LMMediaPlayerViewUnfullscreenButtonImageKey = @"unfullscreenButtonImageKey";
NSString *LMMediaPlayerViewUnfullscreenButtonSelectedImageKey = @"unfullscreenButtonSelectedImageKey";
NSString *LMMediaPlayerViewShuffleButtonShuffledImageKey = @"shuffleButtonShuffledImageKey";
NSString *LMMediaPlayerViewShuffleButtonShuffledSelectedImageKey = @"shuffleButtonShuffledSelectedImageKey";
NSString *LMMediaPlayerViewShuffleButtonUnshuffledImageKey = @"shuffleButtonUnshuffledImageKey";
NSString *LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey = @"shuffleButtonUnshuffledSelectedImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatOneImageKey = @"repeatButtonRepeatOneImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatOneSelectedImageKey = @"repeatButtonRepeatOneSelectedImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatAllImageKey = @"repeatButtonRepeatAllImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatAllSelectedImageKey = @"repeatButtonRepeatAllSelectedImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatNoneImageKey = @"repeatButtonRepeatNoneImageKey";
NSString *LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey = @"repeatButtonRepeatNoneSelectedImageKey";

@interface UIViewController (LMMediaPlayerPrefersStatusBarHidden)

- (void)mediaPlayerPrefersStatusBarHidden:(BOOL)hidden;

@end

@implementation UIViewController (LMMediaPlayerPrefersStatusBarHidden)

- (void)mediaPlayerPrefersStatusBarHidden:(BOOL)hidden
{
	Method fromMethod = class_getInstanceMethod([self class], @selector(prefersStatusBarHidden));
	Method toMethod = class_getInstanceMethod([self class], @selector(lm_media_player_prefersStatusBarHidden));
	method_exchangeImplementations(fromMethod, toMethod);
	objc_setAssociatedObject(self, (__bridge const void *)(kLMMediaPlayerPrefersStatusBarHidden), [NSNumber numberWithBool:hidden], OBJC_ASSOCIATION_COPY);
	[self setNeedsStatusBarAppearanceUpdate];
	objc_setAssociatedObject(self, (__bridge const void *)(kLMMediaPlayerPrefersStatusBarHidden), nil, OBJC_ASSOCIATION_COPY);
	method_exchangeImplementations(toMethod, fromMethod);
}

- (BOOL)lm_media_player_prefersStatusBarHidden
{
	NSNumber *hidden = (id)objc_getAssociatedObject(self, (__bridge const void *)(kLMMediaPlayerPrefersStatusBarHidden));
	return [hidden boolValue];
}

@end

@interface LMMediaPlayerView ()
{
	LMPlayerLayerView *videoLayer_;
	BOOL userInterfaceHidden_;
	IBOutlet UILabel *playbackTimeLabel_;
	IBOutlet UILabel *remainingTimeLabel_;
	IBOutlet UIView *headerView_;
	IBOutlet UIView *footerView_;
	IBOutlet UIImageView *artworkImageView_;
	IBOutlet UIButton *playButton_;
	IBOutlet UIButton *nextButton_;
	IBOutlet UIButton *previousButton_;
	IBOutlet UIButton *shuffleButton_;
	IBOutlet UIButton *repeatButton_;
	IBOutlet UIButton *fullscreenButton_;
	BOOL fullscreen_;
	BOOL seeking_;
	UIView *superView_;
	AVPlayerLayer *currentPlayerLayer_;
	NSMutableDictionary *buttonImages_;
}

@end

@implementation LMMediaPlayerView

static LMMediaPlayerView *sharedPlayerView;

+ (id)sharedPlayerView
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedPlayerView = [LMMediaPlayerView create];
	});
	return sharedPlayerView;
}

+ (id)create
{
	return [[UINib nibWithNibName:@"LMMediaPlayerView" bundle:nil] instantiateWithOwner:nil options:nil][0];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}

- (void)setup
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerBecomeForgroundMode:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayerBecomeBackgroundMode:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	userInterfaceHidden_ = NO;
	
	_mediaPlayer = [[LMMediaPlayer alloc] init];
	_mediaPlayer.delegate = self;
	
	artworkImageView_.contentMode = UIViewContentModeScaleAspectFit;
	
	[_currentTimeSlider addTarget:self action:@selector(beginSeek:) forControlEvents:UIControlEventTouchDown];
	[_currentTimeSlider addTarget:self action:@selector(endSeek:) forControlEvents:UIControlEventTouchUpInside];
	
	[playButton_ addTarget:self action:@selector(changePlaybackState:) forControlEvents:UIControlEventTouchUpInside];
	[nextButton_ addTarget:self action:@selector(fourcePlayNextMedia) forControlEvents:UIControlEventTouchUpInside];
	[previousButton_ addTarget:self	action:@selector(fourcePlayPreviousMedia) forControlEvents:UIControlEventTouchUpInside];
	
	UIView *gestureView = [[UIView alloc] initWithFrame:self.frame];
	gestureView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self addSubview:gestureView];
	[self sendSubviewToBack:gestureView];
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverseUserInterfaceHidden)];
	[gestureView addGestureRecognizer:gesture];
	
	UIColor *backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
	footerView_.backgroundColor = headerView_.backgroundColor = backgroundColor;
	nextButton_.backgroundColor = previousButton_.backgroundColor = backgroundColor;
	
	[_mediaPlayer setShuffleEnabled:NO];
	[_mediaPlayer setRepeatMode:LMMediaRepeatModeNone];
	
	buttonImages_ = [@{LMMediaPlayerViewPlayButtonImageKey						:	[[self class] getImageForFilename:@"play"],
					   LMMediaPlayerViewPlayButtonSelectedImageKey				:	[[self class] getImageForFilename:@"play"],
					   LMMediaPlayerViewStopButtonImageKey						:	[[self class] getImageForFilename:@"pause"],
					   LMMediaPlayerViewStopButtonSelectedImageKey				:	[[self class] getImageForFilename:@"pause"],
					   LMMediaPlayerViewShuffleButtonShuffledImageKey			:	[[self class] getImageForFilename:@"shuffle"],
					   LMMediaPlayerViewShuffleButtonShuffledSelectedImageKey	:	[[self class] getImageForFilename:@"shuffle"],
					   LMMediaPlayerViewShuffleButtonUnshuffledImageKey			:	[[self class] getImageForFilename:@"unshuffle"],
					   LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey	:	[[self class] getImageForFilename:@"unshuffle"],
					   LMMediaPlayerViewRepeatButtonRepeatNoneImageKey			:	[[self class] getImageForFilename:@"repeat_none"],
					   LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey	:	[[self class] getImageForFilename:@"repeat_none"],
					   LMMediaPlayerViewRepeatButtonRepeatOneImageKey			:	[[self class] getImageForFilename:@"repeat_one"],
					   LMMediaPlayerViewRepeatButtonRepeatOneSelectedImageKey	:	[[self class] getImageForFilename:@"repeat_one"],
					   LMMediaPlayerViewRepeatButtonRepeatAllImageKey			:	[[self class] getImageForFilename:@"repeat_all"],
					   LMMediaPlayerViewRepeatButtonRepeatAllSelectedImageKey	:	[[self class] getImageForFilename:@"repeat_all"],
					   LMMediaPlayerViewFullscreenButtonImageKey				:	[[self class] getImageForFilename:@"fullscreen"],
					   LMMediaPlayerViewFullscreenButtonSelectedImageKey		:	[[self class] getImageForFilename:@"fullscreen"],
					   LMMediaPlayerViewUnfullscreenButtonImageKey				:	[[self class] getImageForFilename:@"unfullscreen"],
					   LMMediaPlayerViewUnfullscreenButtonSelectedImageKey		:	[[self class] getImageForFilename:@"unfullscreen"]
					   } mutableCopy];
	
	[playButton_.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[playButton_ setImage:buttonImages_[LMMediaPlayerViewPlayButtonImageKey] forState:UIControlStateNormal];
	[playButton_ setImage:buttonImages_[LMMediaPlayerViewPlayButtonSelectedImageKey] forState:UIControlStateSelected];
	
	[fullscreenButton_.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewFullscreenButtonImageKey] forState:UIControlStateNormal];
	[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewFullscreenButtonSelectedImageKey] forState:UIControlStateSelected];
	
	[repeatButton_.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatNoneImageKey] forState:UIControlStateNormal];
	[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey] forState:UIControlStateSelected];
	
	[shuffleButton_.imageView setContentMode:UIViewContentModeScaleAspectFit];
	[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonUnshuffledImageKey] forState:UIControlStateNormal];
	[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey] forState:UIControlStateSelected];
	
	self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)mediaPlayerBecomeForgroundMode:(NSNotification *)notification
{
	[[videoLayer_ getPlayerLayer] setPlayer:[videoLayer_ getPlayer]];
}

- (void)mediaPlayerBecomeBackgroundMode:(NSNotification *)notification
{
	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[[videoLayer_ getPlayerLayer] setPlayer:nil];
		if (self.mediaPlayer.playbackState == LMMediaPlaybackStatePlaying) {
			[self.mediaPlayer play];
		}
	});
}

#pragma mark LMMediaPlayerDelegate

- (void)mediaPlayerWillChangeState:(LMMediaPlaybackState)state
{
	if ([self.delegate respondsToSelector:@selector(mediaPlayerViewWillChangeState:state:)]) {
		[self.delegate mediaPlayerViewWillChangeState:self state:state];
	}
	
	if (state == LMMediaPlaybackStateStopped || state == LMMediaPlaybackStatePaused) {
		if (state == LMMediaPlaybackStateStopped) {
			[videoLayer_ removeFromSuperview];
		}
		[playButton_ setImage:buttonImages_[LMMediaPlayerViewPlayButtonImageKey] ?: nil forState:UIControlStateNormal];
		[playButton_ setImage:buttonImages_[LMMediaPlayerViewPlayButtonSelectedImageKey] ?: nil forState:UIControlStateSelected];
	}
	else {
		[playButton_ setImage:buttonImages_[LMMediaPlayerViewStopButtonImageKey] ?: nil forState:UIControlStateNormal];
		[playButton_ setImage:buttonImages_[LMMediaPlayerViewStopButtonSelectedImageKey] ?: nil forState:UIControlStateSelected];
	}
}

- (BOOL)mediaPlayerWillStartPlaying:(LMMediaPlayer *)player media:(LMMediaItem *)media
{
	return [self.delegate respondsToSelector:@selector(mediaPlayerViewWillStartPlaying:media:)] && [self.delegate mediaPlayerViewWillStartPlaying:self media:media];
}

- (void)mediaPlayerDidStartPlaying:(LMMediaPlayer *)player media:(LMMediaItem *)media
{
	if (media.isVideo) {
		artworkImageView_.hidden = YES;
		videoLayer_ = [[LMPlayerLayerView alloc] initWithFrame:self.frame audioPlayer:_mediaPlayer.player];
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reverseUserInterfaceHidden)];
		[videoLayer_ addGestureRecognizer:gesture];
		double delayInSeconds = 0.01;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self addSubview:videoLayer_];
			[self sendSubviewToBack:videoLayer_];
		});

		videoLayer_.hidden = NO;
	}
	else {
		videoLayer_.hidden = YES;
		artworkImageView_.hidden = NO;
		artworkImageView_.image = [media getArtworkImageWithSize:self.frame.size];
	}
	if ([self.delegate respondsToSelector:@selector(mediaPlayerViewDidStartPlaying:media:)]) {
		[self.delegate mediaPlayerViewDidStartPlaying:self media:media];
	}
}

- (void)mediaPlayerDidFinishPlaying:(LMMediaPlayer *)player media:(LMMediaItem *)media
{
	if ([self.delegate respondsToSelector:@selector(mediaPlayerViewDidFinishPlaying:media:)]) {
		[self.delegate mediaPlayerViewDidFinishPlaying:self media:media];
	}
}

- (void)mediaPlayerDidChangeCurrentTime:(LMMediaPlayer *)player
{
	if (seeking_ == NO) {
		_currentTimeSlider.value = player.currentPlaybackTime / player.currentPlaybackDuration;
		
		NSMutableString *durationString = [NSMutableString new];
		NSInteger duration = (NSInteger)player.currentPlaybackTime;
		if (duration / (60 * 60) > 0) {
			[durationString appendFormat:@"%02d:",
			 duration / (60 * 60)];
			duration /= 60 * 60;
		}
		[durationString appendFormat:@"%02d:", duration / 60];
		duration %= 60;
		[durationString appendFormat:@"%02ld", (long)duration];
		playbackTimeLabel_.text = durationString;
		
		durationString = [NSMutableString stringWithString:@"-"];
		duration = (NSInteger)fabs(player.currentPlaybackTime - player.currentPlaybackDuration);
		if (duration / (60 * 60) > 0) {
			[durationString appendFormat:@"%02d:",
			 duration / (60 * 60)];
			duration /= 60 * 60;
		}
		[durationString appendFormat:@"%02d:", duration / 60];
		duration %= 60;
		[durationString appendFormat:@"%02ld", (long)duration];
		remainingTimeLabel_.text = durationString;
	}
}

- (void)mediaPlayerDidChangeRepeatMode:(LMMediaRepeatMode)mode player:(LMMediaPlayer *)player
{
	[self setRepeatButtonImageWithRepeatMode:mode];
}

#pragma mark -

- (void)beginSeek:(id)sender
{
	seeking_ = YES;
}

- (void)endSeek:(id)sender
{
	UISlider *slider = (UISlider *)sender;
	[_mediaPlayer seekTo:_mediaPlayer.currentPlaybackDuration * slider.value];
	seeking_ = NO;
}

- (void)changePlaybackState:(id)sender
{
	if ([_mediaPlayer playbackState] == LMMediaPlaybackStatePlaying) {
		[_mediaPlayer pause];
	}
	else if ([_mediaPlayer playbackState] == LMMediaPlaybackStatePaused || [_mediaPlayer playbackState] == LMMediaPlaybackStateStopped) {
		[_mediaPlayer play];
	}
}

- (void)reverseUserInterfaceHidden
{
	[self setUserInterfaceHidden:!userInterfaceHidden_];
}

- (void)fourcePlayNextMedia
{
	LMMediaRepeatMode repeatMode = _mediaPlayer.repeatMode;
	if (repeatMode == LMMediaRepeatModeOne) {
		_mediaPlayer.repeatMode = LMMediaRepeatModeNone;
	}
	[_mediaPlayer playNextMedia];
	_mediaPlayer.repeatMode = repeatMode;
}

- (void)fourcePlayPreviousMedia
{
	LMMediaRepeatMode repeatMode = _mediaPlayer.repeatMode;
	if (repeatMode == LMMediaRepeatModeOne) {
		_mediaPlayer.repeatMode = LMMediaRepeatModeNone;
	}
	[_mediaPlayer playPreviousMedia];
	_mediaPlayer.repeatMode = repeatMode;
}

- (IBAction)shuffleButtonPressed:(id)sender
{
	[_mediaPlayer setShuffleEnabled:!_mediaPlayer.shuffleMode];
	
	if (_mediaPlayer.shuffleMode) {
		[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonShuffledImageKey] forState:UIControlStateNormal];
		[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonShuffledSelectedImageKey] forState:UIControlStateSelected];
	}
	else {
		[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonUnshuffledImageKey] forState:UIControlStateNormal];
		[shuffleButton_ setImage:buttonImages_[LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey] forState:UIControlStateSelected];
	}
}

- (IBAction)repeatButtonPressed:(id)sender
{
	switch (_mediaPlayer.repeatMode) {
		case LMMediaRepeatModeAll: {
			_mediaPlayer.repeatMode = LMMediaRepeatModeOne;
		}
			break;
		case LMMediaRepeatModeOne: {
			_mediaPlayer.repeatMode = LMMediaRepeatModeNone;
		}
			break;
		case LMMediaRepeatModeNone: {
			_mediaPlayer.repeatMode = LMMediaRepeatModeAll;
		}
			break;
		default:
			break;
	}
	[self setRepeatButtonImageWithRepeatMode:_mediaPlayer.repeatMode];
}

- (void)setRepeatButtonImageWithRepeatMode:(LMMediaRepeatMode)mode
{
	switch (_mediaPlayer.repeatMode) {
		case LMMediaRepeatModeAll: {
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatAllImageKey] forState:UIControlStateNormal];
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatAllSelectedImageKey] forState:UIControlStateSelected];
		}
			break;
		case LMMediaRepeatModeOne: {
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatOneImageKey] forState:UIControlStateNormal];
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatOneSelectedImageKey] forState:UIControlStateSelected];
		}
			break;
		case LMMediaRepeatModeNone: {
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatNoneImageKey] forState:UIControlStateNormal];
			[repeatButton_ setImage:buttonImages_[LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey] forState:UIControlStateSelected];
		}
	}
}

- (IBAction)fullscreenButtonPressed:(id)sender
{
	CGRect newRect;
	if (fullscreen_) {
		[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewFullscreenButtonImageKey] forState:UIControlStateNormal];
		[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewFullscreenButtonSelectedImageKey] forState:UIControlStateSelected];
		UIViewController *viewController = [[[UIApplication sharedApplication] windows][0] rootViewController];
		if ([viewController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
			[viewController mediaPlayerPrefersStatusBarHidden:NO];
		} else {
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		}
		
		[self removeFromSuperview];
		newRect = superView_.bounds;
		[superView_ addSubview:self];
	}
	else {
		[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewUnfullscreenButtonImageKey] forState:UIControlStateNormal];
		[fullscreenButton_ setImage:buttonImages_[LMMediaPlayerViewUnfullscreenButtonSelectedImageKey] forState:UIControlStateSelected];
		superView_ = self.superview;
		UIWindow *window = [[UIApplication sharedApplication] keyWindow];
		if (window == nil) {
			window = [[UIApplication sharedApplication] windows][0];
		}
		newRect = window.frame;
		
		UIViewController *viewController = [[[UIApplication sharedApplication] windows][0] rootViewController];
		if ([viewController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
			[viewController mediaPlayerPrefersStatusBarHidden:YES];
		} else {
			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
		}
		
		UIInterfaceOrientation orientation = viewController.interfaceOrientation;
		if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
			newRect = CGRectMake(0, 0, CGRectGetHeight(window.frame), CGRectGetWidth(window.frame));
		}
		
		[self removeFromSuperview];
		[[window subviews][0] addSubview:self];
	}
	self.frame = newRect;
	self.alpha = 0;
	[UIView animateWithDuration:kFullscreenTransitionDuration animations:^{
		self.alpha = 1;
	}];
	fullscreen_ = !fullscreen_;
	[[UIApplication sharedApplication] setStatusBarHidden:fullscreen_ withAnimation:UIStatusBarAnimationFade];
}

#pragma mark -

- (void)setHeaderViewHidden:(BOOL)hidden
{
	headerView_.hidden = hidden;
}

- (void)setFooterViewHidden:(BOOL)hidden
{
	footerView_.hidden = hidden;
}

- (void)setUserInterfaceHidden:(BOOL)hidden
{
	userInterfaceHidden_ = hidden;
	if (hidden) {
		[UIView animateWithDuration:0.3 animations:^{
			headerView_.alpha = 0;
			footerView_.alpha = 0;
			_currentTimeSlider.alpha = 0;
			previousButton_.alpha = 0;
			nextButton_.alpha = 0;
		} completion:^(BOOL finished) {
		}];
	}
	else {
		[UIView animateWithDuration:0.3 animations:^{
			headerView_.alpha = 1;
			footerView_.alpha = 1;
			_currentTimeSlider.alpha = 1;
			previousButton_.alpha = 1;
			nextButton_.alpha = 1;
		} completion:^(BOOL finished) {
		}];
	}
}

- (void)setButtonImages:(NSDictionary *)info
{
	for (NSString *key in info) {
		buttonImages_[key] = info[key];
	}
}

+ (UIImage *)getImageForFilename:(NSString *)filename
{
	NSString *version = @"7";
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		version = @"6";
	}
	UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png", [[NSBundle mainBundle] pathForResource:@"LMMediaPlayerView" ofType:@"bundle"], version, filename]];
	return image;
}

@end
