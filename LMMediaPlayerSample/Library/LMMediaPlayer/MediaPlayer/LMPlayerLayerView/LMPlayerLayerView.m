//
//  LMMediaPlayerView.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/30.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMPlayerLayerView.h"

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
		_player = player;
		_playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
		[self.layer addSublayer:_playerLayer];
    }
	
    return self;
}

- (void)layoutSubviews
{
	// resize your layers based on the view's new bounds
	_playerLayer.frame = self.bounds;
}

@end
