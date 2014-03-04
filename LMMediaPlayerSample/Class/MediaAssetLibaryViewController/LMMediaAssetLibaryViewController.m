//
//  LMMediaAssetLibaryViewController.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/10.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMMediaAssetLibaryViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LMMediaItemQueueManager.h"
#import "HCYoutubeParser.h"
#import "LMMediaItem.h"

@interface LMMediaAssetLibaryViewController ()
{
	MPMediaPlaylist *currentPlaylist_;
	LMMediaPlayerView *playerView_;
	NSArray *musics_;
	NSArray *playlists_;
}

@end

@implementation LMMediaAssetLibaryViewController

- (id)initWithPlaylist:(MPMediaPlaylist *)playlist
{
	self = [self initWithStyle:UITableViewStylePlain];
	if (self) {
		currentPlaylist_ = playlist;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (currentPlaylist_) {
		musics_ = [currentPlaylist_ items];
		self.title = [currentPlaylist_ valueForProperty:MPMediaPlaylistPropertyName];
	}
	else {
		musics_ = [[[MPMediaQuery alloc] init] items];
		playlists_ = [[MPMediaQuery playlistsQuery] collections];
	}
	playerView_ = [LMMediaPlayerView sharedPlayerView];
	playerView_.delegate = self;
	[HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=rVWx5YHmvFo"] completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
		NSDictionary *qualities = videoDictionary;
		NSString *URLString = nil;
		if ([qualities objectForKey:@"small"] != nil) {
			URLString = [qualities objectForKey:@"small"];
		}
		else if ([qualities objectForKey:@"live"] != nil) {
			URLString = [qualities objectForKey:@"live"];
		}
		else {
			[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't find youtube video" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil] show];
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			LMMediaItem *item = [[LMMediaItem alloc] initWithInfo:@{
																	LMMediaItemInfoURLKey:[NSURL URLWithString:URLString]
																	}];
			[playerView_.mediaPlayer addMedia:item];
			[playerView_.mediaPlayer play];
		});
	}];
	UIView *baseView = [[UIView alloc] initWithFrame:playerView_.frame];
	baseView.backgroundColor = [UIColor blackColor];
	[baseView addSubview:playerView_];
	self.tableView.tableHeaderView = baseView;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];
}

#pragma mark - LMMediaPlayerViewDelegate

- (BOOL)mediaPlayerViewWillStartPlaying:(LMMediaPlayerView *)playerView media:(LMMediaItem *)media
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return currentPlaylist_ == nil ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == 0 ? [musics_ count] : [playlists_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	if (indexPath.section == 0) {
		cell.textLabel.text = [(MPMediaItem *)musics_[indexPath.row] valueForProperty:MPMediaItemPropertyTitle];
		cell.detailTextLabel.text = [(MPMediaItem *)musics_[indexPath.row] valueForProperty:MPMediaItemPropertyArtist];
		MPMediaItemArtwork *artwork = [musics_[indexPath.row] valueForProperty:MPMediaItemPropertyArtwork];
		cell.imageView.image = [artwork imageWithSize:CGSizeMake(44, 44)];
	}
	else if (indexPath.section == 1) {
		cell.textLabel.text = [(MPMediaPlaylist *)playlists_[indexPath.row] valueForProperty:MPMediaPlaylistPropertyName];
		cell.detailTextLabel.text = @"";
		cell.imageView.image = nil;
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = nil;
	if (section == 0) {
		title = @"Songs";
	}
	else {
		title = @"Playlists";
	}
	
	return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		NSURL *url = [musics_[indexPath.row] valueForProperty:MPMediaItemPropertyAssetURL];
		if (url.absoluteString.length) {
			NSNumber *type = [musics_[indexPath.row] valueForProperty:MPMediaItemPropertyMediaType];
			LMMediaItem *item = [[LMMediaItem alloc] initWithMetaMedia:musics_[indexPath.row] contentType:([type integerValue] | MPMediaTypeMusicVideo) ? LMMediaItemContentTypeVideo : LMMediaItemContentTypeAudio];
			[playerView_.mediaPlayer addMedia:item];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DRM content" message:@"You cannot add this content because of DRM." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		LMMediaAssetLibaryViewController *viewController = [[LMMediaAssetLibaryViewController alloc] initWithPlaylist:playlists_[indexPath.row]];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark - 
#pragma mark - remote control event
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
	if (receivedEvent.type == UIEventTypeRemoteControl) {
		switch (receivedEvent.subtype) {
			case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
			case UIEventSubtypeRemoteControlTogglePlayPause: {
				if ([playerView_.mediaPlayer playbackState] == LMMediaPlaybackStatePlaying) {
					[playerView_.mediaPlayer pause];
				}
				else if ([playerView_.mediaPlayer playbackState] == LMMediaPlaybackStatePaused || [playerView_.mediaPlayer playbackState] == LMMediaPlaybackStateStopped) {
					[playerView_.mediaPlayer play];
				}
			}
				break;
			case UIEventSubtypeRemoteControlPreviousTrack: {
				[playerView_.mediaPlayer playPreviousMedia];
			}
				break;
			case UIEventSubtypeRemoteControlNextTrack: {
				[playerView_.mediaPlayer playNextMedia];
			}
				break;
			default:
				break;
		}
	}
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
