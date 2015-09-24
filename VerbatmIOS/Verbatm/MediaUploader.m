//
//  ImageVideoUpload.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/10/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "MediaUploader.h"


@interface MediaUploader()

@property (nonatomic, strong) ASIFormDataRequest *formData;
@property (strong, nonatomic) MediaUploadCompletionBlock completionBlock;

@end


@implementation MediaUploader

@synthesize formData, progress;

-(instancetype) initWithImage:(UIImage*)img andUri: (NSString*)uri {

	NSLog(@"Uploading image to blobstore with url: %@", uri);

	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];
	[self.formData setData:imageData
			  withFileName:@"defaultImage.png"
			andContentType:@"image/png"
					forKey:@"defaultImage"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];
	// Needs to be long in order to allow long videos to upload
	[self.formData setTimeOutSeconds: 60];

	return self;
}

//Maybe could do this with Promise NSURLConnection?
-(instancetype) initWithVideoData: (NSData*)videoData  andUri: (NSString*)uri {

	NSLog(@"Uploading video to blobstore with url: %@", uri);

	self.formData = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uri]];

	[self.formData setData:videoData
			  withFileName:@"defaultVideo.mov"
			andContentType:@"video/quicktime"
					forKey:@"defaultVideo"];
	[self.formData setDelegate:self];
	[self.formData setUploadProgressDelegate:self];
	[self.formData setTimeOutSeconds: 180];

	return self;
}

-(AnyPromise*) startUpload {

	AnyPromise* promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
		[self startWithCompletionHandler: ^(NSError* error, NSString* responseURL) {
			if (error) {
				resolve(error);
			} else {
				resolve(responseURL);
			}
		}];
	}];

	return promise;
}

-(void) startWithCompletionHandler:(MediaUploadCompletionBlock) completionBlock {
	self.completionBlock = completionBlock;
	[self.formData startAsynchronous];
}

#pragma mark Delegate methods

- (void)request:(ASIHTTPRequest *)theRequest didSendBytes:(long long)newLength {

	if ([theRequest totalBytesSent] > 0) {
		float progressAmount = (float) ([theRequest totalBytesSent]/[theRequest postLength]);
		self.progress = progressAmount;
	}
}

-(void) requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"upload media finished");
	//The response string is a blobkeystring and an imagesservice servingurl for image
	NSString* responseString = [request responseString];
	if (!responseString.length) {
		[self requestFailed:request];
	} else {
		self.completionBlock(nil, responseString);
	}
}

-(void) requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"error uploading media%@", error);
	self.completionBlock(error, nil);
}


@end