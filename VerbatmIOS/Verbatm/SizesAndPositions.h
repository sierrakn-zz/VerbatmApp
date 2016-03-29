//
//  Sizes.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef SizesAndPositions_h
#define SizesAndPositions_h

#define CHANNEL_NAME_CHARACTER_LIMIT 20

#define INTRO_NOTIFICATION_SIZE 250.f

#pragma mark - Main Tab bar -

#define TAB_BUTTON_PADDING 12.f
#define TAB_DIVIDER_WIDTH 2.f
#define TAB_BAR_HEIGHT 40.f



#pragma mark - Custom Navigation Bar -

#define CUSTOM_NAV_BAR_HEIGHT 40.f
#define BAR_TOP_OFFSET 10.f
#define NAV_BAR_HEIGHT 50.f
#define NAV_ICON_OFFSET 7.f
#define NAV_ICON_SIZE (NAV_BAR_HEIGHT - NAV_ICON_OFFSET*2)



#pragma mark - Sign In -

#define SIGN_IN_ERROR_VIEW_HEIGHT 100.f
#define SIGNIN_ERROR_LABEL_PADDING 30.f



#pragma mark - ADK -

#pragma mark - Media Dev VC

#define SWITCH_ORIENTATION_ICON_SIZE 70.f
#define FLASH_ICON_SIZE_HEIGHT 70.f
#define FLASH_ICON_SIZE_WIDTH 25.f
#define CAPTURE_MEDIA_BUTTON_SIZE 100.f
#define CLOSE_CAMERA_BUTTON_SIZE 40.f

#define PROGRESS_CIRCLE_SIZE 100.f
#define PROGRESS_CIRCLE_THICKNESS 10.0f
#define PROGRESS_CIRCLE_OPACITY 0.6f

#define CAPTURE_MEDIA_BUTTON_OFFSET 10.f

#define TRANSLATION_CONTENT_DEV_CONTAINER_VIEW_THRESHOLD 50.f

#pragma mark - Content Dev VC

#define AUTO_SCROLL_OFFSET 10
#define CONTENT_SIZE_OFFSET 20
#define ELEMENT_Y_OFFSET_DISTANCE 25
#define ELEMENT_X_OFFSET_DISTANCE 50
#define CENTERING_OFFSET_FOR_TEXT_VIEW 30

#pragma mark Delete icon

#define DELETE_ICON_X_OFFSET 20
#define DELETE_ICON_Y_OFFSET 50
#define DELETE_ICON_WIDTH 20
#define DELETE_ICON_HEIGHT 26

#pragma mark - Gallery

#define GALLERY_COLUMNS_PORTRAIT 3
#define GALLERY_COLUMNS_LANDSCAPE 5

#pragma mark - Editing Content View

#define EXIT_CV_BUTTON_WIDTH 42
#define EXIT_CV_BUTTON_HEIGHT 30
#define EXIT_CV_BUTTON_WALL_OFFSET 20

#pragma mark Toolbar

#define TEXT_TOOLBAR_HEIGHT 35.f
#define TEXT_TOOLBAR_BUTTON_OFFSET 9.f
#define TEXT_TOOLBAR_BUTTON_WIDTH 25.f
#define TEXT_TOOLBAR_DONE_WIDTH 75.f

#pragma mark - Preview

#define PUBLISH_BUTTON_OFFSET 20.f
#define PUBLISH_BUTTON_SIZE 75.f
#define BACK_BUTTON_OFFSET 10.f

#pragma mark PinchViews

#define ELEMENT_Y_OFFSET_DISTANCE 25
#define PINCHVIEW_DIVISION_FACTOR_FOR_TWO 2
#define MIN_PINCHVIEW_SIZE 100
//distance two fingers must travel for the horizontal pinch to be accepted
#define HORIZONTAL_PINCH_THRESHOLD 100
#define PINCH_VIEW_DELETING_THRESHOLD 80
#define PINCH_DISTANCE_THRESHOLD_FOR_NEW_MEDIA_TILE_CREATION (MEDIA_TILE_SELECTOR_HEIGHT * 3.f/4.f)

#pragma mark Media Select Tile

#define MEDIA_TILE_SELECTOR_HEIGHT 80.f
#define ADD_MEDIA_BUTTON_OFFSET 10



#pragma mark - Feed -

#define FOLLOW_BUTTON_HEIGHT SETTINGS_BUTTON_SIZE
#define FOLLOW_BUTTON_WIDTH (FOLLOW_BUTTON_HEIGHT * FOLLOW_BUTTON_RATIO_FOR_WIDTH)
#define FOLLOW_BUTTON_RATIO_FOR_WIDTH (223.f / 234.f)
#define VIDEO_LOADING_ICON_SIZE 50

#pragma mark - Post View

#define CREATOR_CHANNEL_BAR_HEIGHT 35.f
#define TITLE_BAR_HEIGHT 60.f

#pragma mark - Like Share Bar

#define LIKE_SHARE_BAR_HEIGHT 50.f
#define LIKE_SHARE_BAR_BUTTON_SIZE 32.f
#define LIKE_SHARE_BAR_BUTTON_OFFSET 20.f
#define MUTE_BUTTON_OFFSET 10

#pragma mark - Page Views

#pragma mark Images

#define CIRCLE_RADIUS 45.f
#define CIRCLE_OFFSET (LIKE_SHARE_BAR_HEIGHT*2 + 10.f)

#define POINTS_ON_CIRCLE_RADIUS 10.f
#define TAP_THRESHOLD 20.f//the threshold to select a circle - but also to start panning
#define	SLIDE_THRESHOLD 70.f

#define TEXT_VIEW_X_OFFSET 10.f
#define TEXT_VIEW_OVER_MEDIA_Y_OFFSET 150.f
#define TEXT_VIEW_OVER_MEDIA_MIN_HEIGHT 70.f

#define PAN_CIRCLE_CENTER_Y (self.frame.size.height - CIRCLE_RADIUS - CIRCLE_OFFSET)


#pragma mark - Profile -

#define PROFILE_HEADER_HEIGHT 35.f
#define USER_CELL_VIEW_HEIGHT 40.f

#define CHANNEL_USER_LIST_CELL_HEIGHT 55.f

#define PROFILE_NAV_BAR_HEIGHT (PROFILE_HEADER_HEIGHT + USER_CELL_VIEW_HEIGHT)

#define CHANNEL_CREATION_VIEW_HEIGHT 120.f
#define CHANNEL_CREATION_VIEW_WIDTH 300.f
#define CHANNEL_CREATION_VIEW_Y_OFFSET (PROFILE_NAV_BAR_HEIGHT + 140.f)

//for PROFILE NAV BAR ARROW
#define ARROW_EXTENSION_BAR_HEIGHT 15.f
#define ARROW_FRAME_HEIGHT ARROW_EXTENSION_BAR_HEIGHT
#define ARROW_FRAME_WIDTH 30.f
#define ARROW_IMAGE_WALL_OFFSET 2.f

#define NO_POSTS_LABEL_WIDTH 300.f

#define THREAD_BAR_BUTTON_FONT_SIZE 17.f

#define SETTINGS_BUTTON_SIZE 25.f

#define CHANNEL_BUTTON_WALL_XOFFSET 10.f
#define CHANNEL_LIST_CELL_SEPERATOR_HEIGHT 1.f


#endif











