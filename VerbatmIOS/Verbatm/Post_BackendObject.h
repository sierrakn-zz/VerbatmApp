//
//  Post.h
//  Verbatm
//
//  Created by Iain Usiri on 1/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"
/*
    This is a wraper class to support mangaging the Post PFObject
 */


@interface Post_BackendObject : NSObject

-(PFObject * ) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel;

+(void) deletePost: (PFObject *)post withCompletionBlock:(void(^)(void))block;

+(void) markPostAsFlagged:(PFObject *) flaggedPost;

@end
