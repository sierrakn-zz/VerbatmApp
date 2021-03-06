//
//  SelectSharingOption.h
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Shows the user what options they have for sharing
 and allows them to select one.
 What's shown is a logo, company name and a select button.
 */


typedef enum ShareOptions{
    Verbatm = 0,
    TwitterShare = 1,
    Facebook = 2,
    Sms = 3,
    CopyLink = 4,
}ShareOptions;


@protocol SelectSharingOptionProtocol <NSObject>

-(void)shareOptionSelected:(ShareOptions) shareOption;
-(void)shareOptionDeselected:(ShareOptions) shareOption;

@end


@interface SelectSharingOption : UIScrollView

@property (nonatomic, weak) id <SelectSharingOptionProtocol> sharingDelegate;

-(void)unselectAllOptions;

@end
