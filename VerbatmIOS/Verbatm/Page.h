//
//  Page.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "PinchView.h"
#import "Article.h"
@class Photo;
@class Video;

@interface Page : PFObject
#pragma mark - required subclassing methods
+(NSString*)parseClassName;
+(void)load;

#pragma mark - methods for getting and setting page properties - 
-(instancetype)initWithPinchObject:(PinchView*)pinchView Article: (Article *) article andPageNumber:(NSInteger) position;
-(NSString*)getText;

//This method blocks//
/*This method returns the media that make up the page. Index 0 of the array always contains the text of the page: this is nil if the containsText boolean of the page is false. Index 1 contains an array of all the videos of the page; the array has the videos as NSData.
 Index 2 has an array of the photos of the page each of which is a UIImage.
 */
//-(NSMutableArray*)getMedia;
-(NSMutableArray*)getPhotos;
-(NSMutableArray*)getVideos;

-(NSInteger) numTypesOfMedia;

/*This method blocks*/
/*Reconstructs a pinch object from a page*/
-(PinchView*)getPinchObjectWithRadius:(float)radius andCenter:(CGPoint)center;

#pragma mark - bools to tell what type of media make up page -
@property (readonly,nonatomic) BOOL containsText;
@property (readonly, nonatomic) BOOL containsVideo;
@property (readonly, nonatomic) BOOL containsImage;
@property (readonly,nonatomic) NSInteger pagePosition;//indexed from 0 tells you the position of the page in the article

@end