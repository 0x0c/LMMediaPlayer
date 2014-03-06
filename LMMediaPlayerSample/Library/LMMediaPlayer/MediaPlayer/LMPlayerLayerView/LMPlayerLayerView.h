//
//  LMMediaPlayerView.h
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/30.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LMPlayerLayerView : UIView

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, readonly) AVPlayer *player;

- (id)initWithFrame:(CGRect)frame audioPlayer:(AVPlayer *)player;

@end
