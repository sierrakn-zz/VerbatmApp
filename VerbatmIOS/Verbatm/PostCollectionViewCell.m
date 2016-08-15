//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Like_BackendManager.h"
#import <Parse/PFObject.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PublishingProgressView.h"
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"
#import "SizesAndPositions.h"
#import "UIView+Effects.h"
#import "Icons.h"

@interface PostCollectionViewCell () <PostViewDelegate>

@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@property (nonatomic) BOOL footerUp;
@property (nonatomic) PublishingProgressView * publishingProgressView;
@property (nonatomic) BOOL hasPublishingView;
@property (nonatomic) BOOL hasShadow;

@property (nonatomic) UIImageView * tapToExitNotification;
//temp
@property (nonatomic) UIView * dot;

@property (nonatomic) UIButton *smallLikeButton;
@property (nonatomic) UIButton *smallShareButton;
@property (nonatomic) UILabel * numLikeLabel;
@property (nonatomic) UILabel * numSharesLabel;

@property (nonatomic) NSNumber * numLikes;
@property (nonatomic) NSNumber * numShares;

#define POSTVIEW_FRAME ((self.inSmallMode) ? CGRectMake(0.f, SMALL_SQUARE_LIKESHAREBAR_HEIGHT, self.frame.size.width, self.frame.size.height - SMALL_SQUARE_LIKESHAREBAR_HEIGHT) : self.bounds)

#define LIKE_BUTTION_SIZE 25.f
#define SHARE_BUTTION_SIZE 20.f

#define LIKE_BUTTON_WALL_OFFSET 5.f
#define SMALL_ICON_SPACING 5.f
@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    
	self = [super initWithFrame:frame];
	if (self) {
        
		self.backgroundColor = [UIColor clearColor];
		[self clearViews];
		[self setClipsToBounds:NO];
        [self.layer setCornerRadius:POST_VIEW_CORNER_RADIUS];

    }
    
	return self;
    
}

-(void) clearViews {
	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
	}

	[self removePublishingProgress];
    
	@autoreleasepool {
        [self.numSharesLabel removeFromSuperview];
        [self.smallShareButton removeFromSuperview];
        [self.numLikeLabel removeFromSuperview];
        [self.smallLikeButton removeFromSuperview];
        
        self.numSharesLabel = nil;
        self.smallShareButton = nil;
        self.numLikeLabel = nil;
        self.smallLikeButton = nil;
		self.currentPostView = nil;
		self.currentPostActivityObject = nil;
		self.postBeingPresented = nil;
	}
    
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
}

-(void) layoutSubviews {
	self.currentPostView.frame = POSTVIEW_FRAME;
	if(!self.hasShadow){
		//[self addShadowToView];
		self.hasShadow = YES;
	}
}

-(void)presentPublishingView{
    if(self.presentingTapToExitNotification){
        [self insertSubview:self.publishingProgressView belowSubview:self.tapToExitNotification];
    }else{
        [self addSubview:self.publishingProgressView];
    }
	self.hasPublishingView = YES;
}

-(void)removePublishingProgress{
	if(_publishingProgressView != nil){
		[self.publishingProgressView removeFromSuperview];
		@autoreleasepool {
			_publishingProgressView = nil;
		}
	}
}

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up {

	[self removePublishingProgress];
	self.hasPublishingView = NO;
	self.footerUp = up;
	self.currentPostActivityObject = pfActivityObj;
    
    PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
    __weak PostCollectionViewCell *weakSelf = self;
    
    [post fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        weakSelf.numLikes = object[POST_NUM_LIKES];
        weakSelf.numShares = object[POST_NUM_REBLOGS];
        
        
        [Page_BackendObject getPagesFromPost:object andCompletionBlock:^(NSArray * pages) {
            
            weakSelf.currentPostView = [[PostView alloc] initWithFrame:POSTVIEW_FRAME
                                          andPostChannelActivityObject:pfActivityObj small:weakSelf.inSmallMode andPageObjects:pages];
            
            if(weakSelf.inSmallMode)[weakSelf.currentPostView muteAllVideos:YES];
            NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
            if (weakSelf.isOnScreen) {
                [weakSelf.currentPostView postOnScreen];
            } else if (weakSelf.isAlmostOnScreen) {
                [weakSelf.currentPostView postAlmostOnScreen];
            } else {
                [weakSelf.currentPostView postOffScreen];
            }
            weakSelf.currentPostView.delegate = weakSelf;
            weakSelf.currentPostView.listChannel = channelForList;
            
            if(self.tapToExitNotification){
                [weakSelf insertSubview:weakSelf.currentPostView belowSubview:self.tapToExitNotification];
            }else{
                [weakSelf addSubview: weakSelf.currentPostView];
            }
            weakSelf.currentPostView.inSmallMode = weakSelf.inSmallMode;
            
            
            
            if(weakSelf.inSmallMode){
                [weakSelf.currentPostView checkIfUserHasLikedThePost];
            }else{
                
                [weakSelf.currentPostView createLikeAndShareBarWithNumberOfLikes:weakSelf.numLikes numberOfShares:weakSelf.numShares
                                                                   numberOfPages:numberOfPages
                                                           andStartingPageNumber:@(1)
                                                                         startUp:up
                                                                withDeleteButton:withDelete];
                [weakSelf.currentPostView addCreatorInfo];
                
            }
            [weakSelf bringSubviewToFront:weakSelf.dot];
        }];
    }];
    
    
}

-(void) showWhoLikesThePost:(PFObject *) post{
	[self.cellDelegate showWhoLikesThePost:post];
}


