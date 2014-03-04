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

- (id)initWithFrame:(CGRect)frame audioPlayer:(AVPlayer *)player;
- (AVPlayerLayer *)getPlayerLayer;
- (AVPlayer *)getPlayer;

@end
