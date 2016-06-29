//
//  profileInformationBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Icons.h"

#import "Follow_BackendManager.h"

#import "Notifications.h"

#import <Parse/PFUser.h>
#import "ParseBackendKeys.h"
#import "ProfileInformationBar.h"

#import "SizesAndPositions.h"
#import "Styles.h"
#import "FollowingView.h"


@interface ProfileInformationBar ()

@property (nonatomic) PFUser *user;
@property (nonatomic) Channel *channel;
@property (nonatomic) BOOL isCurrentUser;
@property (nonatomic) BOOL profileTab;

@property (nonatomic) UILabel *numFollowersLabel;
@property (nonatomic) UILabel *numFollowingLabel;
@property (nonatomic) UILabel *followersLabel;
@property (nonatomic) UILabel *followingLabel;

@property (nonatomic) UIButton *followOrEditButton;

@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *settingsButton;

@property (nonatomic) BOOL editMode;

// Whether current user has blocked the user who owns this profile
@property (nonatomic) BOOL hasBlockedUser;
@property (nonatomic) BOOL currentUserFollowsUser;

#define FONT_SIZE 12.f
#define NUMBER_FONT_SIZE 15.f
#define SETTINGS_BUTTON_SIZE (PROFILE_INFO_BAR_HEIGHT - (EDIT_SETTINGS_BUTTON_HEIGHT_OFFSET * 2))
#define FOLLOW_OR_EDIT_BUTTON_SIZE 65.f
#define FOLLOWING_LABEL_WIDTH 60.f
#define NUM_FOLLOWING_WIDTH 17.f

#define EDIT_SETTINGS_BUTTON_HEIGHT_OFFSET 2.f // how much buffer between button and top and bottom of self

@end

@implementation ProfileInformationBar

-(instancetype)initWithFrame:(CGRect)frame andUser:(PFUser*)user
                  andChannel:(Channel*)channel inProfileTab:(BOOL) profileTab inFeed:(BOOL) inFeed{
	self =  [super initWithFrame:frame];
	if(self) {
		self.user = user;
		self.channel = channel;
		self.profileTab = profileTab;
		self.isCurrentUser = (user == nil);
		self.editMode = NO;
		self.backgroundColor = PROFILE_INFO_BAR_BACKGROUND_COLRO;
		if (self.profileTab) {
			[self createSettingsButton];
			[self createEditButton];
		} else {
			if(!inFeed)[self createBackButton];
			if (!self.isCurrentUser) {
				// This allows a user to block another user
				[self createSettingsButton];
				self.currentUserFollowsUser = [channel.usersFollowingChannel containsObject:[PFUser currentUser]];
				[self createFollowButton];
			}
		}
		[self createFollowersAndFollowingLabels];
	}
	return self;
}


-(void) updateNumFollowersAndFollowing {
	NSString *numFollowers = [NSNumber numberWithInteger:self.channel.usersFollowingChannel.count].stringValue;
	NSString *numFollowing = [NSNumber numberWithInteger:self.channel.channelsUserFollowing.count].stringValue;
    NSDictionary *numAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:NUMBER_FONT_SIZE]};
    
	self.numFollowersLabel.attributedText = [[NSAttributedString alloc] initWithString:numFollowers attributes:numAttributes];
	self.numFollowingLabel.attributedText = [[NSAttributedString alloc] initWithString:numFollowing attributes:numAttributes];
}


-(void) createFollowersAndFollowingLabels {

	NSDictionary *textAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
									  NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size:FOLLOW_TEXT_FONT_SIZE]};

    CGFloat following_x = (self.frame.size.width - SETTINGS_BUTTON_SIZE - PROFILE_HEADER_XOFFSET*3
    						   - FOLLOW_OR_EDIT_BUTTON_SIZE - FOLLOWING_LABEL_WIDTH -1.f);
    CGFloat following_num_x = following_x - NUM_FOLLOWING_WIDTH - 4.f;
    CGFloat followers_x = following_num_x - PROFILE_HEADER_XOFFSET - FOLLOWING_LABEL_WIDTH;
    CGFloat followers_num_x = followers_x - NUM_FOLLOWING_WIDTH - 3.f;
    CGRect followingFrame = CGRectMake(following_x, STATUS_BAR_HEIGHT, FOLLOWING_LABEL_WIDTH, PROFILE_INFO_BAR_HEIGHT);
    CGRect followersFrame = CGRectMake(followers_x, STATUS_BAR_HEIGHT, FOLLOWING_LABEL_WIDTH, PROFILE_INFO_BAR_HEIGHT);
    CGRect numFollowersFrame = CGRectMake(followers_num_x, STATUS_BAR_HEIGHT, NUM_FOLLOWING_WIDTH, PROFILE_INFO_BAR_HEIGHT);
    CGRect numFollowingFrame = CGRectMake(following_num_x, STATUS_BAR_HEIGHT , NUM_FOLLOWING_WIDTH, PROFILE_INFO_BAR_HEIGHT);
    
    self.numFollowersLabel = [[UILabel alloc] initWithFrame: numFollowersFrame];
    self.numFollowingLabel = [[UILabel alloc] initWithFrame: numFollowingFrame];
    self.numFollowersLabel.textAlignment = NSTextAlignmentRight;
    self.numFollowingLabel.textAlignment = NSTextAlignmentRight;
    self.followersLabel = [[UILabel alloc] initWithFrame: followersFrame];
    self.followersLabel.attributedText = [[NSAttributedString alloc] initWithString:@"followers" attributes:textAttributes];
    self.followingLabel = [[UILabel alloc] initWithFrame: followingFrame];
    self.followingLabel.attributedText = [[NSAttributedString alloc] initWithString:@"following" attributes:textAttributes];
    [self addSubview: self.followersLabel];
    [self addSubview: self.followingLabel];
    [self updateNumFollowersAndFollowing];
    [self addSubview: self.numFollowersLabel];
    [self addSubview: self.numFollowingLabel];
    [self addTapGestureToFollowersView];
    [self addTapGestureToFollowingView];
}

