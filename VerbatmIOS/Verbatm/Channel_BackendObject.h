//
//  Channel_BackendObject.h
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFUser.h>
#import "Channel.h"
@interface Channel_BackendObject : NSObject
-(Channel *) createChannelWithName:(NSString *) channelName;

//this will return null of the channel already exists
//will return the newly created channel otherwise
-(Channel *) createPostFromPinchViews: (NSArray*) pinchViews toChannel: (Channel *) channel
                  withCompletionBlock:(void(^)(PFObject *))block;
//takes a completion block that will be called with
//an nsarray of the channels
+(void) getChannelsForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock;

//gets all the channels on V except the provided user.
//often this will be the current user
+(void) getAllChannelsButNoneForUser:(PFUser *) user withCompletionBlock:(void(^)(NSMutableArray *))completionBlock;


//gets all channels on Verbatm including the current user
+(void) getAllChannelsWithCompletionBlock:(void(^)(NSMutableArray *))completionBlock;

@end