-(void)setInSmallMode:(BOOL)inSmallMode{
	_inSmallMode = inSmallMode;
	if(_currentPostView){
		_currentPostView.inSmallMode = inSmallMode;
	}
}

-(void) almostOnScreen {
	self.isAlmostOnScreen = YES;
	if(!self.hasPublishingView){
		if(self.currentPostView){
			[self.currentPostView postAlmostOnScreen];
		}
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	self.isAlmostOnScreen = NO;
	if(!self.hasPublishingView){
		if(self.currentPostView) {
			[self.currentPostView postOnScreen];
		}
	}
}

-(void) offScreen {
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
	[self.currentPostView postOffScreen];
}

-(void)removeDot{
    if(self.dot){
        [self.dot removeFromSuperview];
        self.dot = nil;
    }
}

-(void)addDot{
    if(self.dot){
        [self bringSubviewToFront:self.dot];
    }else{
        self.dot = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 15.f)/2.f,  -20.f, 15.f, 15.f)];
        [self.dot setBackgroundColor:[UIColor colorWithRed:0.f/255.f  green:191.f/255.f blue:255.f/255.f  alpha:1.f]];
        [self addSubview:self.dot];
        [self.dot.layer setCornerRadius:7.5];
    }
}

-(void)presentTapToExitNotification{
    self.tapToExitNotification = [[UIImageView alloc] initWithImage:[UIImage imageNamed:TAP_TO_EXIT_FULLSCREENPOV_INSTRUCTION]];
    self.tapToExitNotification.frame = self.bounds;
    [self addSubview:self.tapToExitNotification];
    self.presentingTapToExitNotification = YES;
}

-(void)removeTapToExitNotification{
    if(self.tapToExitNotification){
        [self.tapToExitNotification removeFromSuperview];
        self.tapToExitNotification = nil;
        [self.cellDelegate justRemovedTapToExitNotification];
        self.presentingTapToExitNotification = NO;
    }
}


-(void)likeButtonPressed{
    [self.currentPostView likeButtonPressed];
}

-(void)shareButtonPressed{
    [self.currentPostView shareButtonPressed];
}

#pragma mark - Post view delegate -

-(void)presentSmallLikeButton{
    //create LikeButton
    CGFloat likeButtonY =  2.5;
    CGFloat shareButtonY = 5.f;
    CGRect likeButtonFrame =  CGRectMake(LIKE_BUTTON_WALL_OFFSET,
                                         likeButtonY,
                                         LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE);
    if(!self.smallLikeButton){
        self.smallLikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallLikeButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.smallLikeButton setFrame:likeButtonFrame];
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
        [self.smallLikeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.smallLikeButton];
    }
    
    if(!self.numLikeLabel){
        self.numLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.smallLikeButton.frame.origin.x + self.smallLikeButton.frame.size.width + SMALL_ICON_SPACING, likeButtonY, LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE)];
        [self.numLikeLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.numLikeLabel];
    }
    
    [self.numLikeLabel setText:[self.numLikes stringValue]];
    
    if(!self.smallShareButton){
        self.smallShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smallShareButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.smallShareButton setFrame:CGRectMake(self.numLikeLabel.frame.origin.x + self.numLikeLabel.frame.size.width + SMALL_ICON_SPACING, shareButtonY, SHARE_BUTTION_SIZE, SHARE_BUTTION_SIZE)];
        [self.smallShareButton setImage:[UIImage imageNamed:SMALL_SHARE_ICON] forState:UIControlStateNormal];
        [self.smallShareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchDown];
        [self addSubview:self.smallShareButton];
    }
    
    if(!self.numSharesLabel){
        self.numSharesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.smallShareButton.frame.origin.x + self.smallShareButton.frame.size.width + SMALL_ICON_SPACING, shareButtonY, LIKE_BUTTION_SIZE, LIKE_BUTTION_SIZE)];
        [self.numSharesLabel setTextColor:[UIColor whiteColor]];
        [self addSubview:self.numSharesLabel];
    }
    
    [self.numSharesLabel setText:[self.numLikes stringValue]];

}
-(void)updateSmallLikeButton:(BOOL)isLiked{
    NSInteger numLikes;
    if(isLiked){
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_PRESSED ] forState:UIControlStateNormal];
        numLikes = [self.numLikes integerValue] + 1;
    }else{
        [self.smallLikeButton setImage:[UIImage imageNamed:LIKE_ICON_UNPRESSED] forState:UIControlStateNormal];
        numLikes = (([self.numLikes integerValue]-1) < 0) ? 0 : ([self.numLikes integerValue]-1);
    }
    
    self.numLikes = [NSNumber numberWithInteger:numLikes];
    if(self.numLikeLabel)[self.numLikeLabel setText:[self.numLikes stringValue]];
}


-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post {
	[self.cellDelegate shareOptionSelectedForParsePostObject:post];
}

-(void) channelSelected:(Channel *) channel {
	[self.cellDelegate channelSelected:channel];
}

-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post reblogged: (BOOL)reblogged {
	[self.cellDelegate deleteButtonSelectedOnPostView:postView withPostObject:post
							andPostChannelActivityObj:self.currentPostActivityObject reblogged:reblogged];
}

-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post {
	[self.cellDelegate flagOrBlockButtonSelectedOnPostView:postView withPostObject:post];
}

-(PublishingProgressView *)publishingProgressView{
	if(!_publishingProgressView){
		_publishingProgressView = [[PublishingProgressView alloc] initWithFrame:POSTVIEW_FRAME];
	}
	return _publishingProgressView;
}

-(void)dealloc{
}

@end
