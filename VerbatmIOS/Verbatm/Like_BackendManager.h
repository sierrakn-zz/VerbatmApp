//
//  Like_BackendManager.h
//  Verbatm
//
//  Created by Iain Usiri on 3/20/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import "PromiseKit/PromiseKit.h"

@interface Like_BackendManager : NSObject

+(void) currentUserLikePost:(PFObject *) postParseObject;
+(void) currentUserStopLikingPost:(PFObject *) postParseObject;

//tests to see if the logged in user likes this post

+(void) currentUserLikesPost:(PFObject *) postParseObject withCompletionBlock:(void(^)(bool))block;

+ (void)getUsersWhoLikePost:(PFObject *) postParseObject withCompletionBlock:(void(^)(NSArray *))block;

+(void) deleteLikesForPost:(PFObject*) postParseObject withCompletionBlock:(void(^)(BOOL)) block;

@end
