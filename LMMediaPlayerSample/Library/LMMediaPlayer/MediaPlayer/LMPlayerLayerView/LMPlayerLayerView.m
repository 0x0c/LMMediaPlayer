//
//  LMMediaPlayerView.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/30.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMPlayerLayerView.h"

@interface LMPlayerLayerView ()
{
	AVPlayerLayer *playerLayer_;
	AVPlayer *player_;
}

@end

@implementation LMPlayerLayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (id)initWithFrame:(CGRect)frame audioPlayer:(AVPlayer *)player
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor blackColor];
		[self setTranslatesAutoresizingMaskIntoConstraints:YES];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		player_ = player;
		playerLayer_ = [AVPlayerLayer playerLayerWithPlayer:player];
		[self.layer addSublayer:playerLayer_];
    }
	
    return self;
}

- (void)layoutSubviews
{
	// resize your layers based on the view's new bounds
	playerLayer_.frame = self.bounds;
}

- (AVPlayerLayer *)getPlayerLayer
{
	return playerLayer_;
}

- (AVPlayer *)getPlayer
{
	return player_;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
