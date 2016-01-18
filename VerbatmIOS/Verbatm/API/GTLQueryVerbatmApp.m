/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLQueryVerbatmApp.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryVerbatmApp (16 custom class methods, 10 custom properties)

#import "GTLQueryVerbatmApp.h"

#import "GTLVerbatmAppChannel.h"
#import "GTLVerbatmAppImageCollection.h"
#import "GTLVerbatmAppPageCollection.h"
#import "GTLVerbatmAppPost.h"
#import "GTLVerbatmAppPostCollection.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppVerbatmUserCollection.h"
#import "GTLVerbatmAppVideoCollection.h"

@implementation GTLQueryVerbatmApp

@dynamic channelId, count, email, fields, identifier, liked, pageId, postId,
         shareType, userId;

+ (NSDictionary *)parameterNameMap {
  NSDictionary *map = @{
    @"channelId" : @"channel_id",
    @"identifier" : @"id",
    @"pageId" : @"page_id",
    @"postId" : @"post_id",
    @"shareType" : @"share_type",
    @"userId" : @"user_id"
  };
  return map;
}

#pragma mark - "channel" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForChannelInsertChannelWithObject:(GTLVerbatmAppChannel *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.channel.insertChannel";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppChannel class];
  return query;
}

#pragma mark - "post" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForPostGetImagesInPageWithPageId:(NSInteger)pageId {
  NSString *methodName = @"verbatmApp.post.getImagesInPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.pageId = pageId;
  query.expectedObjectClass = [GTLVerbatmAppImageCollection class];
  return query;
}

+ (instancetype)queryForPostGetPagesInPostWithPostId:(NSInteger)postId {
  NSString *methodName = @"verbatmApp.post.getPagesInPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppPageCollection class];
  return query;
}

+ (instancetype)queryForPostGetPostsInChannelWithChannelId:(NSInteger)channelId {
  NSString *methodName = @"verbatmApp.post.getPostsInChannel";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.channelId = channelId;
  query.expectedObjectClass = [GTLVerbatmAppPostCollection class];
  return query;
}

+ (instancetype)queryForPostGetRecentPostsWithCount:(NSInteger)count {
  NSString *methodName = @"verbatmApp.post.getRecentPosts";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.count = count;
  query.expectedObjectClass = [GTLVerbatmAppPostCollection class];
  return query;
}

+ (instancetype)queryForPostGetUsersWhoLikePostWithPostId:(NSInteger)postId {
  NSString *methodName = @"verbatmApp.post.getUsersWhoLikePost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUserCollection class];
  return query;
}

+ (instancetype)queryForPostGetUsersWhoSharedPostWithPostId:(NSInteger)postId {
  NSString *methodName = @"verbatmApp.post.getUsersWhoSharedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUserCollection class];
  return query;
}

+ (instancetype)queryForPostGetVideosInPageWithPageId:(NSInteger)pageId {
  NSString *methodName = @"verbatmApp.post.getVideosInPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.pageId = pageId;
  query.expectedObjectClass = [GTLVerbatmAppVideoCollection class];
  return query;
}

+ (instancetype)queryForPostInsertPostWithObject:(GTLVerbatmAppPost *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.post.insertPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppPost class];
  return query;
}

+ (instancetype)queryForPostUserLikedPostWithLiked:(BOOL)liked
                                            postId:(NSInteger)postId
                                            userId:(NSInteger)userId {
  NSString *methodName = @"verbatmApp.post.userLikedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.liked = liked;
  query.postId = postId;
  query.userId = userId;
  return query;
}

+ (instancetype)queryForPostUserSharedPostWithPostId:(NSInteger)postId
                                           shareType:(NSString *)shareType
                                              userId:(NSInteger)userId {
  NSString *methodName = @"verbatmApp.post.userSharedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.shareType = shareType;
  query.userId = userId;
  return query;
}

#pragma mark - "verbatmuser" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForVerbatmuserGetUserWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.verbatmuser.getUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserGetUserFromEmailWithEmail:(NSString *)email {
  NSString *methodName = @"verbatmApp.verbatmuser.getUserFromEmail";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.email = email;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserInsertUserWithObject:(GTLVerbatmAppVerbatmUser *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.verbatmuser.insertUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserRemoveUserWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.verbatmuser.removeUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  return query;
}

+ (instancetype)queryForVerbatmuserUpdateUserWithObject:(GTLVerbatmAppVerbatmUser *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.verbatmuser.updateUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

@end
