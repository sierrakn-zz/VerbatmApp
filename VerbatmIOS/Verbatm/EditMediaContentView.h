//
//  verbatmCustomImageScrollView.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayerView.h"
#import "PinchView.h"


@protocol EditContentViewDelegate <NSObject>
-(void) textIsEditing;
-(void) textDoneEditing;
@end

@interface EditMediaContentView : UIView

@property (nonatomic, strong) id<EditContentViewDelegate> delegate;
@property (nonatomic, strong) VideoPlayerView * videoView;
@property (nonatomic, strong) PinchView * pinchView;

//this should be set when the edit content view is created
//it allows us to make the pan gestures interact
@property (nonatomic, weak) UIScrollView * povViewMasterScrollView;

//only loads the video onto the screen. You must call onScreen for the video to play
-(void) displayVideo: (NSMutableArray *) videoAssetArray;

//passes it an array of UIImages to display
-(void)displayImages: (NSArray*) filteredImages atIndex:(NSInteger)index;

-(void)createTextCreationButton;

-(void) setText: (NSString*) text andTextViewYPosition: (CGFloat) yPosition;

-(NSString*) getText;

-(NSNumber*) getTextYPosition;

-(NSInteger) getFilteredImageIndex;


//call before removing the view our ecv
//saves the content into the pinchview
-(void)exitingECV;


-(void)offScreen;//removes video 
-(void)onScreen;//plays video
-(void)almostOnScreen;//stages video
@end