//
//  LMMediaItemArchiver.m
//  iPodMusicSample
//
//  Created by Akira Matsuda on 2014/01/31.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "LMMediaItemQueueManager.h"

static const NSString *const kLMMediaItemQueueManagerQueueList = @"kLMMediaItemQueueManagerQueueList";

@implementation LMMediaItemQueueManager

+ (NSArray *)getQueueList
{
	return [[NSUserDefaults standardUserDefaults] arrayForKey:(NSString *)kLMMediaItemQueueManagerQueueList];
}

+ (void)removeQueueWithKey:(NSString *)key
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	NSMutableArray *keys = [[LMMediaItemQueueManager getQueueList] mutableCopy];
	for (NSString *k in keys) {
		if ([k isEqualToString:key]) {
			[keys removeObject:k];
			break;
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[keys copy] forKey:(NSString *)kLMMediaItemQueueManagerQueueList];
}

+ (void)saveQueueWithKey:(NSString *)key queue:(NSArray *)queue
{
	NSMutableArray *saveArray = [NSMutableArray new];
	for (LMMediaItem *item in queue) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
		[saveArray addObject:data];
	}
	[[NSUserDefaults standardUserDefaults] setObject:saveArray forKey:key];
	
	NSMutableArray *keys = [[LMMediaItemQueueManager getQueueList] mutableCopy];
	[keys addObject:key];
	[[NSUserDefaults standardUserDefaults] setObject:[keys copy] forKey:(NSString *)kLMMediaItemQueueManagerQueueList];
}

+ (NSArray *)loadQueueWithKey:(NSString *)key
{
	NSMutableArray *result = [NSMutableArray new];
	NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
	for (id d in array) {
		LMMediaItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:d];
		[result addObject:item];
	}
	
	return [result copy];
}

@end
