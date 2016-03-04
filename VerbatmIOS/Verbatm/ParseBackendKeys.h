//
//  ParseBackendKeys.h
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#ifndef ParseBackendKeys_h
#define ParseBackendKeys_h


#define VERBATM_USER_NAME_KEY @"VerbatmName" //different from the username which is used by fb on parse
#define USER_RELATION_CHANNELS_FOLLOWING @"ChannelsFollowing"

#define FOLLOW_PFCLASS_KEY @"FollowClass"//we maintain all the follow relationships in their own table
#define FOLLOW_USER_KEY @"UserFollowing"//the user doing the following
#define FOLLOW_CHANNEL_FOLLOWED_KEY @"ChannelFollowed"//channel being followed by above user

#define PHOTO_PFCLASS_KEY @"PhotoClass"
#define PHOTO_TEXT_KEY @"PhotoText"
#define PHOTO_TEXT_YOFFSET_KEY @"TextYOffset"
#define PHOTO_IMAGEURL_KEY @"BlobStoreUrl"
#define PHOTO_PAGE_OBJECT_KEY @"PageObject"
#define PHOTO_INDEX_KEY @"PhotoIndex"
#define PHOTO_USER_KEY @"UsersPhoto"



#define VIDEO_INDEX_KEY @"VideoIndex" //if we have multiple videos how they are organized
#define VIDEO_PFCLASS_KEY @"VideoClass"
#define User_Key @"user"
#define BLOB_STORE_URL @"BlobStoreUrl"
#define VIDEO_PAGE_OBJECT_KEY @"Page"
#define VIDEO_THUMBNAIL_KEY @"Thumbnail"

#define PAGE_PFCLASS_KEY @"PageClass"
#define PAGE_INDEX_KEY @"PageIndex"
#define PAGE_POST_KEY @"PostForPage" // the post this page belongs to
#define PAGE_VIEW_TYPE @"AveType"

#define POST_PFCLASS_KEY @"PostClass"
#define POST_CHANNEL_KEY @"ChannelForPost" //the channel the post lives in
#define POST_SIZE_KEY @"PostSize" //number of pages on this post
#define POST_LIKES_NUM_KEY @"NumberOfLikes"
#define POST_NUM_SHARES_KEY @"NumberOfShares" //number of times this post has been shared
#define POST_ORIGINAL_CREATOR_KEY @"OriginalCreator" //Original creator or post

#define POST_COMPLETED_SAVING @"PostDoneSaving"//we store


#define CHANNEL_PFCLASS_KEY @"ChannelClass"
#define CHANNEL_NAME_KEY @"ChannelName"
#define CHANNEL_NUM_POSTS_KEY @"NumPosts"
#define CHANNEL_CREATOR_KEY @"ChannelCreator" //the user that has created this channel
#endif /* ParseBackendKeys_h */
