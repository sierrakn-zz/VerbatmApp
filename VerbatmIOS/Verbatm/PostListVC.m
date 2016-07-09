//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"
#import <Branch/BranchUniversalObject.h>
#import <Branch/BranchLinkProperties.h>

#import "Durations.h"
#import "ExternalShare.h"

#import "FeedQueryManager.h"
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import "Icons.h"

#import "Like_BackendManager.h"
#import "LoadingIndicator.h"

#import "Notifications.h"

#import "Page_BackendObject.h"
#import "PostListVC.h"
#import "PostCollectionViewCell.h"
#import "Post_BackendObject.h"
#import "Post_Channel_RelationshipManager.h"
#import "Page_BackendObject.h"
#import "Photo_BackendObject.h"
#import "PublishingProgressManager.h"

#import "Video_BackendObject.h"
#import "Channel_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PostView.h"
#import <PromiseKit/PromiseKit.h>
#import "PageTypeAnalyzer.h"
#import <Parse/PFQuery.h>

#import "Share_BackendManager.h"
#import "SharePostView.h"
#import "SizesAndPositions.h"
#import "StringsAndAppConstants.h"
#import "Styles.h"

#import "UserAndChannelListsTVC.h"
#import "User_BackendObject.h"
#import "UserInfoCache.h"
#import <TwitterKit/TwitterKit.h>

#import <MessageUI/MFMessageComposeViewController.h>

@interface PostListVC () <UICollectionViewDelegate, UICollectionViewDataSource,
SharePostViewDelegate,
UIScrollViewDelegate, PostCollectionViewCellDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic) PFUser *listOwner;
@property (nonatomic) Channel *channelForList;
@property (nonatomic) NSDate *latestDate;

@property (nonatomic, readwrite) NSMutableArray * parsePostObjects;
@property (nonatomic) BOOL performingUpdate;
@property (nonatomic) NSInteger nextIndexToPresent;
@property (nonatomic) NSInteger nextNextIndex;
@property (nonatomic) PostCollectionViewCell *currentDisplayCell;
@property (strong, nonatomic) PostCollectionViewCell *nextCellToPresent;
@property (strong, nonatomic) PostCollectionViewCell *nextNextCell;
@property (nonatomic, strong) UILabel * noContentLabel;

@property (nonatomic) SharePostView *sharePostView;
@property (nonatomic) BOOL shouldPlayVideos;

@property (nonatomic) BOOL footerBarIsUp;//like share bar
@property (nonatomic) BOOL fbShare;
@property (nonatomic) NSString *postImageText;
@property (nonatomic) PFObject *postToShare;

@property (nonatomic) NSNumber * publishingProgressViewPositionHolder;
@property (nonatomic) ExternalShare * externalShare;

@property (nonatomic) UIImageView *reblogSucessful;
@property (nonatomic) UIImageView *following;
@property (nonatomic) UIImageView *publishSuccessful;
@property (nonatomic) UIImageView *publishFailed;

@property (nonatomic) BOOL exitedView;

@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic) BOOL isLoadingOlder;

@property (nonatomic) NSInteger scrollDirection; // -1 if scrolling backwards, +1 if forwards

@property (nonatomic) void(^refreshPostsCompletion)(NSArray * posts);
@property (nonatomic) void(^loadOlderPostsCompletion)(NSArray * posts);


#define LOAD_MORE_POSTS_COUNT (self.inSmallMode ? 4 : 3)

#define POST_CELL_ID @"postCellId"

#define REBLOG_IMAGE_SIZE 150.f //when we put size it means both width and height
#define REPOST_ANIMATION_DURATION 4.f

@end

@implementation PostListVC

-(void) viewDidLoad {
	[super viewDidLoad];
	[self setDateSourceAndDelegate];
	[self defineLoadPostsCompletions];
	[self registerClassForCustomCells];
	[self registerForNotifications];
	[self clearViews];
	self.collectionView.backgroundColor = (self.inSmallMode) ? [UIColor clearColor] : [UIColor blackColor];
	self.collectionView.bounces = YES;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	self.exitedView = NO;
}

