//
//  PostListVC.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <UIKit/UIKit.h>
#import <Parse/PFUser.h>
#import "PostsQueryManager.h"


@protocol PostListVCProtocol <NSObject>

-(void)noPostFound;
-(void)postsFound;
-(void)cellSelectedAtPostIndex:(NSIndexPath *) cellPath;
-(void)createPostPromptSelected;
-(void)channelSelected:(Channel *) channel;
-(void)removePostViewSelected;
-(void)shareToSmsSelectedToUrl:(NSString *) url;

-(void)showWhoLikedPost:(PFObject*) post;
-(void)showWhoCommentedOnPost:(PFObject *) post;

@end

@interface PostListVC : UICollectionViewController

@property (nonatomic, readonly) NSDate *latestPostSeen;


@property (strong, nonatomic) PostsQueryManager *postsQueryManager;

@property (nonatomic) BOOL isInitiated;

@property (nonatomic, weak) id <PostListVCProtocol> postListDelegate;

@property (nonatomic) BOOL inSmallMode;

@property (nonatomic, readonly) NSMutableArray * parsePostActivityObjects;
@property (nonatomic) BOOL currentlyPublishing;


-(void) display:(Channel*)channelForList withListOwner:(PFUser*)listOwner
isCurrentUserProfile:(BOOL)isCurrentUserProfile
andStartingDate:(NSDate*)date;

// Used when we already have the posts to display
-(void) display:(Channel*)channelForList withListOwner:(PFUser*)listOwner
isCurrentUserProfile:(BOOL)isCurrentUserProfile andStartingDate:(NSDate*)date
withOldParseObjects:(NSMutableArray *)newParseObjects;

-(void) updateInSmallMode: (BOOL) smallMode;

-(void) clearViews;

//marks all posts as off screen
-(void) offScreen;

-(void) refreshPosts;

//moves the tap/share bar up and down over the tab bar
-(void) footerShowing: (BOOL) showing;

-(void) startMonitoringPublishing;
-(NSDate *)creationDateOfLastPostObjectInPostList;
@end
