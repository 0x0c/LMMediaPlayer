# LMMediaPlayer

[![CI Status](http://img.shields.io/travis/Akira Matsuda/LMMediaPlayer.svg?style=flat)](https://travis-ci.org/Akira Matsuda/LMMediaPlayer)
[![Version](https://img.shields.io/cocoapods/v/LMMediaPlayer.svg?style=flat)](http://cocoadocs.org/docsets/LMMediaPlayer)
[![License](https://img.shields.io/cocoapods/l/LMMediaPlayer.svg?style=flat)](http://cocoadocs.org/docsets/LMMediaPlayer)
[![Platform](https://img.shields.io/cocoapods/p/LMMediaPlayer.svg?style=flat)](http://cocoadocs.org/docsets/LMMediaPlayer)

LMMediaPlayer is a video and an audio player for iPhone with replaceable user interface.

![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/1.png)
![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/2.png)
![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/3.png)

## Requirements

- Runs on iOS 6.0 or later.

## Installation

LMMediaPlayer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "LMMediaPlayer"

## Usage

You can play **MPMediaItem** and **http streaming contents** with fullscreen or non-fullscreen mode.

	//Get shared player
	LMMediaPlayerView *player = [LMMediaPlayerView sharedPlayerView];

	//Create media item with URL.
	LMMediaItem *item1 = [[LMMediaItem alloc] initWithInfo:@{
		LMMediaItemInfoURLKey:[NSURL URLWithString:@"video or audio url"],
		LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)
	}];

	//Create media item with MPMediaItem.
	MPMediaItem *mediaItem =
	LMMediaItem *item2 = [[LMMediaItem alloc] initWithMetaMedia:mediaItem contentType:LMMediaItemContentTypeVideo];

	//Add queue.
	[player.mediaPlayer addMedia:item1];
	[player.mediaPlayer addMedia:item2];

	//Play it!
	[player.mediaPlayer play];

without player view.

	//Get shared player
	LMMediaPlayer *player = [LMMediaPlayer sharedPlayer];

	//Create media item with URL.
	LMMediaItem *item1 = [[LMMediaItem alloc] initWithInfo:@{
		LMMediaItemInfoURLKey:[NSURL URLWithString:@"video or audio url"],
		LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)
	}];

	//Create media item with MPMediaItem.
	MPMediaItem *mediaItem =
	LMMediaItem *item2 = [[LMMediaItem alloc] initWithMetaMedia:mediaItem contentType:LMMediaItemContentTypeVideo];

	//Add queue.
	[player addMedia:item1];
	[player addMedia:item2];

	//Play it!
	[player play];

Already implemented repeat mode and shuffle mode.

	LMMediaPlayerView *player = [LMMediaPlayerView sharedPlayerView];
	player.mediaPlayer.repeatMode = LMMediaRepeatModeNone;
	player.mediaPlayer.repeatMode = LMMediaRepeatModeAll;
	player.mediaPlayer.repeatMode = LMMediaRepeatModeOne;

	[player.mediaPlayer setShuffleEnabled:YES];

To change user interface, use ```setButtonImages:``` and set images with these keys.

| Keys |
|:-----------|
| LMMediaPlayerViewPlayButtonImageKey       |
| LMMediaPlayerViewPlayButtonSelectedImageKey |
| LMMediaPlayerViewStopButtonImageKey |
| LMMediaPlayerViewStopButtonSelectedImageKey |
| LMMediaPlayerViewFullscreenButtonImageKey |
| LMMediaPlayerViewFullscreenButtonSelectedImageKey |
| LMMediaPlayerViewUnfullscreenButtonImageKey |
| LMMediaPlayerViewUnfullscreenButtonSelectedImageKey |
| LMMediaPlayerViewShuffleButtonShuffledImageKey  |
| LMMediaPlayerViewShuffleButtonShuffledSelectedImageKey  |
| LMMediaPlayerViewShuffleButtonUnshuffledImageKey  |
| LMMediaPlayerViewShuffleButtonUnshuffledSelectedImageKey  |
| LMMediaPlayerViewRepeatButtonRepeatOneImageKey  |
| LMMediaPlayerViewRepeatButtonRepeatOneSelectedImageKey  |
| LMMediaPlayerViewRepeatButtonRepeatAllImageKey  |
| LMMediaPlayerViewRepeatButtonRepeatAllSelectedImageKey  |
| LMMediaPlayerViewRepeatButtonRepeatNoneImageKey |
| LMMediaPlayerViewRepeatButtonRepeatNoneSelectedImageKey |
| LMMediaPlayerViewActionButtonImageKey |

To show action button, set image with ```LMMediaPlayerViewActionButtonImageKey```.

Of course, you can play video or audio in background mode and can control with control center.
If you want to play with fullscreen mode, please add "View controller-based status bar appearance" key and set value with "NO" at your Info.plist

## Author

Akira Matsuda, [akira.matsuda@me.com](mailto:akira.matsuda@me.com)

## License

LMMediaPlayer is available under the MIT license. See the LICENSE file for more info.