-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self offScreen];
}

-(void) registerForNotifications {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userPublishing:)
												 name:NOTIFICATION_POST_CURRENTLY_PUBLISHING
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(publishingFailed:)
												 name:NOTIFICATION_POST_FAILED_TO_PUBLISH
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(publishingSucceeded:)
												 name:NOTIFICATION_POST_PUBLISHED
											   object:nil];
}

-(void) display:(Channel*)channelForList withListOwner:(PFUser*)listOwner isCurrentUserProfile:(BOOL)isCurrentUserProfile andStartingDate:(NSDate*)date
withOldParseObjects:(NSMutableArray *)newParseObjects {

	[self initializeChannel:channelForList withListOwner:listOwner isCurrentUserProfile:isCurrentUserProfile andStartingDate:date];
	self.parsePostObjects = newParseObjects;
	[self.collectionView reloadData];
}

-(void) display:(Channel*)channelForList withListOwner:(PFUser*)listOwner
isCurrentUserProfile:(BOOL)isCurrentUserProfile andStartingDate:(NSDate*)date {
	[self initializeChannel:channelForList withListOwner:listOwner
	   isCurrentUserProfile:isCurrentUserProfile andStartingDate:date];
	[self refreshPosts];
}

-(void) initializeChannel:(Channel*)channelForList withListOwner:(PFUser*)listOwner
	 isCurrentUserProfile:(BOOL)isCurrentUserProfile andStartingDate:(NSDate*)date {
	[self clearViews];
	self.latestDate = date;
	self.channelForList = channelForList;
	self.listOwner = listOwner;
	self.isCurrentUserProfile = isCurrentUserProfile;
	self.footerBarIsUp = self.isCurrentUserProfile;
	self.isInitiated = YES;
}

-(void) offScreen {
	self.exitedView = YES;
	for (PostCollectionViewCell *cellView in [self.collectionView visibleCells]) {
		[cellView offScreen];
	}
}

//todo: change refresh to pull from right
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView == self.collectionView) {
		CGPoint offset = scrollView.contentOffset;
		float reload_distance = 120;

		/* Refresh */
		if(offset.x < (0 - reload_distance)) {
			[self refreshPosts];
		}

		/* Load more */
		CGRect bounds = scrollView.bounds;
		CGSize size = scrollView.contentSize;
		UIEdgeInsets inset = scrollView.contentInset;

		float y = offset.x + bounds.size.width - inset.right;
		float h = size.width;
		if(y > h + reload_distance && !self.isRefreshing && !self.isLoadingMore) {
			//todo: show indicator
		}
	}
}

#pragma mark - Loading content methods -

-(void)nothingToPresentHere {
	if(self.parsePostObjects.count == 0)[self.postListDelegate noPostFound];

	if (self.noContentLabel || self.parsePostObjects.count > 0){
		return;
	}

	self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.f - NO_POSTS_LABEL_WIDTH/2.f, 0.f,
																	NO_POSTS_LABEL_WIDTH, self.view.frame.size.height)];
	self.noContentLabel.text = @"There are no posts to present :(";
	self.noContentLabel.font = [UIFont fontWithName:REGULAR_FONT size:20.f];
	self.noContentLabel.textColor = [UIColor whiteColor];
	self.noContentLabel.textAlignment = NSTextAlignmentCenter;
	self.noContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.noContentLabel.numberOfLines = 3;
	self.view.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.noContentLabel];
}

-(void)removePresentLabel{
	if(self.noContentLabel){
		[self.noContentLabel removeFromSuperview];
		self.noContentLabel = nil;
	}
}

