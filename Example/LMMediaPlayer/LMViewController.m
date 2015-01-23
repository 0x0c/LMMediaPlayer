//
//  LMViewController.m
//  LMMediaPlayer
//
//  Created by Akira Matsuda on 08/28/2014.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "LMViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LMMediaItem.h"

@interface LMViewController ()
{
	MPMediaPlaylist *currentPlaylist_;
	LMMediaPlayerView *playerView_;
	NSArray *musics_;
	NSArray *playlists_;
}

@end

@implementation LMViewController

- (id)initWithPlaylist:(MPMediaPlaylist *)playlist
{
	self = [self initWithStyle:UITableViewStylePlain];
	if (self) {
		currentPlaylist_ = playlist;
	}
	
	return self;
}

- (void)dealloc
{
	playerView_.delegate = nil;
#if !__has_feature(objc_arc)
	[super dealloc];
	[musics_ release];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (currentPlaylist_) {
		musics_ = [currentPlaylist_ items];
		self.title = [currentPlaylist_ valueForProperty:MPMediaPlaylistPropertyName];
	}
	else {
		MPMediaQuery *q = [[MPMediaQuery alloc] init];
		musics_ = [q items];
#if !__has_feature(objc_arc)
		[q release];
#endif
		playlists_ = [[MPMediaQuery playlistsQuery] collections];
	}
	playerView_ = [LMMediaPlayerView sharedPlayerView];
	playerView_.delegate = self;
	[playerView_ setBluredUserInterface:YES visualEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//	[playerView_ setBluredUserInterface:NO visualEffect:nil];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL *path = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"mp4"];
		LMMediaItem *item = [[LMMediaItem alloc] initWithInfo:@{LMMediaItemInfoURLKey:path, LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)}];
		item.title = @"sample.mp4";
		[playerView_.mediaPlayer addMedia:item];
		[playerView_.mediaPlayer play];
#if !__has_feature(objc_arc)
		[item release];
#endif
	});
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	playerView_.delegate = self;
	
	UIView *baseView = [[UIView alloc] initWithFrame:playerView_.frame];
	baseView.backgroundColor = [UIColor blackColor];
	[baseView addSubview:playerView_];
	self.tableView.tableHeaderView = baseView;
#if !__has_feature(objc_arc)
	[baseView release];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];
	
	playerView_.delegate = self;
}

- (BOOL)shouldAutorotate
{
	return NO;
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
#if !__has_feature(objc_arc)
		[cell autorelease];
#endif
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
			LMMediaItem *item = [[LMMediaItem alloc] initWithMetaMedia:musics_[indexPath.row] contentType:([type integerValue] & MPMediaTypeMusicVideo) ? LMMediaItemContentTypeVideo : LMMediaItemContentTypeAudio];
			[playerView_.mediaPlayer addMedia:item];
#if !__has_feature(objc_arc)
			[item release];
#endif
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DRM content" message:@"You cannot add this content because of DRM." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		LMViewController *viewController = [[LMViewController alloc] initWithPlaylist:playlists_[indexPath.row]];
		[self.navigationController pushViewController:viewController animated:YES];
#if !__has_feature(objc_arc)
		[viewController release];
#endif
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
