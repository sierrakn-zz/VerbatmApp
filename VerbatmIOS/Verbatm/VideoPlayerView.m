//
//  VideoPlayer.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/10/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "VideoPlayerView.h"
#import "VideoDownloadManager.h"
#import "LoadingIndicator.h"
#import "Icons.h"
#import "SizesAndPositions.h"

@interface VideoPlayerView()

#pragma mark AVPlayer properties
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;
@property (nonatomic,strong) AVPlayerLayer* playerLayer;
@property (strong, readwrite) AVMutableComposition* fusedVideoAsset;

#pragma mark Video Playback properties
@property (nonatomic, readwrite) BOOL videoLoading;
@property (nonatomic, readwrite) BOOL isMuted;
@property (nonatomic, readwrite) BOOL isVideoPlaying; //tells you if the video is in a playing state
@property (strong) NSTimer *ourTimer;//keeps calling continue

@property (nonatomic) BOOL shouldPlayOnLoad;

@property (strong, nonatomic) id playbackLikelyToKeepUpKVOToken;

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;


#define VIDEO_LOADING_ICON_SIZE 50

@end

@implementation VideoPlayerView

-(instancetype)initWithFrame:(CGRect)frame {
	if((self  = [super initWithFrame:frame])) {
		self.fusedVideoAsset = nil;
		self.repeatsVideo = NO;
		self.videoLoading = NO;
		self.shouldPlayOnLoad = NO;
		self.clearsContextBeforeDrawing = YES;
		self.isMuted = false;
		[self setBackgroundColor:[UIColor clearColor]];

	}
	return self;
}

#pragma mark - Format subviews -

//make sure the sublayer resizes with the view screen
- (void)layoutSubviews {
	if (self.playerLayer) {
		self.playerLayer.frame = self.bounds;
	}
}

#pragma mark - Prepare Video Asset -

-(void)prepareVideoFromAsset: (AVAsset*) asset{
	if (!asset) return;

	self.videoLoading = YES;
	NSArray *keys = @[@"playable",@"tracks",@"duration"];

	[asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self prepareVideoFromPlayerItem:[AVPlayerItem playerItemWithAsset:asset]];
		});
	}];
}

-(void)prepareVideoFromURL: (NSURL*) url{
	if (!url) return;

	self.videoLoading = YES;
	[self prepareVideoFromAsset:[AVAsset assetWithURL: url]];
}

-(void) prepareVideoFromPlayerItem:(AVPlayerItem*)playerItem {
	self.videoLoading = YES;
	if (self.playerItem) {
		[self removePlayerItemObservers];
		self.playerItem = nil;
	}
	self.playerItem = playerItem;
	[self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
	[self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
	[self initiateVideo];
}

//this function should be called on the main thread
-(void) initiateVideo {
	if (self.isVideoPlaying) {
		return;
	}
	self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
	self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
	// Create an AVPlayerLayer using the player
	if(self.playerLayer)[self.playerLayer removeFromSuperlayer];
	self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	self.playerLayer.frame = self.bounds;
	self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	[self.playerLayer removeAllAnimations];
	self.player.muted = self.isMuted;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:[self.player currentItem]];

	dispatch_async(dispatch_get_main_queue(), ^{
		if(self.playerLayer) [self.layer addSublayer:self.playerLayer];
	});
	if (self.shouldPlayOnLoad) [self playVideo];
}

#pragma mark - Observe player item status -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context {
	if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
		if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
			[self.loadingIndicator stopAnimating];
			self.videoLoading = NO;
			if (self.shouldPlayOnLoad) [self playVideo];
		} else if (self.playerItem.status == AVPlayerItemStatusFailed) {
			[[Crashlytics sharedInstance] recordError:self.playerItem.error];
			if (self.videoLoading) {
				[self.loadingIndicator stopAnimating];
				self.videoLoading = NO;
			}
		}
	}
	if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
		if (self.playerItem.playbackLikelyToKeepUp) {
			[self.loadingIndicator stopAnimating];
			self.videoLoading = NO;
			if (self.shouldPlayOnLoad) {
//				NSLog(@"play back will keep up");
				[self playVideo];
			} else {
//				NSLog(@"Ready but not playing.");
			}
		} else if (self.shouldPlayOnLoad) {
//			NSLog(@"play back will not keep up");
			[self.loadingIndicator startAnimating];
			self.videoLoading = YES;
		}
	}
}

#pragma mark - Play video -

-(void)playVideo {
	self.shouldPlayOnLoad = YES;
	if (self.videoLoading) [self.loadingIndicator startAnimating];
	if (self.player && self.playerLayer) {
		[self.player play];
		self.isVideoPlaying = YES;
	}
}

// Notifies that video has ended so video can replay
-(void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *playerItem = [notification object];
	[playerItem seekToTime:kCMTimeZero];
	//todo: repeatsVideo not set correctly
//	if (self.repeatsVideo) {
//
//	} else {
//		NSLog(@"Video not repeating.");
//	}
}

// Pauses player
-(void)pauseVideo {
	if (self.player) {
		[self.player pause];
	}
	self.isVideoPlaying = NO;
	self.shouldPlayOnLoad = NO;
}

#pragma mark - Mute / Unmute -

-(void) muteVideo: (BOOL)mute {
	if(self.player) {
		[self.player setMuted:mute];
	}
	self.isMuted = mute;
}

-(void)fastForwardVideoWithRate: (NSInteger) rate{
	if(self.playerItem) {
		if([self.playerItem canPlayFastForward]) self.playerLayer.player.rate = rate;
	}
}

-(void)rewindVideoWithRate:(NSInteger) rate {
	if(self.playerItem) {
		if([self.playerItem canPlayFastReverse] && self.playerLayer.player.rate) self.playerLayer.player.rate = -rate;
	}
}

#pragma mark - Clean up video assets -

//cleans up video and all other helper objects
//this is called right before the view is removed from the screen
-(void) stopVideo {
	[self removePlayerItemObservers];
	if(self.player) [self.player pause];
	self.shouldPlayOnLoad = NO;
	self.videoLoading = NO;
	if(self.loadingIndicator) [self.loadingIndicator stopAnimating];

	for (int i = 0; i < self.subviews.count; i++) {
		[self.subviews[i] removeFromSuperview];
	}

	for(int i =0; i < self.layer.sublayers.count; i++){
		[self.layer.sublayers[i] removeFromSuperlayer];
	}

	if(self.playerLayer)[self.playerLayer removeFromSuperlayer];
	self.loadingIndicator = nil;
	self.playerItem = nil;
	self.player = nil;
	self.playerLayer = nil;
	self.isVideoPlaying = NO;
	if(self.ourTimer) [self.ourTimer invalidate];
	self.ourTimer = nil;
}

-(void) removePlayerItemObservers {
	@try {
		[self.playerItem removeObserver:self forKeyPath:@"status"];
	} @catch(id anException) {
		//do nothing, obviously they weren't attached because an exception was thrown
	}
	@try {
		[self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
	} @catch(id anException) {
		//do nothing, obviously they weren't attached because an exception was thrown
	}
}

#pragma mark - Lazy Instantation -

-(UIActivityIndicatorView *) loadingIndicator {
	if(!_loadingIndicator) {
		_loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
		_loadingIndicator.center = self.center;
		_loadingIndicator.hidesWhenStopped = YES;
		[self addSubview:_loadingIndicator];
	}
	[self bringSubviewToFront:_loadingIndicator];
	return _loadingIndicator;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self stopVideo];
}

@end