-(void) defineLoadPostsCompletions {
	__weak typeof(self) weakSelf = self;
	self.refreshPostsCompletion = ^void(NSArray *posts) {
		if(weakSelf.exitedView) return; // Already left page
		[weakSelf.postListDelegate postsFound];
		if(posts.count) {
			[weakSelf.parsePostObjects removeAllObjects];
			[weakSelf.parsePostObjects addObjectsFromArray:posts];
			if(weakSelf.currentlyPublishing) {
				[weakSelf.parsePostObjects addObject:weakSelf.publishingProgressViewPositionHolder];
			}
			[weakSelf.collectionView reloadData];
			[weakSelf scrollToLastElementInList];

			[weakSelf removePresentLabel];
		} else if(!weakSelf.parsePostObjects.count){
			[weakSelf nothingToPresentHere];
		}
		weakSelf.isRefreshing = NO;
	};

	self.loadOlderPostsCompletion = ^void(NSArray *posts) {
		if (!posts.count || weakSelf.exitedView){
			weakSelf.isLoadingOlder = NO;
			return;
		}
		[weakSelf.postListDelegate postsFound];
		NSMutableArray *indices = [NSMutableArray array];
		for (NSInteger i = 0; i < posts.count; i++) {
			[indices addObject:[NSIndexPath indexPathForItem:i inSection:0]];
		}
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0,[posts count])];

		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		weakSelf.performingUpdate = YES;
		// Perform the updates
		[weakSelf.collectionView performBatchUpdates:^{
			//Insert the new data
			[weakSelf.parsePostObjects insertObjects:posts atIndexes:indexSet];
			//Insert the new cells
			[weakSelf.collectionView insertItemsAtIndexPaths:indices];

		} completion: ^(BOOL finished) {
			if (finished) {
				// Scroll to previously selected cell so nothing looks different
				NSArray* visiblePaths = [weakSelf.collectionView indexPathsForVisibleItems];
				NSInteger oldRow = visiblePaths && visiblePaths.count ? [(NSIndexPath*)visiblePaths[0] row] : 0;
				NSInteger newRow = oldRow + posts.count;
				if (newRow >= 0 && newRow < self.parsePostObjects.count) {
					NSIndexPath *selectedPostPath = [NSIndexPath indexPathForRow:newRow inSection:0];
					[weakSelf.collectionView scrollToItemAtIndexPath:selectedPostPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
					weakSelf.nextIndexToPresent += posts.count;
					weakSelf.nextNextIndex += posts.count;
				} else {
					NSLog(@"Bug scrolling when added older posts");
				}

				weakSelf.isLoadingOlder = NO;
				weakSelf.performingUpdate = NO;
				[CATransaction commit];
			}
		}];
	};
}

-(void)scrollToLastElementInList {
	NSInteger section = 0;
	NSInteger item = [self.collectionView numberOfItemsInSection:section] - 1;
	if(item > 0) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
		[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionRight) animated:NO];
	}
}

//todo: change to refresh newest and just load posts
-(void) refreshPosts {
	if (!self.isRefreshing){
		self.exitedView = NO;
		self.isRefreshing = YES;
		self.isLoadingMore = NO;
		[self.postsQueryManager loadPostsInChannel: self.channelForList withLatestDate:self.latestDate withCompletionBlock:self.refreshPostsCompletion];
	}
}

-(void) loadOlderPosts {
	if (self.isLoadingOlder) return;
	self.isLoadingOlder = YES;
	[self.postsQueryManager loadOlderPostsInChannel:self.channelForList withCompletionBlock:self.loadOlderPostsCompletion];
}

#pragma mark - Table view methods -

//register our custom cell class
-(void)registerClassForCustomCells{
	[self.collectionView registerClass:[PostCollectionViewCell class] forCellWithReuseIdentifier:POST_CELL_ID];
}

//set the data source and delegate of the collection view
-(void)setDateSourceAndDelegate{
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.pagingEnabled = NO;
	self.collectionView.scrollEnabled = YES;
	self.collectionView.showsHorizontalScrollIndicator = NO;
	self.collectionView.bounces = YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return self.parsePostObjects.count;
}


