//
//  FeedProfileListTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/23/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedProfileListProtocol <NSObject>

-(void)goToDiscover;

@end

@interface FeedProfileListTVC : UITableViewController

-(void) refreshListOfContent;

@property (nonatomic, weak) id<FeedProfileListProtocol> delegate;

@end
