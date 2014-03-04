//
//  LMMediaItem.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/27.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMMediaItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation LMMediaItem

@synthesize title = title_;
@synthesize albumTitle = albumTitle_;
@synthesize artist = artist_;
@synthesize assetURL = url_;

- (id)initWithMetaMedia:(id)media contentType:(LMMediaItemContentType)type
{
	self = [super init];
	if (self) {
		metaMedia_ = media;
		contentType_ = type;
	}
	
	return self;
}

- (id)initWithInfo:(NSDictionary *)info
{
	self = [super init];
	if (self) {
		title_ = ([info[LMMediaItemInfoTitleKey] isKindOfClass:[NSString class]] ? [info[LMMediaItemInfoTitleKey] copy] : nil);
		albumTitle_ = ([info[LMMediaItemInfoAlubumTitleKey] isKindOfClass:[NSString class]] ? [info[LMMediaItemInfoAlubumTitleKey] copy] : nil);
		artist_ = ([info[LMMediaItemInfoArtistKey] isKindOfClass:[NSString class]] ? [info[LMMediaItemInfoArtistKey] copy] : nil);
		artworkImage_ = ([info[LMMediaItemInfoArtworkKey] isKindOfClass:[UIImage class]] ? [info[LMMediaItemInfoArtworkKey] copy] : nil);
		url_ = ([info[LMMediaItemInfoURLKey] isKindOfClass:[NSURL class]] ? [info[LMMediaItemInfoURLKey] copy] : nil);
		contentType_ = (LMMediaItemContentType)([info[LMMediaItemInfoContentTypeKey] isKindOfClass:[NSNumber class]] ? [info[LMMediaItemInfoContentTypeKey] integerValue] : -1);
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super init];
	if (self) {
		title_ = [coder decodeObjectForKey:LMMediaItemInfoTitleKey];
		albumTitle_ = [coder decodeObjectForKey:LMMediaItemInfoAlubumTitleKey];
		artist_ = [coder decodeObjectForKey:LMMediaItemInfoArtistKey];
		artworkImage_ = [coder decodeObjectForKey:LMMediaItemInfoArtworkKey];
		url_ = [coder decodeObjectForKey:LMMediaItemInfoURLKey];
		contentType_ = (LMMediaItemContentType)[[coder decodeObjectForKey:LMMediaItemInfoContentTypeKey] integerValue];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:title_ forKey:LMMediaItemInfoTitleKey];
	[coder encodeObject:albumTitle_ forKey:LMMediaItemInfoAlubumTitleKey];
	[coder encodeObject:artist_ forKey:LMMediaItemInfoArtistKey];
	[coder encodeObject:artworkImage_ forKey:LMMediaItemInfoArtworkKey];
	[coder encodeObject:url_ forKey:LMMediaItemInfoURLKey];
	[coder encodeObject:[NSNumber numberWithInteger:contentType_] forKey:LMMediaItemInfoContentTypeKey];
}

- (id)copyWithZone:(NSZone *)zone
{
	NSMutableDictionary *newInfo = [NSMutableDictionary new];
	if (title_) {
		newInfo[LMMediaItemInfoTitleKey] = [title_ copy];
	}
	if (albumTitle_) {
		newInfo[LMMediaItemInfoAlubumTitleKey] = [albumTitle_ copy];
	}
	if (artist_) {
		newInfo[LMMediaItemInfoArtistKey] = [artist_ copy];
	}
	if (artworkImage_) {
		newInfo[LMMediaItemInfoArtworkKey] = [artworkImage_ copy];
	}
	if (url_) {
		newInfo[LMMediaItemInfoURLKey] = [url_ copy];
	}
	newInfo[LMMediaItemInfoContentTypeKey] = [NSNumber numberWithInteger:contentType_];
	
	LMMediaItem *newObject = [[[self class] allocWithZone:zone] initWithInfo:newInfo];
	return newObject;
}

- (id)getPropertyValue:(NSString *)property cache:(id)cache
{
	id returnValue = nil;
	if ([metaMedia_ isKindOfClass:[MPMediaItem class]]) {
		returnValue = cache = [metaMedia_ valueForProperty:property];
	}
	
	return returnValue;
}

- (NSString *)getTitle
{
	return title_ ?: [self getPropertyValue:MPMediaItemPropertyTitle cache:title_];
}

- (NSString *)getAlbumTitle
{
	return albumTitle_ ?: [self getPropertyValue:MPMediaItemPropertyAlbumTitle cache:albumTitle_];
}

- (NSString *)getArtistString
{
	return artist_ ?: [self getPropertyValue:MPMediaItemPropertyAlbumTitle cache:artist_];
}

- (UIImage *)getArtworkImageWithSize:(CGSize)size
{
	UIImage *(^f)(id) = ^UIImage *(id metaMedia){
		UIImage *image = nil;
		if ([metaMedia isKindOfClass:[MPMediaItem class]]) {
			artworkImage_ = image = [[metaMedia_ valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:size];
		}
		
		return image;
	};

	return artworkImage_ ?:  f(metaMedia_);
}

- (void)setArtworkImage:(UIImage *)image
{
	artworkImage_ = [image copy];
}

- (NSURL *)getAssetURL
{
	return url_ ?: [self getPropertyValue:MPMediaItemPropertyAssetURL cache:url_];
}

- (id)getMetaMedia
{
	return metaMedia_;
}

- (BOOL)isVideo
{
	return contentType_;
}

- (NSString *)getDescription
{
	return [@{@"title":title_ ?: @"nil",
			  @"album":albumTitle_ ?: @"nil",
			  @"artist":artist_ ?: @"nil",
			  @"url":url_ ?: @"nil",
			  @"artwork":artworkImage_ ?: @"nil",
			  @"content type":contentType_ == LMMediaItemContentTypeAudio ? @"LMMediaItemContentTypeAudio" : @"LMMediaItemContentTypeVideo",
			  @"meta media":metaMedia_ ?: @"nil"} description];
}

@end