- (BOOL)collectionView: (UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	[self checkShouldReverseScrollDirectionFromIndexPath: indexPath];

//	if (self.performingUpdate && self.currentDisplayCell){
//		return self.currentDisplayCell;
//	}

	PostCollectionViewCell *currentCell;
	//todo: load cells to the left when needed in small mode
	if (!self.inSmallMode) {
		if (indexPath.row == self.nextIndexToPresent) {
			currentCell = self.nextCellToPresent;
		}
		[self prepareNextPostsFromIndexPath:indexPath];
	}

	if (currentCell == nil) {
		currentCell = [self postCellAtIndexPath:indexPath];
	}
	[currentCell onScreen];

	//Load older posts
	if (indexPath.row <= LOAD_MORE_POSTS_COUNT && !self.isLoadingOlder && !self.isRefreshing) {
		[self loadOlderPosts];
	}

	self.currentDisplayCell = currentCell;
	return currentCell;
}

-(void) checkShouldReverseScrollDirectionFromIndexPath:(NSIndexPath*)indexPath  {
	// Check if should reverse scroll direction (only if this isn't the first time getting a cell)
	if (self.nextIndexToPresent != -1) {
		self.scrollDirection = (indexPath.row == self.nextIndexToPresent) ? self.scrollDirection : self.scrollDirection*-1;
	}
}

-(void) prepareNextPostsFromIndexPath:(NSIndexPath*)indexPath {
	self.nextIndexToPresent = indexPath.row + self.scrollDirection;
	// If next cell is previously prepared next next cell, just set it equal
	if (self.nextIndexToPresent == self.nextNextIndex) {
		self.nextCellToPresent = self.nextNextCell;
		// Otherwise, reset it
	} else {
		self.nextCellToPresent = [self postCellAtIndexPath:[NSIndexPath indexPathForRow:self.nextIndexToPresent inSection:indexPath.section]];
	}
	if (self.nextCellToPresent) [self.nextCellToPresent almostOnScreen];

	//Prepare next next cell
	self.nextNextIndex = indexPath.row + self.scrollDirection*2;
	self.nextNextCell = [self postCellAtIndexPath:[NSIndexPath indexPathForRow:self.nextNextIndex inSection:indexPath.section]];
	if (self.nextNextCell) [self.nextNextCell almostOnScreen];
}

-(PostCollectionViewCell*) postCellAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row >= self.parsePostObjects.count){
		return nil;
	}

	PostCollectionViewCell *cell = (PostCollectionViewCell *) [self.collectionView dequeueReusableCellWithReuseIdentifier:POST_CELL_ID forIndexPath:indexPath];
	cell.cellDelegate = self;
	if(indexPath.row < self.parsePostObjects.count){
		id postObject = self.parsePostObjects[indexPath.row];
		if (cell.currentPostActivityObject != postObject) {
			[cell clearViews];
			if([postObject isKindOfClass:[NSNumber class]]){
				if (self.currentlyPublishing) [cell presentPublishingView];
			} else {
//				NSLog(@"Presenting post at index %ld", (long)indexPath.row);
				[cell presentPostFromPCActivityObj:postObject andChannel:self.channelForList
								  withDeleteButton:self.isCurrentUserProfile andLikeShareBarUp:NO];
			}
		}
	}
	[self addTapGestureToCell:cell];
	cell.inSmallMode = self.inSmallMode;
	return cell;
}


-(void)addTapGestureToCell:(PostCollectionViewCell *) cell{

	if(cell && !cell.cellHasTapGesture){
		[cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)]];
		cell.cellHasTapGesture = YES;

	}
}

-(void)cellTapped:(UIGestureRecognizer *) tap{

	PostCollectionViewCell * cellTapped = (PostCollectionViewCell *) tap.view;
	[self.postListDelegate cellSelectedAtPostIndex:[self.collectionView indexPathForCell:cellTapped]];
}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	// If the indexpath is not within visible objects then it is offscreen
	if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		[(PostCollectionViewCell*)cell clearViews];
	}
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	if ([collectionView.indexPathsForVisibleItems indexOfObject:indexPath] == NSNotFound) {
		[(PostCollectionViewCell*)cell onScreen];
	}
}

