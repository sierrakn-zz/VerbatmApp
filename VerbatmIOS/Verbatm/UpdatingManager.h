//
//  UpdatingManager.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/16/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.

// 	Responsible for updating information in already stored entities
//

#import <Foundation/Foundation.h>

@interface UpdatingManager : NSObject

// Updates the POV in the backend with the information that user liked
// or unliked it
- (void) povWithId: (NSNumber*) povID wasLiked: (BOOL) liked;

@end