//
//  InviteFriendCell.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/9/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriendCell : UITableViewCell

@property (nonatomic) BOOL buttonIsSelected;

-(void) toggleButton;

-(void) setContactName: (NSString*)name andPhoneNumber:(NSString*)phoneNumber;

@end
