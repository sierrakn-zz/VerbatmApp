//
//  v_multiVidTextPhoto.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "MultiplePhotoVideoAVE.h"

@interface MultiVidTextPhotoAVE : UIView
-(instancetype)initWithFrame:(CGRect)frame Photos:(NSMutableArray*)photos andVideos:(NSArray*)videos andText:(NSString*)text;
-(void)onScreen;
-(void)offScreen;
-(void)addSwipeGesture;
-(void)mutePlayer;
-(void)enableSound;
@end