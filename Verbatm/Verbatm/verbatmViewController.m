//
//  verbatmViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 8/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmViewController.h"
#import <Parse/Parse.h>
#import "VerbatmUser.h"
#import "Article.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface verbatmViewController () <UITextFieldDelegate, AVCaptureFileOutputRecordingDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;

@property (strong, nonatomic) IBOutlet UIView *verbatmCameraView;
@property (weak, nonatomic) IBOutlet UILabel *testingLabel;
@property (weak, nonatomic) IBOutlet UIView *whiteBackgroundUIView;
@property (weak, nonatomic) IBOutlet UITextField *whereTextView;
@property (weak, nonatomic) IBOutlet UITextField *whatTextView;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong)UIImage* stillImage;
@property (strong, nonatomic) AVCaptureMovieFileOutput * movieOutputFile;
@property (strong, nonatomic) NSURL* verbatmFolderURL;
@property (strong, nonatomic) ALAssetsLibrary* assetLibrary;
@property (strong, nonatomic) ALAssetsGroup* verbatmAlbum;
@property (nonatomic, weak) CAShapeLayer *pathLayer;
@property (strong, nonatomic) UIImageView* videoProgressImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat counter;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;


#define SWITCH_ICON_SIZE 60
#define CAMERA_ICON @"switch_front3"
#define MAX_VIDEO_LENGTH 30
#define RGB_LEFT_SIDE 247, 0, 99, 1
#define RGB_RIGHT_SIDE 247, 0, 99, 1
#define RGB_BOTTOM_SIDE 247, 0, 99, 1
#define RGB_TOP_SIDE 247, 0, 99, 1

#define Y_OFFSET 80

@end

@implementation verbatmViewController

@synthesize stillImageOutput = _stillImageOutput;
@synthesize stillImage = _stillImage;
@synthesize verbatmFolderURL = _verbatmFolderURL;
@synthesize assetLibrary = _assetLibrary;
@synthesize verbatmAlbum = _verbatmAlbum;
@synthesize videoProgressImageView= _videoProgressImageView;
@synthesize timer = _timer;
@synthesize verbatmCameraView =_verbatmCameraView;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;


//Test function for top shadow
//Iain
-(void) addTopShadowToView: (UIView *) view
{
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    view.layer.shadowOpacity = 0.4f;
    view.layer.shadowPath = shadowPath.CGPath;
}


#pragma mark - creating album for verbatm

//Lucio
-(void)createVerbatmDirectory
{
    NSString* albumName = @"Verbatm";
    [self.assetLibrary addAssetsGroupAlbumWithName:albumName
                                       resultBlock:^(ALAssetsGroup *group) {
                                           NSLog(@"added album:%@", albumName);
                                       }
                                      failureBlock:^(NSError *error) {
                                          NSLog(@"error adding album");
                                      }];
    
    //gets the album once ints created.
    __weak verbatmViewController* weakSelf = self;
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                                        NSLog(@"found album %@", albumName);
                                        weakSelf.verbatmAlbum = group;
                                    }
                                }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                              }];
}


#pragma mark - saving photos and videos

//Lucio
-(void)saveImageToVerbatmFolder
{
    //    UIImageWriteToSavedPhotosAlbum(self.stillImage, self, nil, nil);
    //[[UIImage alloc] initWithCGImage:self.stillImage.CGImage scale:1 orientation:UIImageOrientationLeft];
    CGImageRef img = [self.stillImage CGImage];
    [self.assetLibrary writeImageToSavedPhotosAlbum:img
                                           metadata:nil
                                    completionBlock:^(NSURL* assetURL, NSError* error) {
                                        if (error.code == 0) {
                                            NSLog(@"saved image completed:\nurl: %@", assetURL);
                                            
                                            // try to get the asset
                                            [self.assetLibrary assetForURL:assetURL
                                                               resultBlock:^(ALAsset *asset) {
                                                                   // assign the photo to the album
                                                                   [self.verbatmAlbum addAsset:asset];
                                                                   NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], @"Verbatm");
                                                               }
                                                              failureBlock:^(NSError* error) {
                                                                  NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                              }];
                                        }
                                        else {
                                            NSLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                        }
                                    }];
}



