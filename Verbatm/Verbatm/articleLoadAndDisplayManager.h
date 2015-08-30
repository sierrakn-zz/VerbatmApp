//
//  articleLoadAndDisplayManager.h
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "singleArticlePresenter.h"
@protocol articleLoadAndDisplayProtocol <NSObject>

-(void)rightArticleDidLoad:(singleArticlePresenter *) articleView;
-(void)leftArticleDidLoad:(singleArticlePresenter *) articleView;

@end

@interface articleLoadAndDisplayManager : NSObject
@property (strong, nonatomic) id<articleLoadAndDisplayProtocol> articleLDDelegate;

/*These two functions instruct our model to load and provide the next article to the left or right of the one presented
 They do not return anything and are reacted to through the protocol described above
 */
-(void)getRightArticle;
-(void)getLeftArticle;
@end
