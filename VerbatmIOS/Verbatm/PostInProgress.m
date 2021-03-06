//
//  UserPinchViews.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "Notifications.h"
#import "PostInProgress.h"
#import "PromiseKit/PromiseKit.h"

@interface PostInProgress()

//array of NSData convertible to PinchView
@property (strong, nonatomic) NSMutableArray* pinchViewsAsData;

#define TITLE_KEY @"user_title"
#define COVER_PHOTO_KEY @"user_cover_photo"
#define PINCHVIEWS_KEY @"user_pinch_views"

@end

@implementation PostInProgress

+ (instancetype)sharedInstance {
	static PostInProgress *_sharedInstance = nil;
	static dispatch_once_t onceSecurePredicate;
	dispatch_once(&onceSecurePredicate,^{
		_sharedInstance = [[PostInProgress alloc] init];
	});

	return _sharedInstance;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(userHasSignedOut)
													 name:NOTIFICATION_USER_SIGNED_OUT
												   object:nil];
	}
	return self;
}

-(void) userHasSignedOut {
	self.pinchViewsAsData = nil;
	self.pinchViews = nil;
	self.title = nil;
}

-(void) addTitle: (NSString*) title {
	self.title = title;
	[[NSUserDefaults standardUserDefaults] setObject:self.title forKey:TITLE_KEY];
}

//adds pinch view and automatically saves pinchViews
-(void) addPinchView:(PinchView*)pinchView atIndex:(NSInteger) index {
	if (!pinchView) {
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {

			if (index > self.pinchViewsAsData.count || index < 0) {
				return;
			}

			NSData* pinchViewData = [self convertPinchViewToNSData:pinchView];
			[self.pinchViewsAsData insertObject:pinchViewData atIndex:index];
			[self.pinchViews insertObject:pinchView atIndex:index];

			//todo: delete?
//			//call on main queu because we are creating and formating uiview
//			dispatch_async(dispatch_get_main_queue(), ^{
//				//Insert copy of pinch view not pinch view itself
//				[self.pinchViews insertObject:[self convertNSDataToPinchView:pinchViewData] atIndex:index];
//			});

			[[NSUserDefaults standardUserDefaults]
			 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
		}
	});
}

//removes pinch view and saves pinchViews
-(void) removePinchViewAtIndex: (NSInteger) index {
	@synchronized(self) {
		if(index >= self.pinchViews.count || index < 0) {
			return;
		}

		[self.pinchViews removeObjectAtIndex:index];
		[self.pinchViewsAsData removeObjectAtIndex:index];
        [[NSUserDefaults standardUserDefaults]
         setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	}
}

-(void) removePinchViewAtIndex:(NSInteger)index andReplaceWithPinchView:(PinchView *)newPinchView {
	if (!newPinchView) {
		return;
	}
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		@synchronized(self) {
			if (index >= self.pinchViews.count || index < 0) {
				return;
			}
			NSData* pinchViewData = [self convertPinchViewToNSData: newPinchView];
			[self.pinchViews replaceObjectAtIndex:index withObject: newPinchView];
			[self.pinchViewsAsData replaceObjectAtIndex:index withObject: pinchViewData];
			[[NSUserDefaults standardUserDefaults]
			 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];

		}
	});
}

-(void) swapPinchViewsAtIndex:(NSInteger)index1 andIndex:(NSInteger)index2 {
	@synchronized(self) {
		if (index1 < 0 || index1 >= self.pinchViews.count || index2 < 0 || index2 >= self.pinchViews.count) {
			return;
		}
		PinchView *pinchView1 = self.pinchViews[index1];
		PinchView *pinchView2 = self.pinchViews[index2];
		[self.pinchViews replaceObjectAtIndex: index1 withObject: pinchView2];
		[self.pinchViews replaceObjectAtIndex: index2 withObject: pinchView1];

		// swap data
		NSData* pinchViewData1 = self.pinchViewsAsData[index1];
		NSData* pinchViewData2 = self.pinchViewsAsData[index2];
		[self.pinchViewsAsData replaceObjectAtIndex: index1 withObject: pinchViewData2];
		[self.pinchViewsAsData replaceObjectAtIndex: index2 withObject: pinchViewData1];
		[[NSUserDefaults standardUserDefaults]
		 setObject:self.pinchViewsAsData forKey:PINCHVIEWS_KEY];
	}
}

//loads pinchviews from user defaults
-(void) loadPostFromUserDefaults {
	self.title = [[NSUserDefaults standardUserDefaults]
				  objectForKey:TITLE_KEY];
	NSArray* pinchViewsData = [[NSUserDefaults standardUserDefaults]
							   objectForKey:PINCHVIEWS_KEY];
	@synchronized(self) {
        __weak PostInProgress * weakSelf = self;
		self.pinchViewsAsData = [[NSMutableArray alloc] initWithArray:pinchViewsData copyItems:NO];
		for (int i = 0; i < pinchViewsData.count; i++) {
			NSData* data = pinchViewsData[i];
			PinchView* pinchView = [weakSelf convertNSDataToPinchView:data];
			if ([pinchView isKindOfClass:[VideoPinchView class]]) {
				[(VideoPinchView*)pinchView loadAVURLAssetFromPHAsset].then(^(AVURLAsset* video) {
					[weakSelf.pinchViews insertObject:pinchView atIndex:i];
				});
			} else if([pinchView isKindOfClass:[CollectionPinchView class]] && pinchView.containsVideo) {
				CollectionPinchView *collectionPinchView = (CollectionPinchView*)pinchView;
				NSMutableArray *loadVideoPromises = [[NSMutableArray alloc] init];
				for (VideoPinchView *videoPinchView in collectionPinchView.videoPinchViews) {
					[loadVideoPromises addObject:[videoPinchView loadAVURLAssetFromPHAsset]];
				}
				PMKWhen(loadVideoPromises).then(^(NSArray *videoAssets) {
					[weakSelf.pinchViews insertObject:collectionPinchView atIndex:i];
				});
			} else {
				[weakSelf.pinchViews addObject:pinchView];
			}
		}
	}
}

//removes all pinch views
-(void) clearPostInProgress {
	//thread safety
	@synchronized(self) {
		[self.pinchViews removeAllObjects];
		[self.pinchViewsAsData removeAllObjects];
	}
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:TITLE_KEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:COVER_PHOTO_KEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:PINCHVIEWS_KEY];
}

#pragma mark - Converting pinch views to data and back -

-(NSData*) convertPinchViewToNSData:(PinchView*)pinchView {
	return [NSKeyedArchiver archivedDataWithRootObject:pinchView];
}

-(PinchView*) convertNSDataToPinchView:(NSData*)data {
	return (PinchView*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
}

#pragma mark - Lazy Instantiation -

-(NSMutableArray*) pinchViews {
	if(!_pinchViews) _pinchViews = [[NSMutableArray alloc] init];
	return _pinchViews;
}

-(NSMutableArray*) pinchViewsAsData {
	if(!_pinchViewsAsData) _pinchViewsAsData = [[NSMutableArray alloc] init];
	return _pinchViewsAsData;
}

@end
