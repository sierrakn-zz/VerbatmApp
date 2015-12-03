//
//  ImagePinchView.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/26/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "PinchView.h"
#import "SingleMediaAndTextPinchView.h"

@interface ImagePinchView : SingleMediaAndTextPinchView

@property (strong, nonatomic) NSMutableArray* filteredImages;
@property (nonatomic) NSInteger filterImageIndex;

-(instancetype)initWithRadius:(float)radius withCenter:(CGPoint)center andImage:(UIImage*)image;

-(void) initWithImage:(UIImage*)image andSetFilteredImages: (BOOL) setFilters;

//change which filter is applied
-(void)changeImageToFilterIndex:(NSInteger)filterIndex;

//returns the image with its current filter 
-(UIImage*) getImage;

//returns the image without any filter - guaranteed to be unfiltered
-(UIImage *) getOriginalImage;

//replaces the current image with this image
-(void) putNewImage:(UIImage*)image;

@end