#pragma mark - touch gesture selectors

//Lucio
- (IBAction)switch:(id)sender
{
    if(self.session)
    {
        //indicate that changes will be made to this session
        [self.session beginConfiguration];
        
        //remove existing input
        AVCaptureInput* currentInput = [self.session.inputs firstObject];
        currentInput = ([((AVCaptureDeviceInput*)currentInput).device hasMediaType:AVMediaTypeVideo])? currentInput : [self.session.inputs lastObject];
        [self.session removeInput:  currentInput];
        
        //get a new input
        AVCaptureDevice* newCamera = nil;
        if(((AVCaptureDeviceInput*)currentInput).device.position == AVCaptureDevicePositionFront ){
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionBack];
        }else{
            newCamera = [self getCameraWithOrientation:AVCaptureDevicePositionFront];
        }
        
        AVCaptureDeviceInput* newInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        [self.session addInput:newInput];
        //commit the changes made
        
        [self.session commitConfiguration];
    }

}

//by Lucio Dery
//changes the camera orientation to front
-(AVCaptureDevice*)getCameraWithOrientation: (NSInteger)orientation
{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice* device in devices){
        if([device position] == orientation){
            return device;
        }
    }
    return nil;
}

//by Lucio
-(IBAction)extendScreen:(id)sender
{
    [self changeImageScreenBounds];
}

//Lucio
-(void) changeImageScreenBounds
{
    [UIView animateWithDuration:0.5 animations:^{
        self.verbatmCameraView.frame = self.baseView.frame;
        UIDevice* currentDevice = [UIDevice currentDevice];
        if(currentDevice.orientation == UIDeviceOrientationLandscapeRight|| [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft){
            self.verbatmCameraView.frame = CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y, self.baseView.frame.size.height, self.baseView.frame.size.width);
        }
        [self setCorrectVideoOrientaion:currentDevice.orientation];
        self.captureVideoPreviewLayer.frame = self.verbatmCameraView.frame;
        //self.captureVideoPreviewLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
    }];
}

//by Lucio
-(void)setCorrectVideoOrientaion:(UIDeviceOrientation)orientation
{
    if(orientation == UIDeviceOrientationLandscapeLeft){
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }else if (orientation == UIDeviceOrientationLandscapeRight){
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }else if (orientation == UIDeviceOrientationPortraitUpsideDown){
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }else{
        self.captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}

//by Lucio
-(IBAction)raiseScreen:(id)sender
{
    BOOL canRaise = self.verbatmCameraView.frame.size.height == self.baseView.frame.size.height;
    if(canRaise){
        [UIView animateWithDuration:0.5 animations:^{
            self.verbatmCameraView.frame = CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y, self.baseView.frame.size.width, self.baseView.frame.size.height/2);
            self.captureVideoPreviewLayer.frame = self.verbatmCameraView.frame;
            [self setCorrectVideoOrientaion:[UIDevice currentDevice].orientation];
           //self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton* overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:CAMERA_ICON] forState:UIControlStateNormal];
    
    [overlayButton setFrame:CGRectMake(250, 10,SWITCH_ICON_SIZE , SWITCH_ICON_SIZE)];
    [overlayButton addTarget:self action:@selector(switch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:overlayButton];
    
    
//    UIButton* overlayTakePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
//    [overlayTakePhoto setImage:[UIImage imageNamed:CAMERA_ICON] forState:UIControlStateNormal];
//    
//    [overlayTakePhoto setFrame:CGRectMake(150, 150, 60 , 60)];
//    [overlayTakePhoto addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:overlayTakePhoto];
//
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    [self createVerbatmDirectory];
    self.verbatmCameraView = [[UIView alloc]initWithFrame:CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y, self.baseView.frame.size.width, self.baseView.frame.size.height/2)];
    [self.view addSubview:self.verbatmCameraView];
    [self createVideoProgressView];
    [self createTapGesture];
    [self createLongPressGesture];
    [self createSlideDownGesture];
    [self createSlideUpGesture];
    //[self addTopShadowToView:self.whiteBackgroundUIView];
}

#pragma mark -create video progess bar

-(void)createVideoProgressView
{
    self.videoProgressImageView =  [[UIImageView alloc] initWithImage:nil];
    self.videoProgressImageView.backgroundColor = [UIColor clearColor];
    self.videoProgressImageView.frame = CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y, self.baseView.frame.size.width, self.baseView.frame.size.height/2);
    [self.view addSubview: self.videoProgressImageView];
    CGRect frame =  CGRectMake(self.baseView.frame.origin.x, self.baseView.frame.origin.y + self.baseView.frame.size.height/2, self.baseView.frame.size.width, self.baseView.frame.size.height/2);
    self.whiteBackgroundUIView.frame = frame;
}

#pragma mark -creating gestures

-(void) createTapGesture
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    tap.numberOfTapsRequired = 1;
    [self.verbatmCameraView addGestureRecognizer:tap];
}

-(void) createLongPressGesture
{
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(takeVideo:)];
    longPress.minimumPressDuration = 1;
    [self.verbatmCameraView addGestureRecognizer:longPress];
}