-(void)addTapGestureToFollowersView{
    self.followersLabel.userInteractionEnabled = YES;
    [self.followersLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followersViewTapped)]];
}

-(void)followersViewTapped{
    [self.delegate followersButtonSelected];
}

-(void)addTapGestureToFollowingView{
    self.followingLabel.userInteractionEnabled = YES;
    [self.followingLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followingViewTapped)]];
}

-(void)followingViewTapped{
    [self.delegate followingButtonSelected];
}


-(void) createSettingsButton {
	UIImage *image = [UIImage imageNamed:SETTINGS_BUTTON_ICON];
	CGFloat frame_x = self.frame.size.width - SETTINGS_BUTTON_SIZE - PROFILE_HEADER_XOFFSET;
	CGRect iconFrame = CGRectMake(frame_x, STATUS_BAR_HEIGHT, SETTINGS_BUTTON_SIZE, SETTINGS_BUTTON_SIZE);
	self.settingsButton =  [[UIButton alloc] initWithFrame:iconFrame];
	[self.settingsButton setImage:image forState:UIControlStateNormal];
	self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.settingsButton.clipsToBounds = YES;;
	[self.settingsButton addTarget:self action:@selector(settingsButtonSelected) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview: self.settingsButton];
}

-(void) createFollowButton {
	[self createFollowOrEditButton];
	[self updateUserFollowingChannel];
}

-(void) updateUserFollowingChannel {
	//todo: images
	if (self.currentUserFollowsUser) {
		[self changeFollowButtonTitle:@"Following" toColor:[UIColor whiteColor]];
		self.followOrEditButton.backgroundColor = [UIColor blackColor];
	} else {
		[self changeFollowButtonTitle:@"Follow" toColor:[UIColor blackColor]];
		self.followOrEditButton.backgroundColor = [UIColor whiteColor];
	}
	[self updateNumFollowersAndFollowing];
}

-(void) createEditButton {
	[self createFollowOrEditButton];
	[self changeFollowButtonTitle:@"Edit" toColor:[UIColor whiteColor]];
}

-(void) createFollowOrEditButton {
    CGFloat frame_x = self.settingsButton.frame.origin.x - PROFILE_HEADER_XOFFSET - FOLLOW_OR_EDIT_BUTTON_SIZE -2.f;
    CGRect followButtonFrame = CGRectMake(frame_x, STATUS_BAR_HEIGHT + EDIT_SETTINGS_BUTTON_HEIGHT_OFFSET, FOLLOW_OR_EDIT_BUTTON_SIZE, PROFILE_INFO_BAR_HEIGHT - (EDIT_SETTINGS_BUTTON_HEIGHT_OFFSET * 2.f));
    self.followOrEditButton = [[UIButton alloc] initWithFrame: followButtonFrame];
    self.followOrEditButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.followOrEditButton.clipsToBounds = YES;
    self.followOrEditButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.followOrEditButton.layer.borderWidth = 2.f;
    self.followOrEditButton.layer.cornerRadius = 10.f;
    [self.followOrEditButton addTarget:self action:@selector(followOrEditButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview: self.followOrEditButton];}

-(void) changeFollowButtonTitle:(NSString*)title toColor:(UIColor*) color{
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: color,
									  NSFontAttributeName: [UIFont fontWithName:BOLD_FONT size:FOLLOW_TEXT_FONT_SIZE]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:titleAttributes];
	[self.followOrEditButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

-(void) createBackButton {
	UIImage *backButtonImage = [UIImage imageNamed:BACK_BUTTON_ICON];
	CGRect iconFrame = CGRectMake(PROFILE_HEADER_XOFFSET, STATUS_BAR_HEIGHT,
								  PROFILE_INFO_BAR_HEIGHT, PROFILE_INFO_BAR_HEIGHT);

	self.backButton =  [[UIButton alloc] initWithFrame:iconFrame];
	[self.backButton setImage:backButtonImage forState:UIControlStateNormal];
	self.backButton.imageEdgeInsets = UIEdgeInsetsMake(2.f, 0.f, 2.f, 0.f);
	self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.backButton addTarget:self action:@selector(backButtonSelected) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview: self.backButton];
}

-(void) backButtonSelected {
	[self.delegate backButtonSelected];
}

-(void) settingsButtonSelected {
	if (self.isCurrentUser) [self.delegate settingsButtonSelected];
	else [self.delegate blockCurrentUserShouldBlock: YES]; // todo: check if should block
}

-(void) followOrEditButtonSelected {
	if (self.isCurrentUser) {
		[self.delegate editButtonSelected];
		self.editMode = !self.editMode;
		if (self.editMode) {
            self.followOrEditButton.backgroundColor = [UIColor whiteColor];
            [self changeFollowButtonTitle:@"edit" toColor:[UIColor blackColor]];
        } else {
              	self.followOrEditButton.backgroundColor = [UIColor blackColor];
           		[self changeFollowButtonTitle:@"edit" toColor:[UIColor whiteColor]];
        }
	} else {
		self.currentUserFollowsUser = !self.currentUserFollowsUser;
		if (self.currentUserFollowsUser) {
			[Follow_BackendManager currentUserFollowChannel: self.channel];
		} else {
			[Follow_BackendManager user:[PFUser currentUser] stopFollowingChannel: self.channel];
		}
		[self.channel currentUserFollowsChannel: self.currentUserFollowsUser];
		[self updateUserFollowingChannel];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
