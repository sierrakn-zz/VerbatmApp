//
//  v_Analyzer.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "PageTypeAnalyzer.h"
#import <PromiseKit/PromiseKit.h>

#import "CollectionPinchView.h"

#import "ImagePinchView.h"

#import <Parse/PFObject.h>
#import "PhotoVideoPVE.h"
#import "PhotoPVE.h"
#import "PinchView.h"
#import "ParseBackendKeys.h"
#import "Photo_BackendObject.h"
#import "PhotoPveEditView.h"
#import "SizesAndPositions.h"
#import "Styles.h"

#import "UtilityFunctions.h"

#import "VideoPinchView.h"
#import "VideoPveEditingView.h"
#import "VideoPVE.h"
#import "Video_BackendObject.h"
#import "VideoDownloadManager.h"

@interface PageTypeAnalyzer()

#define GET_VIDEO_URI @"https://verbatmapp.appspot.com/serveVideo"
#define BLOBKEYSTRING_KEY @"blob-key"

@end


@implementation PageTypeAnalyzer


+(NSMutableArray*) getPreviewPagesFromPinchviews:(NSArray*) pinchViews withFrame:(CGRect)frame{
	NSMutableArray* results = [[NSMutableArray alloc] init];
	
    for(int i = 0; i < pinchViews.count; i++) {
		PinchView *pinchView = pinchViews[i];
		PageViewingExperience *pageView = [self getPageViewFromPinchView:pinchView withFrame:frame];
		pageView.indexInPost = i;
		[results addObject:pageView];
	}
    
	return results;
}

+(PageViewingExperience *) getPageViewFromPinchView: (PinchView*) pinchView withFrame: (CGRect) frame {
	if (pinchView.containsImage && pinchView.containsVideo) {
		PhotoVideoPVE *photoVideoPageView = [[PhotoVideoPVE alloc] initWithFrame:frame andPinchView:(CollectionPinchView *)pinchView inPreviewMode:YES];
		return photoVideoPageView;

	} else if (pinchView.containsImage) {
        PhotoPVE *photoPageView;
        
            photoPageView = [[PhotoPveEditView alloc] initWithFrame:frame andPinchView:pinchView isPhotoVideoSubview:NO];
		return photoPageView;

	} else {
		VideoPveEditingView *videoPageView = [[VideoPveEditingView alloc] initWithFrame:frame andPinchView:pinchView isPhotoVideoSubview:NO];
		return videoPageView;
	}
}

+(void) getPageMediaFromPage: (PFObject *)page withCompletionBlock:(void(^)(NSArray *))block {
	PageTypes type = [((NSNumber *)[page valueForKey:PAGE_VIEW_TYPE]) intValue];
	if (type == PageTypePhoto) {
		[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray * imagesAndText) {
			block(@[[NSNumber numberWithInt:type], imagesAndText]);
		}];
	} else if (type == PageTypeVideo){
		[self getVideoFromPage:page withCompletionBlock:^(NSArray *videoAndThumbnail) {
			block(@[[NSNumber numberWithInt:type], videoAndThumbnail]);
		}];
	} else if( type == PageTypePhotoVideo){
		[self getVideoFromPage:page withCompletionBlock:^(NSArray *videoAndThumbnail) {
			[self getUIImagesFromPage:page withCompletionBlock:^(NSMutableArray* imagesAndText) {
				block(@[[NSNumber numberWithInt:type], imagesAndText, videoAndThumbnail]);
			}];
		}];
	}
}

/* photoTextArray is array containing subarrays of photo and text info
 @[@[url, uiimage, text, textYPosition, textColor, textAlignment, textSize],...] */
