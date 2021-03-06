//
//  postHolderCollecitonRV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import "PostView.h"

@protocol PostCollectionViewCellDelegate <NSObject>

-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post;
-(void) channelSelected:(Channel *) channel;
-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post andPostChannelActivityObj:(PFObject*)pfActivityObj
							 reblogged:(BOOL)reblogged;
-(void) flagOrBlockButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post;
-(void) showWhoLikesThePost:(PFObject *) post;
-(void)showWhoCommentedOnPost:(PFObject *) post;
-(void)justRemovedTapToExitNotification;
-(void)removePostViewSelected;
-(void)createPostPromptSelected;
@end


typedef enum LastPostType : NSInteger{
    CreateNewPostPrompt = 0,
    PublishingPostPrompt = 1
}LastPostType;

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<PostCollectionViewCellDelegate> cellDelegate;
@property (nonatomic, readonly) PostView *currentPostView;
@property (nonatomic, readonly) PFObject *currentPostActivityObject;
@property (nonatomic, readonly) PFObject *currentPostObject;//the post in the post activity object

@property (nonatomic) BOOL cellHasTapGesture;
@property (nonatomic) BOOL inSmallMode;
@property (nonatomic) BOOL presentingTapToExitNotification;

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete andLikeShareBarUp:(BOOL) up;

-(void) almostOnScreen;
-(void) onScreen;
-(void) offScreen;

-(void) clearViews;
-(void)presentPromptView:(NSNumber *) promptType;
-(void)presentTapToExitNotification;
-(void)removeTapToExitNotification;

-(void)addDot;
-(void)removeDot;
@end