-(void)createSlideDownGesture
{
    UISwipeGestureRecognizer* swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(extendScreen:)];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.verbatmCameraView addGestureRecognizer:swipeDownGesture];
}

-(void)createSlideUpGesture
{
    UISwipeGestureRecognizer* swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(raiseScreen:)];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.verbatmCameraView addGestureRecognizer:swipeUpGesture];
}

#pragma mark - view did appear and did load

-(void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
	
	
	//----- SHOW LIVE CAMERA PREVIEW -----
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPresetMedium;           //mayfix aspect ratio
    [self addStillImageOutput];
	
	self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
	
	self.captureVideoPreviewLayer.frame = self.verbatmCameraView.frame;
    self.captureVideoPreviewLayer.videoGravity =  AVLayerVideoGravityResizeAspectFill;
	[self.verbatmCameraView.layer addSublayer:self.captureVideoPreviewLayer];
	   
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [device lockForConfiguration:nil]){
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];  //added
        [device unlockForConfiguration];
    }
    
    AVCaptureDevice* audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
	
	NSError *errorVideo = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&errorVideo];
    
    NSError* error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
	if (!input || !audioInput) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    [self createVerbatmDirectory];
	[self.session addInput:input];
    [self.session addInput:audioInput];
    if([self.session canAddOutput:self.movieOutputFile]){
        [self.session addOutput: self.movieOutputFile];   //need to check if it cant
    }else{
        NSLog(@"couldn't add output");
    }
	[self.session startRunning];
}


-(BOOL) textFieldShouldReturn:(UITextField *)theTextField {
	if(theTextField == self.whereTextView)
    {
        [self.whereTextView resignFirstResponder];
    
    }else if(theTextField == self.whatTextView)
    {
        [self.whatTextView resignFirstResponder];
    }
	return YES;
}


//test function - not permanent 
-(void) buildRelationshipsBetween:(VerbatmUser *) me and: (VerbatmUser *) them
{
   // [me followUser:them];
    //[me endorseUser:them];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Lucio
-(void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary* outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    [self.session addOutput: self.stillImageOutput];
}

//Lucio
-(void)captureImage
{
    AVCaptureConnection* videoConnection = nil;
    for(AVCaptureConnection* connection in self.stillImageOutput.connections){
        for(AVCaptureInputPort* port in connection.inputPorts){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                videoConnection = connection;
                break;
            }
        }
        if(videoConnection){
            break;
        }
    }
    //AVCaptureConnection *conn = [self.videoCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    //[videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    //requesting a capture
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData* dataForImage = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self processImage:[[UIImage alloc] initWithData:dataForImage ]];
        [self saveImageToVerbatmFolder];
    }];
}


