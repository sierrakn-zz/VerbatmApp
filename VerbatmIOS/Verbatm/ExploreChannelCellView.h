//
//  ExploreChannelCellView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 4/15/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel.h"
#import <UIKit/UIKit.h>

@protocol ExploreChannelCellViewDelegate <NSObject>

-(void) channelFollowed:(Channel *)channel;
-(void) channelSelected: (Channel*)channel;

@end

@interface ExploreChannelCellView : UITableViewCell

@property (weak, nonatomic) id<ExploreChannelCellViewDelegate> delegate;
@property (weak, readonly) Channel *channelBeingPresented;

-(void)presentChannel:(Channel *) channel;

// Makes cell ready to present new channel
-(void)clearViews;

-(void)onScreen;

-(void)almostOnScreen;

-(void)offScreen;

@end