-(void) footerShowing: (BOOL) showing {
	self.footerBarIsUp = showing;
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
		[self setNeedsStatusBarAppearanceUpdate];
	} completion:^(BOOL finished) {
	}];
}

#pragma mark - Deleting -

-(void) deleteButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post
			 andPostChannelActivityObj:(PFObject *)pfActivityObj reblogged:(BOOL)reblogged {

	if (reblogged) {
		[self deleteReblog:post onPostView:postView withPostChannelActivityObj:pfActivityObj];
		return;
	}
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete post"
																   message:@"Entire post will be deleted."
															preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSInteger postIndex = [self.parsePostObjects indexOfObject: pfActivityObj];
		[self removePostAtIndex: postIndex withCompletionBlock:nil];
		[postView clearPost];
		[Post_BackendObject deletePost:post];
	}];

	[alert addAction: cancelAction];
	[alert addAction: deleteAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void) deleteReblog:(PFObject *)post onPostView:(PostView *)postView withPostChannelActivityObj:(PFObject *)pfActivityObj {
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete reblogged post"
																   message:@"Are you sure?"
															preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSInteger postIndex = [self.parsePostObjects indexOfObject: pfActivityObj];
		[self removePostAtIndex: postIndex withCompletionBlock:nil];
		[postView clearPost];
		[postView.parsePostChannelActivityObject deleteInBackground];
	}];

	[alert addAction: cancelAction];
	[alert addAction: deleteAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void)removePostAtIndex:(NSInteger)i withCompletionBlock:(void(^)(void)) block; {
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.performingUpdate = YES;
	[self.collectionView performBatchUpdates: ^ {
		[self.parsePostObjects removeObjectAtIndex:i];
		NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
		[self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
	} completion:^(BOOL finished) {
		if(finished){
			if (self.parsePostObjects.count < 1) {
				[self nothingToPresentHere];
			}
			self.performingUpdate = NO;
			[CATransaction commit];
			if(block)block();
		}
	}];
}

#pragma mark Flagging & Blocking

-(void) flagOrBlockButtonSelectedOnPostView:(PostView *)postView withPostObject:(PFObject *)post{

	UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
																   message:nil
															preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* flagAction = [UIAlertAction actionWithTitle:@"Report Post" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[self confirmFlagOrBlock:YES onPostView:postView withPostObject:post];
	}];
	UIAlertAction* blockAction = [UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[self confirmFlagOrBlock:NO onPostView:postView withPostObject:post];
	}];

	[alert addAction: cancelAction];
	[alert addAction: flagAction];
	[alert addAction: blockAction];
	[self presentViewController:alert animated:YES completion:nil];
}

-(void) confirmFlagOrBlock:(BOOL)flagging onPostView:(PostView *)postView withPostObject:(PFObject *)post{
	UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * action) {}];
	UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		if (flagging) {
			[Post_BackendObject markPostAsFlagged:post];
			//todo: send us an email
		} else {
			PFObject *postChannelObject = [postView parsePostChannelActivityObject];
			PFObject *channel = [postChannelObject objectForKey:POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO];
			PFUser *user = [channel objectForKey:CHANNEL_CREATOR_KEY];
			[User_BackendObject blockUser:user];
		}
	}];
	[confirmAlert addAction: cancelAction];
	[confirmAlert addAction: deleteAction];
	[self presentViewController:confirmAlert animated:YES completion:nil];
}

#pragma mark Sharing

-(void) shareOptionSelectedForParsePostObject: (PFObject* )post {
	[self.postListDelegate hideNavBarIfPresent];
	self.postToShare = post;
	[self presentShareSelectionViewStartOnChannels:YES];
}