//Lucio
-(void)createVibrate
{
    CABasicAnimation* shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    [shakeAnimation setDuration:0.1];
    [shakeAnimation setRepeatCount:5];
    [shakeAnimation setAutoreverses: YES];
    [shakeAnimation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.verbatmCameraView center].x - 20.0f, [self.verbatmCameraView center].y)]];
    [shakeAnimation setToValue:[NSValue valueWithCGPoint:CGPointMake([self.verbatmCameraView center].x + 20.0f, [self.verbatmCameraView center].y + 20.0f)]];
    [self.verbatmCameraView.layer addAnimation:shakeAnimation forKey:@"postion"];
}

//Lucio
-(void)slidePictureOut
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setDuration:0.5f];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [self.verbatmCameraView.layer addAnimation:animation forKey:NULL];
}


//Lucio
- (IBAction)takePhoto:(id)sender
{
    [self captureImage];
    //[self createVibrate];
    [self slidePictureOut];
}


#pragma mark - video recording
//Lucio
-(IBAction)takeVideo:(id)sender
{
    UITapGestureRecognizer* recognizer = [self.verbatmCameraView.gestureRecognizers objectAtIndex:1];
    if(recognizer.state == UIGestureRecognizerStateBegan){
        [self startVideoRecording];
        self.counter = 0;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(createProgressPath) userInfo:nil repeats:YES];
    }else{
        if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateFailed ||
           recognizer.state == UIGestureRecognizerStateCancelled){
            [self stopVideoRecording];
            [self clearVideoProgressImage];
            [self.timer invalidate];
            self.counter = 0;
        }
    }
}

//Lucio
-(void)clearVideoProgressImage
{
    self.videoProgressImageView.image = nil;
}

//Lucio
-(void)createProgressPath
{
    self.counter += 0.05;
    UIGraphicsBeginImageContext(self.videoProgressImageView.frame.size);
    [self.videoProgressImageView.image drawInRect:self.videoProgressImageView.frame];
    self.videoProgressImageView.frame = self.verbatmCameraView.frame;
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 12.0);
    if(self.counter < MAX_VIDEO_LENGTH/8){
        //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 246, 0, 99, 1);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width/2, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake((self.videoProgressImageView.frame.size.width/2)*(1 - (self.counter/ (MAX_VIDEO_LENGTH/8))), self.videoProgressImageView.frame.size.height);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= MAX_VIDEO_LENGTH/8 && self.counter < (MAX_VIDEO_LENGTH*3)/8){
        //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),0, 0,1,1);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(),RGB_LEFT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(0, self.videoProgressImageView.frame.size.height - (self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH/8))/(MAX_VIDEO_LENGTH*2/8))));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*3)/8  && self.counter < (MAX_VIDEO_LENGTH*5)/8 ){
        //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0 ,1,1);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_TOP_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(0, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width*((self.counter - (MAX_VIDEO_LENGTH*3/8))/ (MAX_VIDEO_LENGTH*2/8)), 0);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else if (self.counter >= (MAX_VIDEO_LENGTH*5)/8  && self.counter < (MAX_VIDEO_LENGTH*7)/8){
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_RIGHT_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, 0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height*((self.counter - (MAX_VIDEO_LENGTH*5)/8)/ (MAX_VIDEO_LENGTH*2/8)));
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }else{
        //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 246, 0, 99, 1);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), RGB_BOTTOM_SIDE);
        CGContextBeginPath(UIGraphicsGetCurrentContext());
        CGPoint start = CGPointMake(self.videoProgressImageView.frame.size.width, self.videoProgressImageView.frame.size.height);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), start.x , start.y);
        CGPoint end = CGPointMake(self.videoProgressImageView.frame.size.width - ((self.videoProgressImageView.frame.size.width/2)*(self.counter - ((MAX_VIDEO_LENGTH*7)/8))/(MAX_VIDEO_LENGTH/8)), self.videoProgressImageView.frame.size.height);
         CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), end.x, end.y);
    }
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.videoProgressImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    [self.view addSubview: self.videoProgressImageView];
}

