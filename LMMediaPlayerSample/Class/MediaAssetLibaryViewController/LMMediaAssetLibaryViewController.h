//
//  LMMediaAssetLibaryViewController.h
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/10.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMMediaPlayerView.h"

@class MPMediaPlaylist;

@interface LMMediaAssetLibaryViewController : UITableViewController<LMMediaPlayerViewDelegate>

- (id)initWithPlaylist:(MPMediaPlaylist *)playlist;

@end
