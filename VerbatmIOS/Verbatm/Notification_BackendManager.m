//
//  Notification_BackendManager.m
//  Verbatm
//
//  Created by Iain Usiri on 7/5/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Notification_BackendManager.h"
#import <Parse/PFQuery.h>
#import "ParseBackendKeys.h"

@interface Notification_BackendManager ()
#define LOAD_MAX_AMOUNT 20
@end

@implementation Notification_BackendManager



+(void)createNotificationWithType:(NotificationType) notType receivingUser:(PFUser *) receivingUser relevantPostObject:(PFObject *) post {
    
    NSNumber * notificationType = [NSNumber numberWithInteger:notType];
    PFObject * notificationObject = [PFObject objectWithClassName:NOTIFICATION_PFCLASS_KEY];
    
    [notificationObject setValue:[NSNumber numberWithBool:YES] forKey:NOTIFICATION_IS_NEW];
    [notificationObject setValue:[PFUser currentUser] forKey:NOTIFICATION_SENDER];
    [notificationObject setValue:receivingUser forKey:NOTIFICATION_RECEIVER];
    if(post)[notificationObject setValue:post forKey:NOTIFICATION_POST];
    [notificationObject setValue:notificationType forKey:NOTIFICATION_TYPE];
    [notificationObject saveInBackground];
}

+(void)getNotificationsForUserAfterDate:(NSData *) afterDate withCompletionBlock:(void(^)(NSArray*)) block {
    
    
    PFQuery * query = [PFQuery queryWithClassName:NOTIFICATION_PFCLASS_KEY];
    [query orderByAscending:@"createdAt"];
    [query setLimit:LOAD_MAX_AMOUNT];
    if(afterDate)[query whereKey:@"createdAt" lessThan:afterDate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!objects && error){
            NSLog(@"Error loading objects");
        }
        block(objects);
    }];
}


@end