+(void) getUIImagesFromPage: (PFObject *) page withCompletionBlock:(void(^)(NSMutableArray *)) block{

	[Photo_BackendObject getPhotosForPage:page andCompletionBlock:^(NSArray * photoObjects) {

		NSMutableArray* imageUrls = [[NSMutableArray alloc] init];
		for (PFObject * imageAndTextObj in photoObjects) {
			NSString * photoUrlString = [imageAndTextObj valueForKey:PHOTO_IMAGEURL_KEY];
			// Don't want high quality image for this - just loading thumbnails
			[imageUrls addObject: photoUrlString];
		}

		[self getThumbnailDatafromUrls:imageUrls withCompletionBlock:^(NSArray *imageData) {
			NSMutableArray* imageTextArrays = [[NSMutableArray alloc] init];
			for (int i = 0; i < photoObjects.count; i++) {
				if ([imageData[i] isEqual:[NSNull null]]) {
					continue;
				}
				PFObject * imageAndTextObj = photoObjects[i];
				NSString * photoUrlString = [imageAndTextObj valueForKey:PHOTO_IMAGEURL_KEY];

				NSURL *photoURL = [NSURL URLWithString:photoUrlString];

				NSString *text =  [imageAndTextObj valueForKey:PHOTO_TEXT_KEY];
				NSNumber *yOffset = [imageAndTextObj valueForKey:PHOTO_TEXT_YOFFSET_KEY];

				NSData *textColorData = [imageAndTextObj valueForKey:PHOTO_TEXT_COLOR_KEY];
				UIColor *textColor = textColorData == nil ? nil : [NSKeyedUnarchiver unarchiveObjectWithData:textColorData];
				if (textColor == nil) textColor = [UIColor TEXT_PAGE_VIEW_DEFAULT_COLOR];
				NSNumber *textAlignment = [imageAndTextObj valueForKey:PHOTO_TEXT_ALIGNMENT_KEY];
				if (textAlignment == nil) textAlignment = [NSNumber numberWithInt:0];
				NSNumber *textSize = [imageAndTextObj valueForKey:PHOTO_TEXT_SIZE_KEY];
				if (textSize == nil) textSize = [NSNumber numberWithFloat:TEXT_PAGE_VIEW_DEFAULT_FONT_SIZE];

				[imageTextArrays addObject: @[photoURL, [UIImage imageWithData:imageData[i]], text,
											  yOffset, textColor, textAlignment, textSize]];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				block(imageTextArrays);
			});
		}];
	}];
}

+(void)getThumbnailDatafromUrls:(NSArray *)urls withCompletionBlock:(void(^)(NSArray *)) block {

	NSMutableArray* loadImageDataPromises = [[NSMutableArray alloc] init];
	for (NSString *uri in urls) {
		NSString *smallImageUrl = [UtilityFunctions addSuffixToPhotoUrl:uri forSize: THUMBNAIL_IMAGE_SIZE];
		AnyPromise* getImageDataPromise = [[UtilityFunctions sharedInstance] loadCachedPhotoDataFromURL: [NSURL URLWithString: smallImageUrl]];
		[loadImageDataPromises addObject: getImageDataPromise];
	}
	PMKWhen(loadImageDataPromises).then(^(NSArray* results) {
		block(results);
	});
}

//Video array looks like @[URL, thumbnail]
+(void) getVideoFromPage: (PFObject*) page withCompletionBlock:(void(^)(NSArray *)) block{

//	NSDate *before = [NSDate date];
	[Video_BackendObject getVideoForPage:page andCompletionBlock:^(PFObject *videoObject) {

//		NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate: before];
//		NSLog(@"%@",[NSString stringWithFormat:@"Time loading parse video objects %f seconds \n\n", timeInterval]);

		//get thumbnail url for video
		NSString * thumbNailUrl = [videoObject valueForKey:VIDEO_THUMBNAIL_KEY];

		//download all thumbnail urls for videos
		[self getThumbnailDatafromUrls:@[thumbNailUrl] withCompletionBlock:^(NSArray * videoThumbNails) {

			NSString * videoBlobKey = [videoObject valueForKey:BLOB_STORE_URL];
			NSURLComponents *components = [NSURLComponents componentsWithString: GET_VIDEO_URI];
			NSURLQueryItem* blobKey = [NSURLQueryItem queryItemWithName:BLOBKEYSTRING_KEY value: videoBlobKey];
			components.queryItems = @[blobKey];

			UIImage * thumbNail = (![videoThumbNails[0] isEqual:[NSNull null]]) ? [UIImage imageWithData:videoThumbNails[0]] : nil;
			block(@[components.URL, thumbNail]);
		}];
		
	}];
}

@end
