
//
//  Post.m
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.

#import "CollectionPinchView.h"

#import "Like_BackendManager.h"

#import "Post_BackendObject.h"
#import "Post_Channel_RelationshipManager.h"
#import "PinchView.h"
#import "ParseBackendKeys.h"

#import <Parse/PFObject.h>
#import <Parse/PFUser.h>
#import <Parse/PFQuery.h>

#import "Page_BackendObject.h"

#import "Share_BackendManager.h"

#import "VideoPinchView.h"

@interface Post_BackendObject ()
@property (nonatomic) NSMutableArray * pageArray;
@end

@implementation Post_BackendObject


-(instancetype)init{
	self = [super init];
	if(self){
		self.pageArray = [[NSMutableArray alloc] init];
	}
	return self;
}

-(PFObject *) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel{
	PFObject * newPostObject = [PFObject objectWithClassName:POST_PFCLASS_KEY];
	[newPostObject setObject:channel.parseChannelObject forKey:POST_CHANNEL_KEY];
	[newPostObject setObject:[NSNumber numberWithInteger:0] forKey:POST_NUM_LIKES];
	[newPostObject setObject:[NSNumber numberWithInteger:0] forKey:POST_NUM_REBLOGS];
	[newPostObject setObject:[PFUser currentUser] forKey:POST_ORIGINAL_CREATOR_KEY];
	[newPostObject setObject:[NSNumber numberWithInteger:pinchViews.count] forKey:POST_SIZE_KEY];
	[newPostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
		if(succeeded){
			Page_BackendObject * newPage = [[Page_BackendObject alloc] init];
			AnyPromise *storePagePromise = [newPage savePageWithIndex:0 andPinchView:pinchViews[0] andPost:newPostObject];
			[self.pageArray addObject:newPage];

			for (int i = 1; i< pinchViews.count; i++) {
				storePagePromise = storePagePromise.then(^(PFObject*pageObject) {
					Page_BackendObject * newPage = [[Page_BackendObject alloc] init];
					[self.pageArray addObject:newPage];
					return [newPage savePageWithIndex:i andPinchView:pinchViews[i] andPost:newPostObject];
				});
			}

			storePagePromise.then(^(PFObject *pageObject) {
			});
		}
	}];

	return newPostObject;
}

//todo: make sure post is not visible while media deleting
/* Remove pages (which will remove media), then remove post.
   Also delete like and share objects associated with post */
+(void) deletePost: (PFObject *)post {
	[Post_Channel_RelationshipManager deleteChannelRelationshipsForPost:post withCompletionBlock:^(bool success) {
		if (!success) {
			NSLog(@"Error deleting channel relationships");
		}
	}];
	[Page_BackendObject deletePagesInPost:post];
	[Like_BackendManager deleteLikesForPost:post withCompletionBlock:^(BOOL success) {
		if (!success) {
			NSLog(@"Error deleting likes");
		}
	}];
	[Share_BackendManager deleteSharesForPost:post withCompletionBlock:^(BOOL success) {
		if (!success) {
			NSLog(@"Error deleting shares");
		}
	}];
}

+(void)markPostAsFlagged:(PFObject *)flaggedPost {
    if(flaggedPost){
        [flaggedPost setValue:[NSNumber numberWithBool:YES] forKey:POST_FLAGGED_KEY];
        [flaggedPost saveInBackground];
		PFObject *newFlagObject = [PFObject objectWithClassName:FLAG_PFCLASS_KEY];
		[newFlagObject setObject:[PFUser currentUser] forKey:FLAG_USER_KEY];
		[newFlagObject setObject:flaggedPost forKey:FLAG_POST_FLAGGED_KEY];
		[newFlagObject saveInBackground];
		//todo: send us an email that it was flagged
    }
}


@end