//Lucio
-(void)startVideoRecording
{
    NSLog(@"video is recording");
    NSString *movieOutput = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:movieOutput];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:movieOutput])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:movieOutput error:&error] == NO)
        {
            NSLog(@"output path  is wrong");
        }
    }
    //Start recording
    [self.movieOutputFile startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

//Lucio
-(void)stopVideoRecording
{
    [self.movieOutputFile stopRecording];
}

//Lucio
-(AVCaptureMovieFileOutput*)movieOutputFile
{
    if(!_movieOutputFile){
        _movieOutputFile = [[AVCaptureMovieFileOutput alloc]init];
        int64_t numSeconds = 960;
        int32_t framesPerSecond = 32;
        CMTime maxDuration = CMTimeMake(numSeconds, framesPerSecond);
        _movieOutputFile.maxRecordedDuration = maxDuration;
    }
    return _movieOutputFile;
}

#pragma mark Required protocol methods for AVCapture
//Lucio

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([self.assetLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]){
        [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            [self.assetLibrary assetForURL:assetURL
                               resultBlock:^(ALAsset *asset) {
                                   // assign the photo to the album
                                   [self.verbatmAlbum addAsset:asset];
                                   NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], @"Verbatm");
                               }
                              failureBlock:^(NSError* error) {
                                  NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                              }];
        }];
    }else{
        NSLog(@"wrong output location");
    }
}



//Lucio
//Directly from stack overflow
-(void)processImage:(UIImage*)image
{
    
    self.stillImage = [self rotateImageToRightOrientation:image withPreviousOrientation:image.imageOrientation];
    if([UIDevice currentDevice].userInterfaceIdiom ==UIUserInterfaceIdiomPad) { //Device is ipad
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
        [image drawInRect: CGRectMake(self.baseView.frame.origin.x,self.baseView.frame.origin.y, image.size.width, image.size.height )];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGRect cropRect = self.captureVideoPreviewLayer.frame;
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        self.stillImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }else{ //Device is iphone
        // Resize image
        NSLog(@"was here");
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
        NSLog(@"image dimensions %f, %f",image.size.width, image.size.height);
        [image drawInRect: CGRectMake(self.baseView.frame.origin.x,self.baseView.frame.origin.y,  image.size.width, image.size.height )];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGRect cropRect = ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp)? CGRectMake(0, Y_OFFSET, self.view.frame.size.width,(self.view.frame.size.height/2)): CGRectMake(self.verbatmCameraView.frame.origin.x,self.verbatmCameraView.frame.origin.y,  self.verbatmCameraView.frame.size.height - 80, self.verbatmCameraView.frame.size.width - 150);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        self.stillImage = [UIImage imageWithCGImage:imageRef];
        NSLog(@"cropped image dimensions %f, %f",cropRect.size.width, cropRect.size.height);
        CGImageRelease(imageRef);
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self changeImageScreenBounds];
}

-(UIImage*)rotateImageToRightOrientation:(UIImage*)initImage withPreviousOrientation:(UIImageOrientation)orientation
{
    if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp ){
        NSLog(@"hEREE 1");
        initImage= [self rotateUIImage:initImage clockwise:YES];
    }else if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft){
        NSLog(@"hEREE 2");
        initImage = [self rotateUIImage:initImage clockwise:NO];
        initImage = [self rotateUIImage:initImage clockwise:NO];
        initImage = [self rotateUIImage:initImage clockwise:NO];
        initImage = [self rotateUIImage:initImage clockwise:NO];
    }else{
        NSLog(@"hEREE 3");
        initImage = [self rotateUIImage:initImage clockwise:YES];
        initImage = [self rotateUIImage:initImage clockwise:YES];
        
    }
    return initImage;
}

- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
