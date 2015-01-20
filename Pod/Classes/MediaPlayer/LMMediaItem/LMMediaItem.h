//
//  LMMediaItem.h
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/27.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *LMMediaItemInfoTitleKey;
extern NSString *LMMediaItemInfoAlubumTitleKey;
extern NSString *LMMediaItemInfoArtistKey;
extern NSString *LMMediaItemInfoArtworkKey;
extern NSString *LMMediaItemInfoURLKey;
extern NSString *LMMediaItemInfoContentTypeKey;

typedef NS_ENUM(NSUInteger, LMMediaItemContentType) {
	LMMediaItemContentTypeUnknown = -1,
	LMMediaItemContentTypeAudio = 0,
	LMMediaItemContentTypeVideo = 1
};

@interface LMMediaItem : NSObject <NSCoding, NSCopying>

- (instancetype)initWithMetaMedia:(id)media contentType:(LMMediaItemContentType)type;
- (instancetype)initWithInfo:(NSDictionary *)info;
- (UIImage *)artworkImageWithSize:(CGSize)size;
- (void)setArtworkImage:(UIImage *)image;
- (BOOL)isVideo;

@property (nonatomic, copy, getter = getTitle) NSString *title;
@property (nonatomic, copy, getter = getAlbumTitle) NSString *albumTitle;
@property (nonatomic, copy, getter = getArtistString) NSString *artist;
@property (nonatomic, copy) id metaMedia;
@property (nonatomic, copy, getter = getAssetURL) NSURL *assetURL;

@end
