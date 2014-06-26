LMMediaPlayer
====

LMMediaPlayer is a video and audio player for iPhone with changeable user interface.

![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/2.png)

![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/1.png)
![](https://raw.github.com/0x0c/LMMediaPlayer/master/images/3.png)

Requirements
====

- Runs on iOS 6.0 or later.
- Must be complied with ARC.

Intstallation
===

First, please add these frameworks.

===
	#import <MediaPlayer/MediaPlayer.h>
	#import <AVFoundation/AVFoundation.h>
===

Second, add files which is contained "LMMediaPlayer" folder.

That's it.

If you want to play with fullscreen mode, please add "View controller-based status bar appearance" key and set value with "NO" at your Info.plist

Usage
====

You can play **MPMediaItem** and **http streaming contents** with fullscreen or non-fullscreen mode.

===
	//Get shared player
	LMMediaPlayerView *player = [LMMediaPlayerView sharedPlayerView];
	
	//Create media item with URL.
	LMMediaItem *item1 = [[LMMediaItem alloc] initWithInfo:@{
		LMMediaItemInfoURLKey:[NSURL URLWithString:@"video or audio url"],
		LMMediaItemInfoURLKey:[NSNumber numberWithInteger:LMMediaItemContentTypeVideo]
	}];
	
	//Create media item with MPMediaItem.
	MPMediaItem *mediaItem = 
	LMMediaItem *item2 = [[LMMediaItem alloc] initWithMetaMedia:mediaItem contentType:LMMediaItemContentTypeVideo];
	
	//Add queue.
	[player.mediaPlayer addMedia:item1];
	[player.mediaPlayer addMedia:item2];
	
	//Play it!
	[player.mediaPlayer play];
===

without player view.

===
	//Get shared player
	LMMediaPlayer *player = [LMMediaPlayer sharedPlayer];
	
	//Create media item with URL.
	LMMediaItem *item1 = [[LMMediaItem alloc] initWithInfo:@{
		LMMediaItemInfoURLKey:[NSURL URLWithString:@"video or audio url"],
		LMMediaItemInfoURLKey:[NSNumber numberWithInteger:LMMediaItemContentTypeVideo]
	}];
	
	//Create media item with MPMediaItem.
	MPMediaItem *mediaItem = 
	LMMediaItem *item2 = [[LMMediaItem alloc] initWithMetaMedia:mediaItem contentType:LMMediaItemContentTypeVideo];
	
	//Add queue.
	[player addMedia:item1];
	[player addMedia:item2];
	
	//Play it!
	[player play];
===

Already implemented repeat mode and shuffle mode.

===
	LMMediaPlayerView *player = [LMMediaPlayerView sharedPlayerView];
	player.mediaPlayer.repeatMode = LMMediaRepeatModeNone;
	player.mediaPlayer.repeatMode = LMMediaRepeatModeAll;
	player.mediaPlayer.repeatMode = LMMediaRepeatModeOne;
	
	[player.mediaPlayer setShuffleEnabled:YES];
===

Of course, you can play video or audio in background mode and can control with control center.
Please check document in the repository.

Contacts
====

- [akira.matsuda@me.com](mailto:akira.matsuda@me.com)

License
====

LMMediaPlayer is available under the MIT license.