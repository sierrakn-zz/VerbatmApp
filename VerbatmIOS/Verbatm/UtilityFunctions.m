//
//  UseFulFunctions.m
//  Verbatm
//
//  Created by Iain Usiri on 9/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "UtilityFunctions.h"
#import "Notifications.h"
#import "zlib.h"
#include <compression.h>
#import "Channel.h"

@import AVFoundation;
@import Foundation;

@interface UtilityFunctions ()

@property (strong, nonatomic) NSMutableArray *sessionTasks;
@property (strong, nonatomic) NSCondition * cancelSessionCondition;

#define COMPRESSING 0

@end

@implementation UtilityFunctions

+ (id)sharedInstance {
	static UtilityFunctions *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[UtilityFunctions alloc] init];

	});
	return sharedInstance;
}

+(NSString*) stripLargePhotoSuffix:(NSString*)photoUrl {
	NSString * suffix = @"=s0";
	if ([photoUrl hasSuffix:suffix] ) {
		return [photoUrl substringWithRange:NSMakeRange(0, photoUrl.length-suffix.length)];
	}
	return photoUrl;
}

+(NSString*) addSuffixToPhotoUrl:(NSString*)photoUrl forSize:(NSInteger)size {
	photoUrl = [UtilityFunctions stripLargePhotoSuffix: photoUrl];
	NSString *suffix = @"=s";
	suffix = [suffix stringByAppendingString: [NSString stringWithFormat:@"%ld", (long)size]];
	NSString *newUrl = [photoUrl stringByAppendingString: suffix];
	return newUrl;
}

//This code fuses the video assets into a single video that plays the videos one after the other.
//It accepts both avassets and urls which it converts into assets
+(AVMutableComposition*) fuseAssets:(NSArray*)videoList {
	AVMutableComposition *fusedAsset = [AVMutableComposition composition]; //create a composition to hold the joined assets
	AVMutableCompositionTrack* videoTrack = [fusedAsset addMutableTrackWithMediaType:AVMediaTypeVideo
																	preferredTrackID:kCMPersistentTrackID_Invalid];
	AVMutableCompositionTrack* audioTrack = [fusedAsset addMutableTrackWithMediaType:AVMediaTypeAudio
																	preferredTrackID:kCMPersistentTrackID_Invalid];
	CMTime nextClipStartTime = kCMTimeZero;
	NSError* error;
	for(id asset in videoList) {
		AVURLAsset * videoAsset;
		if([asset isKindOfClass:[NSURL class]]) {
			videoAsset = [AVURLAsset assetWithURL:asset];
		} else {
			videoAsset = asset;
		}
		NSArray * videoTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
		if(!videoTrackArray.count) continue;

		AVAssetTrack* currentVideoTrack = [videoTrackArray objectAtIndex:0];
		[videoTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentVideoTrack atTime:nextClipStartTime error: &error];
		videoTrack.preferredTransform = currentVideoTrack.preferredTransform;

		NSArray * audioTrackArray = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
		if(!audioTrackArray.count) continue;
		AVAssetTrack* currentAudioTrack = [audioTrackArray objectAtIndex:0];
		audioTrack.preferredTransform = currentAudioTrack.preferredTransform;
		[audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:currentAudioTrack atTime:nextClipStartTime error:&error];
		nextClipStartTime = CMTimeAdd(nextClipStartTime, videoAsset.duration);
	}
	if (error) {
		[[Crashlytics sharedInstance] recordError: error];
	}
	return fusedAsset;
}

+ (NSArray*)shuffleArray:(NSArray*)array {

	NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];

	for(NSUInteger i = [array count]; i > 1; i--) {
		NSUInteger j = (NSUInteger)arc4random_uniform((u_int32_t)i);
		[temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
	}

	return [NSArray arrayWithArray:temp];
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

+ (NSString *) randomStringWithLength: (NSInteger)length {
	NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
	for (int i=0; i<length; i++) {
		[randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((unsigned int)[letters length])]];
	}
	return randomString;
}

