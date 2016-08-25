//
//  onboardingBlogSelectionViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 6/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "OnboardingBlogSelectionViewController.h"
#import "DiscoverVC.h"
#import "Notifications.h"
#import "SizesAndPositions.h"
#import "StoryboardVCIdentifiers.h"
#import "Icons.h"
#import "ParseBackendKeys.h"
#import <Parse/PFUser.h>
#import "SegueIDs.h"
#import "Styles.h"

@interface OnboardingBlogSelectionViewController () <OnboardingBlogsDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) DiscoverVC *discoverList;

#define HEADER_VIEW_HEIGHT STATUS_BAR_HEIGHT + 60.f
#define DONE_BUTTON_WIDTH 70.f
#define HEADER_Y_OFFSET 15.f
#define HEADER_X_OFFSET 5.f

@end

@implementation OnboardingBlogSelectionViewController

-(void) viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;
    [self addBackgroundImage];
	[self.view addSubview: self.headerView];
    self.tableContainerView.frame = CGRectMake(0.f, HEADER_VIEW_HEIGHT,
                                               self.view.frame.size.width, self.view.frame.size.height);
    self.tableContainerView.backgroundColor = [UIColor clearColor];
    [self addListVC];
	[self addDoneButton];
	[self addHeaderLabel];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationController.interactivePopGestureRecognizer.enabled = NO;
	self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	return NO;
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_DISCOVER object:nil userInfo:nil];
}

-(void)addListVC {
    self.discoverList = [self.storyboard instantiateViewControllerWithIdentifier:FEATURED_CONTENT_VC_ID];
    self.discoverList.onboardingBlogSelection = YES;
	self.discoverList.onboardingDelegate = self;
    [self.tableContainerView addSubview: self.discoverList.view];
    [self addChildViewController: self.discoverList];
    [self.discoverList didMoveToParentViewController:self];
}

-(void)addDoneButton {
    CGRect buttomFrame = CGRectMake(self.view.frame.size.width - (DONE_BUTTON_WIDTH + HEADER_X_OFFSET),  STATUS_BAR_HEIGHT,
									DONE_BUTTON_WIDTH, HEADER_VIEW_HEIGHT - (HEADER_Y_OFFSET*2) - STATUS_BAR_HEIGHT);
    
    UIButton * done = [[UIButton alloc] initWithFrame:buttomFrame];
	self.doneButton = done;
    [done addTarget:self action:@selector(exitDiscover) forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"DONE" forState:UIControlStateNormal];
	done.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
	done.userInteractionEnabled = YES;
	done.layer.borderWidth = 3.f;
	done.layer.cornerRadius = 3.f;
	[done.titleLabel setFont:[UIFont fontWithName:BOLD_FONT size: 14.f]]; //todo
    [self.navigationController.navigationBar addSubview:done];
}

-(void) addHeaderLabel {
	CGFloat headerLabelWidth = self.view.frame.size.width - (DONE_BUTTON_WIDTH + HEADER_X_OFFSET)*2;
	self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((DONE_BUTTON_WIDTH + HEADER_X_OFFSET),
																	 HEADER_Y_OFFSET + STATUS_BAR_HEIGHT, headerLabelWidth,
																	 HEADER_VIEW_HEIGHT - (HEADER_Y_OFFSET*2) - STATUS_BAR_HEIGHT)];
	self.headerLabel.text = @"Follow a few profiles";
	[self.headerLabel setFont:[UIFont fontWithName:BOLD_FONT size: 16.f]]; //todo
	[self.headerLabel setTextColor:[UIColor whiteColor]];
	[self.headerLabel setTextAlignment:NSTextAlignmentCenter];
	[self.headerView addSubview: self.headerLabel];
}

// Onboarding delegate method
-(void) followingFriends {
	self.headerLabel.text = @"Follow your friends!";
	CGFloat followAllWidth = 150.f;
	UIButton *followAllButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x - followAllWidth/2.f,
																		   self.headerView.frame.size.height + 15.f,
																		   followAllWidth, 50.f)];
	followAllButton.backgroundColor = [UIColor clearColor];
	followAllButton.layer.borderColor = VERBATM_GOLD_COLOR.CGColor;
	followAllButton.layer.borderWidth = 3.f;
	followAllButton.layer.cornerRadius = 10.f;
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: VERBATM_GOLD_COLOR,
									  NSFontAttributeName: [UIFont fontWithName:REGULAR_FONT size:20.f]};
	NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:@"Follow All" attributes:titleAttributes];
	[followAllButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
	[followAllButton addTarget:self action:@selector(followAll) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview: followAllButton];
}

-(void) followAll {
	[self.discoverList followAllBlogs];
}

-(void)exitDiscover {
	[self.doneButton removeFromSuperview];
	[self performSegueWithIdentifier:SEGUE_CREATE_FIRST_POST sender: self];
}

-(void) addBackgroundImage {
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image =[UIImage imageNamed:DISCOVER_BACKGROUND];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:backgroundView belowSubview:self.tableContainerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Instantiation -

-(UIView*) headerView {
	if (!_headerView) {
		_headerView = [[UIView alloc] initWithFrame: CGRectMake(0.f, 0.f, self.view.frame.size.width, HEADER_VIEW_HEIGHT)];
		[_headerView setBackgroundColor:[UIColor colorWithRed:0.13 green:0.34 blue:0.6 alpha:1.f]];
	}
	return _headerView;
}

@end
