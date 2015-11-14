//
//  Durations.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#ifndef Durations_h
#define Durations_h

#pragma mark - Sign In -

#define ERROR_MESSAGE_ANIMATION_TIME 3.f
#define REMOVE_SIGNIN_ERROR_VIEW_ANIMATION_DURATION 1.f

#pragma mark - Feed -

#define SNAP_ANIMATION_DURATION 0.1f

#define ARTICLE_DISPLAY_REMOVAL_ANIMATION_DURATION 0.4f
//the amount of space that must be pulled to exit
#define ARTICLE_DISPLAY_EXIT_EPSILON 60

#pragma mark - Media Dev VC -

#define PUBLISH_ANIMATION_DURATION 0.4f

#define CONTAINER_VIEW_TRANSITION_ANIMATION_TIME 0.5f
#define PULLBAR_TRANSITION_ANIMATION_TIME 0.3f
#define MINIMUM_PRESS_DURATION_FOR_VIDEO 0.3f
#define MAX_VID_SECONDS 30
#define TIME_FOR_SESSION_TO_RESUME_POST_MEDIA_CAPTURE 0.2f

#pragma mark - Content Dev VC -

#define REVEAL_NEW_MEDIA_TILE_ANIMATION_DURATION 1.f
//time it takes to animate a pinch
#define PINCHVIEW_ANIMATION_DURATION 0.5f
#define PINCHVIEW_DROP_ANIMATION_DURATION 1.f //the speed at which pinch objects fall into place after gallery

#define PINCHVIEW_DELETE_ANIMATION_DURATION 0.5f //the speed at which the pinch objet changes size before disappearing

#pragma mark - AVES -

#define AVE_VIEW_FILLS_SCREEN_DURATION 0.5f
#define CIRCLE_FADE_DURATION 0.5f
#define CIRCLE_REMAIN_DURATION 1.f
#define CIRCLE_FIRST_APPEAR_REMAIN_DURATION 2.f
#define CIRCLE_TAPPED_REMAIN_DURATION 1.5f

#endif /* Durations_h */
