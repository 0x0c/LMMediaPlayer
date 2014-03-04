//
//  LMMediaItem.h
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/27.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *const LMMediaItemInfoTitleKey = @"LMMediaItemInfoTitleKey";
static NSString *const LMMediaItemInfoAlubumTitleKey = @"LMMediaItemInfoAlubumTitleKey";
static NSString *const LMMediaItemInfoArtistKey = @"LMMediaItemInfoArtistKey";
static NSString *const LMMediaItemInfoArtworkKey = @"LMMediaItemInfoArtworkKey";
static NSString *const LMMediaItemInfoURLKey = @"LMMediaItemInfoURLKey";
static NSString *const LMMediaItemInfoContentTypeKey = @"LMMediaItemInfoContentTypeKey";

typedef enum {
	LMMediaItemContentTypeUnknown = -1,
	LMMediaItemContentTypeAudio = 0,
	LMMediaItemContentTypeVideo = 1
} LMMediaItemContentType;

@interface LMMediaItem : NSObject <NSCoding, NSCopying>
{
	id metaMedia_;
	NSString *title_;
	NSString *albumTitle_;
	NSString *artist_;
	UIImage *artworkImage_;
	NSURL *url_;
	LMMediaItemContentType contentType_;
}

- (id)initWithMetaMedia:(id)media contentType:(LMMediaItemContentType)type;
- (id)initWithInfo:(NSDictionary *)info;
- (UIImage *)getArtworkImageWithSize:(CGSize)size;
- (void)setArtworkImage:(UIImage *)image;
- (BOOL)isVideo;
- (NSString *)getDescription;

@property (nonatomic, copy, getter = getTitle) NSString *title;
@property (nonatomic, copy, getter = getAlbumTitle) NSString *albumTitle;
@property (nonatomic, copy, getter = getArtistString) NSString *artist;
@property (nonatomic, copy) id metaMedia;
@property (nonatomic, copy, getter = getAssetURL) NSURL *assetURL;

@end