-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels {
	if(self.sharePostView){
		[self.sharePostView removeFromSuperview];
		self.sharePostView = nil;
	}

	CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
	CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
	self.sharePostView = [[SharePostView alloc] initWithFrame:offScreenFrame];
	self.sharePostView.delegate = self;
	self.view.userInteractionEnabled = NO;
	[[UIApplication sharedApplication].keyWindow addSubview:self.sharePostView];

	//[self.view addSubview:self.sharePostView];
	[[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.sharePostView];
	//[self.view bringSubviewToFront:self.sharePostView];
	[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^ {
		self.sharePostView.frame = onScreenFrame;
	}];
}

-(void)removeSharePOVView{
	if(self.sharePostView){
		CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
		[UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
			self.sharePostView.frame = offScreenFrame;
		}completion:^(BOOL finished) {
			if(finished){
				[self.sharePostView removeFromSuperview];
				self.sharePostView = nil;
			}
		}];
	}
}

#pragma mark - Share Selection View Protocol -

-(void)cancelButtonSelected{
	[self removeSharePOVView];
	self.view.userInteractionEnabled = YES;
}


-(void) shareToVerbatmSelected{
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Repost to Verbatm Account" message:@"" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {}];

	UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {

														NSMutableArray *channels = [[NSMutableArray alloc] init];
														[channels addObject:[[UserInfoCache sharedInstance] getUserChannel]];
														[Post_Channel_RelationshipManager savePost:self.postToShare toChannels:channels withCompletionBlock:^{
															dispatch_async(dispatch_get_main_queue(), ^{
																[self successfullyReblogged];
															});
														}];

													}];
	[newAlert addAction:action1];
	[newAlert addAction:action2];
	[self presentViewController:newAlert animated:YES completion:nil];
}


-(void)reportLinkError{
	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Your link is being generated" message:@"Come back and try again in a few seconds" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action1];
	[self presentViewController:newAlert animated:YES completion:nil];
}

-(void) shareToTwitterSelected{

	NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
	if(url){

		TWTRComposer *composer = [[TWTRComposer alloc] init];
		NSString * message = @"Hey - checkout this post on Verbatm! ";
		[composer setText:[message stringByAppendingString:url]];
		[composer setImage:[UIImage imageNamed:@"fabric"]];

		// Called from a UIViewController
		[composer showFromViewController:self completion:^(TWTRComposerResult result) {
			if (result == TWTRComposerResultCancelled) {
				NSLog(@"Tweet composition cancelled");
			}
			else {
				NSLog(@"Sending Tweet!");
			}
		}];

	} else {
		[self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
		[self reportLinkError];
	}
}

-(void) shareToFacebookSelected{
	NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
	if(url){
		dispatch_async(dispatch_get_main_queue(), ^{
//			NSLog(@"got my Branch invite link to share to Facebook. Link : %@", url);
			NSURL *link = [NSURL URLWithString:url];
			FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
			content.contentURL = link;
			[FBSDKShareDialog showFromViewController:self
										 withContent:content
											delegate:nil];
		});
	}else{
		[self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
		[self reportLinkError];
	}
}


-(void) shareToSmsSelected{
	NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
	if(url){
		MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
		NSString * message = @"Hey - checkout this post on Verbatm!   ";
		controller.body = [message stringByAppendingString:url];

		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];


	}else{
		[self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];

		[self reportLinkError];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) copyLinkSelected{
	NSString * url = [self.postToShare valueForKey:POST_SHARE_LINK];
	if(url){
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = url;

		UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Link Copied to Clipboard" message:@"" preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
														handler:^(UIAlertAction * action) {}];
		[newAlert addAction:action1];
		[self presentViewController:newAlert animated:YES completion:nil];

	}else{
		[self.externalShare storeShareLinkToPost:self.postToShare withCaption:nil withCompletionBlock:nil];
		[self reportLinkError];
	}
}

//todo: save share object
-(void) shareToShareOption:(ShareOptions) shareOption{

	switch (shareOption) {
		case Verbatm:
			[self shareToVerbatmSelected];
			break;
		case TwitterShare:
			[self shareToTwitterSelected];
			break;
		case Facebook:
			[self shareToFacebookSelected];
			break;
		case Sms:
			[self shareToSmsSelected];
			break;
		case CopyLink:
			[self copyLinkSelected];
			break;

		default:
			break;
	}

	[self removeSharePOVView];
	self.view.userInteractionEnabled = YES;
}

-(void)postPostExternal {
	[Page_BackendObject getPagesFromPost:self.postToShare andCompletionBlock:^(NSArray *pages){
		PFObject *po = pages[0];
		PageTypes type = [((NSNumber *)[po valueForKey:PAGE_VIEW_TYPE]) intValue];

		if(type == PageTypePhoto || type == PageTypePhotoVideo){
			[Photo_BackendObject getPhotosForPage:po andCompletionBlock:^(NSArray * photoObjects) {
				PFObject *photo = photoObjects[0];
				NSString *photoLink = [photo valueForKey:PHOTO_IMAGEURL_KEY];
				[self postToFacebookWithShareLink:photoLink];
			}];
		} else if(type == PageTypeVideo){
			[Video_BackendObject getVideoForPage:po andCompletionBlock:^(PFObject * videoObject) {
				NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];
				[self postToFacebookWithShareLink:thumbNailUrl];
			}];
		}
	}];
}

