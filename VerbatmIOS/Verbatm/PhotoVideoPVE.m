
//
//  v_multiplePhotoVideo.m
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "CollectionPinchView.h"
#import "Durations.h"
#import "Icons.h"
#import "ImagePinchView.h"

#import "LoadingIndicator.h"

#import "Notifications.h"

#import "PhotoPVE.h"
#import "PhotoPveEditView.h"
#import "PhotoVideoPVE.h"

#import "Styles.h"
#import "VideoPVE.h"
#import "VideoPinchView.h"
#import "VideoPveEditingView.h"
@interface PhotoVideoPVE() <UIScrollViewDelegate, PhotoPVETextEntryDelegate>

@property (strong, nonatomic) PhotoPVE* photosView;
@property (nonatomic) CGRect videoAveFrame;
@property (nonatomic) CGRect photoAveFrame;

#pragma mark - In Preview Mode -
@property (strong, nonatomic) CollectionPinchView* pinchView;

// Tells whether should display media in small format
@property (nonatomic) BOOL small;

@end

@implementation PhotoVideoPVE

-(instancetype)initWithFrame:(CGRect)frame small: (BOOL)small {
    self = [super initWithFrame:frame];
    if(self) {
		self.small = small;
		self.inPreviewMode = NO;
		[self initialFormatting];

		self.photosView = [[PhotoPVE alloc] initWithFrame:self.photoAveFrame small:small isPhotoVideoSubview:YES];
		self.photosView.textEntryDelegate = self;
		self.videoView = [[VideoPVE alloc] initWithFrame:self.videoAveFrame isPhotoVideoSubview: YES];
		[self addSubview:self.videoView];
		[self addSubview:self.photosView];
    }
    return self;
}

-(void) displayPhotos:(NSArray*)photos andVideo:(NSURL*)videoURL andVideoThumbnail:(UIImage*)thumbnail {
	self.hasLoadedMedia = YES;
	[self.customActivityIndicator stopCustomActivityIndicator];
	[self.customActivityIndicator removeFromSuperview];
	[self.photosView displayPhotos:photos];
	[self.videoView setThumbnailImage: thumbnail andVideo:videoURL];
	if (self.currentlyOnScreen) {
		[self onScreen];
	}
}

-(instancetype) initWithFrame:(CGRect)frame andPinchView:(CollectionPinchView*) pinchView inPreviewMode: (BOOL) previewMode {
	self = [super initWithFrame:frame];
	if (self) {
		self.hasLoadedMedia = YES;
		self.small = NO;
		self.inPreviewMode = previewMode;
		self.pinchView = pinchView;
		[self initialFormatting];

		self.photosView = [[PhotoPveEditView alloc] initWithFrame:self.photoAveFrame andPinchView:pinchView isPhotoVideoSubview:YES];
		self.photosView.textEntryDelegate = self;
		self.videoView = [[VideoPveEditingView alloc]initWithFrame:self.videoAveFrame
										   andPinchView:pinchView isPhotoVideoSubview:YES];
		
		[self addSubview:self.photosView];
        [self addSubview:self.videoView];
	}
	return self;
}

-(void) initialFormatting {
	[self setBackgroundColor:[UIColor PAGE_BACKGROUND_COLOR]];
	//make sure the video is on repeat
	self.videoView.videoPlayer.repeatsVideo = YES;

	float videoAveHeight = self.frame.size.height/2.f;
	float photoAveHeight = (self.frame.size.height - videoAveHeight);

	self.videoAveFrame = CGRectMake(0, 0, self.frame.size.width, videoAveHeight);
	self.photoAveFrame = CGRectMake(0, videoAveHeight, self.frame.size.width, photoAveHeight);
}

#pragma mark - PhotoAveTextEntry Delegate methods -

-(void) editContentViewTextIsEditing {
    [self.textEntryDelegate editContentViewTextIsEditing_PhotoVideoPVE];
    [self movePhotoPageUp:YES];
}

-(void) editContentViewTextDoneEditing {
    [self.textEntryDelegate editContentViewTextDoneEditing_PhotoVideoPVE];
    [self movePhotoPageUp:NO];
}

-(void)movePhotoPageUp:(BOOL) moveUp {
    if(moveUp){
        [UIView animateWithDuration:PAGE_VIEW_FILLS_SCREEN_DURATION animations:^{
            [self bringSubviewToFront:self.photosView];
            self.photosView.frame = CGRectMake(0, 0, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
    } else {
        [UIView animateWithDuration:PAGE_VIEW_FILLS_SCREEN_DURATION animations:^{
            self.photosView.frame = CGRectMake(0, self.videoView.frame.size.height, self.photosView.frame.size.width, self.photosView.frame.size.height);
        }];
    }
}

-(void)dealloc{
}

#pragma mark - Overriding offscreen/onscreen methods -
-(void)prepareForScreenShot{
    [self.videoView prepareForScreenShot];
}
-(void)offScreen {
	[self.customActivityIndicator stopCustomActivityIndicator];
	self.currentlyOnScreen = NO;
    [self.videoView offScreen];
    [self.photosView offScreen];
}

-(void)onScreen {
	self.currentlyOnScreen = YES;
	if (!self.hasLoadedMedia) {
		[self.customActivityIndicator startCustomActivityIndicator];
		return;
	}
    [self.videoView onScreen];
	[self.photosView onScreen];
}

-(void)almostOnScreen {
    [self.videoView almostOnScreen];
	[self.photosView almostOnScreen];
}

-(void) muteVideo: (BOOL) mute{
	[self.videoView muteVideo: mute];
}

@end