+ (UIButton *) getButtonWithFrame:(CGRect)frame andIcon:(NSString*)iconName andSelector:(SEL)action andTarget:(id) target {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
	[button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}


+(BOOL)isEmptyText:(NSString *) string{
    
    NSString * stringNoSpaces = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([stringNoSpaces isEqualToString:@""]){
        return YES;
    }
    return NO;
}

// Promise wrapper for asynchronous request to get image data (or any data) from the url
- (AnyPromise*) loadCachedPhotoDataFromURL: (NSURL*) url {
	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		NSURLRequest* request = [NSURLRequest requestWithURL:url
												 cachePolicy: NSURLRequestReturnCacheDataElseLoad
											 timeoutInterval:300];
		NSURLSessionDataTask *task = [[NSURLSession sharedSession]
									  dataTaskWithRequest:request
									  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                          
										  if (!data || error) {
											  //error code -999 means request was cancelled
											  if (error.code != -999) {
												  NSLog(@"Error downloading photo from url %@ : %@", url, error.description);
												  [[Crashlytics sharedInstance] recordError: error];
											  }
											  resolve(nil);
										  } else if(data){
											  resolve(data);
										  }
		}];
		[self.sessionTasks addObject: task];
		[task resume];

	}];
	return promise;
}

- (void) cancelAllSharedSessionDataTasks {
	for (NSURLSessionTask *_task in self.sessionTasks) {
		if (_task.state == NSURLSessionTaskStateRunning || _task.state == NSURLSessionTaskStateSuspended) {
			NSLog(@"Canceling task");
			[_task cancel];
		}
	}
	self.sessionTasks = nil;
}

- (AnyPromise*) loadCachedVideoDataFromURL: (NSURL*) url {
    AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        
        [UtilityFunctions convertVideoToLowQualityWithInputURL:url withCompletion:^(NSURL * url, BOOL deleteUrl) {
            NSError * error = nil;
            NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            
          if(deleteUrl)[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            if (error) {
                 [[Crashlytics sharedInstance] recordError: error];
                resolve(nil);
            } else {
                resolve([UtilityFunctions gzipDeflate:data]);
            }
        }];
    }];
    return promise;
}

+ (void)convertVideoToLowQualityWithInputURL:(NSURL *) videoUrl withCompletion:(void (^)(NSURL *,  BOOL ))successHandler {

    //  STORE IN FILESYSTEM
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString * uniqueVideoURL = [[videoUrl.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByAppendingString:@".mov"];
    
    NSString *finalFile = [cachesDirectory stringByAppendingPathComponent:uniqueVideoURL];
    NSURL * finalUrl = [NSURL fileURLWithPath:finalFile];
    
    [UtilityFunctions convertVideoToLowQuailtyWithInputURL:videoUrl outputURL:finalUrl handler:^(AVAssetExportSession * session) {
        if (session.status == AVAssetExportSessionStatusCompleted){
            successHandler(finalUrl, YES);
        }else if (session.status == AVAssetExportSessionStatusFailed){
            successHandler(videoUrl, NO);
        }
    }];
}


+ (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession*))handler {
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        handler(exportSession);
    }];
}

+ (NSData *)gzipDeflate:(NSData*)data {
    
    if(!COMPRESSING) return data;

    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = [data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_BEST_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = [compressed length] - strm.total_out;
        
        deflate(&strm, Z_FINISH);
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    
    NSData * finalResult = [NSData dataWithData:compressed];
//    NSLog(@"Video File end size: %lu", (unsigned long)[finalResult length]);
    return finalResult;
}


+(NSData *)gzipInflate:(NSData*)data
{
    if(!COMPRESSING) return data;

    // Write decrypted and decompressed output.
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}

+(NSString*) removeAllNonNumbersFromString:(NSString*)string {
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
	NSString* simpleNumber = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
	return simpleNumber;
}


#pragma mark - Parse Functions -

+(Channel*)checkIfChannelList:(NSArray*)list containsChannel:(Channel*)channel {
	for (Channel* listChannel in list) {
		if([listChannel.parseChannelObject.objectId isEqualToString: channel.parseChannelObject.objectId]){
			return listChannel;
		}
	}
	return nil;
}

+(PFObject*)checkIfObjectsList:(NSArray*)list containsObject:(PFObject*)object {
	for (PFObject* obj in list) {
		if([obj.objectId isEqualToString:object.objectId]){
			return obj;
		}
	}
	return nil;
}

-(NSMutableArray *)sessionTasks {
	if (!_sessionTasks) {
		_sessionTasks = [[NSMutableArray alloc] init];
	}
	return _sessionTasks;
}

@end