-(void) postToFacebookWithShareLink:(NSString*)shareLink {
	NSString *postId = self.postToShare.objectId;
	PFUser *user = [PFUser currentUser];
	NSString *name = [user valueForKey:VERBATM_USER_NAME_KEY];
	Channel_BackendObject *channelObj = [self.postToShare valueForKey:POST_CHANNEL_KEY];
	NSString *channelName = [channelObj valueForKey:CHANNEL_NAME_KEY];

	BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:postId];
	branchUniversalObject.title = [NSString stringWithFormat:@"%@ shared a post from '%@' Verbatm blog", name, channelName];
	branchUniversalObject.contentDescription = VERBATM_DESCRIPTION;
	branchUniversalObject.imageUrl = shareLink;

	BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
	linkProperties.feature = @"share";
	linkProperties.channel = @"facebook";

	[branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
		if (!error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				NSURL *link = [NSURL URLWithString:url];
				FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
				content.contentURL = link;
				[FBSDKShareDialog showFromViewController:self
											 withContent:content
												delegate:nil];
			});

		} else {
		}
	}];
	self.view.userInteractionEnabled = YES;
}

-(void)successfullyReblogged {

	UIAlertController * newAlert = [UIAlertController alertControllerWithTitle:@"Sucessfully Reblogged!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
												   handler:^(UIAlertAction * action) {}];
	[newAlert addAction:action];
	[self presentViewController:newAlert animated:YES completion:nil];
}

#pragma mark - Publishing -

-(void)clearPublishingView {
	if(self.currentlyPublishing && self.parsePostObjects.count) {
		self.currentlyPublishing = NO;
		[self removePostAtIndex:[self.parsePostObjects indexOfObject:self.publishingProgressViewPositionHolder] withCompletionBlock:^() {
			[self refreshPosts];
		}];
	}
}

-(void)startMonitoringPublishing{
	//don't run the script when publishing isn't happening and
	if(self.currentlyPublishing) return;
	if(!self.isCurrentUserProfile) return;
	if (!([PublishingProgressManager sharedInstance].currentlyPublishing)) return;

	self.currentlyPublishing = YES;
	self.nextIndexToPresent = -1;
	self.nextNextIndex = -1;

	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.performingUpdate = YES;
	//add progress view to parseObjects
	NSInteger index = self.parsePostObjects.count;
	[self.collectionView performBatchUpdates:^{
		//Insert the new data
		[self.parsePostObjects addObject:self.publishingProgressViewPositionHolder];
		//Insert the new cells
		[self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];

	} completion:^(BOOL finished) {
		if(finished){
			self.performingUpdate = NO;
			[CATransaction commit];
			[self.postListDelegate postsFound];
		}
	}];
}

-(void) userPublishing:(NSNotification *) notification {
	[self startMonitoringPublishing];
}

// Alerts to user about publishing handled in Master Navigation VC
-(void) publishingSucceeded:(NSNotification *) notification {
	if(!self.isCurrentUserProfile) return;
	[self clearPublishingView];
}

