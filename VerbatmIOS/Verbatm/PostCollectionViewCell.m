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
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"

@interface PostCollectionViewCell () <PostViewDelegate>

@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;
@property (nonatomic) BOOL isOnScreen;
@property (nonatomic) BOOL isAlmostOnScreen;

@property (nonatomic) BOOL footerUp;
@property (nonatomic) UIView * publishingView;
@property (nonatomic) BOOL hasPublishingView;

@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if (self) {
		[self clearViews];
	}
	return self;
}

-(void) clearViews {
	if (self.currentPostView) {
		[self.currentPostView removeFromSuperview];
		[self.currentPostView clearPost];
	}
    
    if(self.publishingView){
        [self.publishingView removeFromSuperview];
        self.publishingView = nil;
    }
	self.currentPostView = nil;
	self.currentPostActivityObject = nil;
	self.postBeingPresented = nil;
	self.isOnScreen = NO;
	self.isAlmostOnScreen = NO;
}

-(void) layoutSubviews {
	self.currentPostView.frame = self.bounds;
}

-(void)presentPublishingView:(UIView *)publishingView{
    self.publishingView = publishingView;
    [self addSubview:self.publishingView];
    self.hasPublishingView = YES;
}




-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up {
    self.hasPublishingView = NO;
    self.footerUp = up;
	self.currentPostActivityObject = pfActivityObj;
	PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
	[Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
		self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
								andPostChannelActivityObject:pfActivityObj small:NO andPageObjects:pages];

		NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
		if (self.isOnScreen) {
			[self.currentPostView postOnScreen];
		} else if (self.isAlmostOnScreen) {
			[self.currentPostView postAlmostOnScreen];
		} else {
			[self.currentPostView postOffScreen];
		}
		self.currentPostView.delegate = self;
		self.currentPostView.listChannel = channelForList;
		[self addSubview: self.currentPostView];

		AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
		AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
		PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
			NSNumber *numLikes = likesAndShares[0];
			NSNumber *numShares = likesAndShares[1];
			[self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
											   numberOfPages:numberOfPages
									   andStartingPageNumber:@(1)
													 startUp:up
											withDeleteButton:withDelete];
			[self.currentPostView addCreatorInfo];
		});
	}];
}

-(void) shiftLikeShareBarDown:(BOOL) down {
    if(self.hasPublishingView) return;
    
    if (self.currentPostView) {
		[self.currentPostView shiftLikeShareBarDown: down];
	} else {
		self.footerUp = !down;
	}
}

-(void) almostOnScreen {
	self.isAlmostOnScreen = YES;
    if(self.hasPublishingView) return;
	if(self.currentPostView){
		[self.currentPostView postAlmostOnScreen];
	}
}

-(void) onScreen {
	self.isOnScreen = YES;
	self.isAlmostOnScreen = NO;
     if(self.hasPublishingView) return;
	if(self.currentPostView) {
		[self.currentPostView postOnScreen];
	}
}

-(void) offScreen {
	self.isOnScreen = NO;
    if(self.hasPublishingView) return;
	if(self.currentPostView) {
		[self.currentPostView postOffScreen];
	}
}

#pragma mark - Post view delegate -

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

@end
