//
//  verbatmArticleAquirer.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "ArticleAquirer.h"
#import "Article.h"
#import "MasterNavigationVC.h"

@interface ArticleAquirer ()
#define ARTICLE_AUTHOR_RELATIONSHIP @"articleAuthorRelation"

@end
@implementation ArticleAquirer

+(Article*)downloadArticleWithTitle:(NSString *)title andAuthor:(VerbatmUser *)user
{
    PFQuery* query = [PFQuery queryWithClassName: @"Article"];
    [query whereKey: ARTICLE_AUTHOR_RELATIONSHIP equalTo:user];
    [query whereKey: @"title" equalTo:title];
    return [[query findObjects]firstObject];
}

+(BOOL)saveArticleWithPinchObjects:(NSArray *)pinchObjects title:(NSString *)title withSandwichFirst:(NSString *)firstPart andSecond:(NSString*)secondPart
{
	BOOL isTesting = [MasterNavigationVC inTestingMode];
    Article * this_article = [[Article alloc] initAndSaveWithTitle:title andSandWichWhat:firstPart Where:secondPart andPinchObjects:pinchObjects andIsTesting:isTesting];
    [this_article setSandwich:firstPart at:secondPart];
    return [this_article save];
}

+(void)downloadAllArticlesWithBlock:(void(^)(NSArray *ourObjects))onDownloadBlock
{
	PFQuery* query;
	if ([MasterNavigationVC inTestingMode]) {
		query = [PFQuery queryWithClassName: @"Article"];
	} else {
		query = [PFQuery queryWithClassName: @"Article"];
		[query whereKey:@"isTestingArticle" equalTo:[NSNumber numberWithBool:NO]];
	}
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        onDownloadBlock(objects);
    }];
}


@end