-(void) publishingFailed:(NSNotification *) notification {
	if(!self.isCurrentUserProfile) return;
	self.currentlyPublishing = NO;
	[PFQuery clearAllCachedResults];
	[self clearPublishingView];
}

#pragma mark - Clear views -

-(void) clearViews {

	@autoreleasepool {
		self.exitedView = YES;
		for (PostCollectionViewCell *cellView in [self.collectionView visibleCells]) {
			[cellView offScreen];
			[cellView clearViews];
		}
		self.parsePostObjects = nil;
		[self.collectionView reloadData];
		// Start off assuming scrolling backwards
		self.scrollDirection = -1;
		self.nextIndexToPresent = -1;
		self.nextNextIndex = -1;
		self.nextCellToPresent = nil;
		self.nextNextCell = nil;
		self.postToShare = nil;
		self.isRefreshing = NO;
		self.isLoadingMore = NO;
		self.isLoadingOlder = NO;
		self.performingUpdate = NO;
		self.shouldPlayVideos = YES;
	}
}

#pragma mark - POV delegate -

-(void)channelSelected:(Channel *) channel{
	[self.postListDelegate channelSelected:channel];
}

-(void) showWhoLikesThePost:(PFObject *) post{
	UserAndChannelListsTVC * vc = [[UserAndChannelListsTVC alloc] initWithStyle:UITableViewStyleGrouped];
	[vc presentList:likersList forChannel:nil orPost:post];
	[self presentViewController:vc animated:YES completion:nil];
}


#pragma mark -Lazy instantiation-

-(UIImageView *)reblogSucessful {
	if(!_reblogSucessful){
		_reblogSucessful = [[UIImageView alloc] init];
		[_reblogSucessful setImage:[UIImage imageNamed:REBLOG_IMAGE]];
		[_reblogSucessful setFrame:CGRectMake((self.view.frame.size.width/2.f)-REBLOG_IMAGE_SIZE/2.f, (self.view.frame.size.height/2.f) -REBLOG_IMAGE_SIZE/2.f, REBLOG_IMAGE_SIZE, REBLOG_IMAGE_SIZE)];
	}
	return _reblogSucessful;
}


-(UIImageView *)publishSuccessful {
	if(!_publishSuccessful){
		_publishSuccessful = [[UIImageView alloc] init];
		[_publishSuccessful setImage:[UIImage imageNamed:SUCCESS_PUBLISHING_IMAGE]];
		[_publishSuccessful setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _publishSuccessful;
}

-(UIImageView *)publishFailed {
	if(!_publishFailed){
		_publishFailed = [[UIImageView alloc] init];
		[_publishFailed setImage:[UIImage imageNamed:FAILED_PUBLISHING_IMAGE]];
		[_publishFailed setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _publishFailed;
}

-(UIImageView *)following {
	if(!_following){
		_following = [[UIImageView alloc] init];
		[_following setImage:[UIImage imageNamed:FOLLOWING_SUCCESS_IMAGE]];
		[_following setFrame:self.reblogSucessful.frame];
		self.reblogSucessful = nil;
	}
	return _following;
}

-(NSMutableArray *) parsePostObjects {
	if(!_parsePostObjects) _parsePostObjects = [[NSMutableArray alloc] init];
	return _parsePostObjects;
}

-(PostsQueryManager*) postsQueryManager {
	if (!_postsQueryManager) {
		_postsQueryManager = [[PostsQueryManager alloc] initInSmallMode: self.inSmallMode];
	}
	return _postsQueryManager;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(ExternalShare *)externalShare{
	if(!_externalShare)_externalShare = [[ExternalShare alloc] init];
	return _externalShare;
}

-(NSNumber*)publishingProgressViewPositionHolder{
	if(!_publishingProgressViewPositionHolder)_publishingProgressViewPositionHolder = [NSNumber numberWithBool:YES];
	return _publishingProgressViewPositionHolder;
}

-(void) didReceiveMemoryWarning {

}

@end
