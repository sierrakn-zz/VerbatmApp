//
//  feedDisplayTVC.h
//  Verbatm
//
//  Created by Iain Usiri on 8/28/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedVCDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

@end

@interface FeedVC : UIViewController

@property (strong, nonatomic) id<FeedVCDelegate> delegate;

// animates the fact that a recent POV is publishing
-(void) showPOVPublishingWithUserName: (NSString*)userName andTitle: (NSString*) title andCoverPic: (UIImage*) coverPic
					andProgressObject:(NSProgress *)publishingProgress;



-(void) offScreen;//told when it's off screen to stop videos
-(void)onScreen;

@end
