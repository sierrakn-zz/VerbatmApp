//
//  verbatmCustomMediaSelectTile.m
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomMediaSelectTile.h"
#import "verbatmDashLineView.h"

@interface verbatmCustomMediaSelectTile ()
    @property(nonatomic ,strong) UIButton * selectMedia;
    @property (nonatomic ,strong) UIButton * selectText;
@property (nonatomic, strong) verbatmDashLineView * dashedView;
    @property (nonatomic, strong) CAShapeLayer * border;
#define BUTTON_OFFSET 5
@end

@implementation verbatmCustomMediaSelectTile

#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createFramesForButtonsWithFrame: frame];
        [self addButtonsAsSubviews];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.selectText setBackgroundImage:[UIImage imageNamed:@"photo_button"] forState: UIControlStateNormal];
        [self.selectMedia setBackgroundImage:[UIImage imageNamed:@"text_button"] forState: UIControlStateNormal];
    }
    return self;
}

//Iain
-(void) createFramesForButtonsWithFrame: (CGRect) frame
{
    self.selectText.frame = CGRectMake(BUTTON_OFFSET, BUTTON_OFFSET, frame.size.width/2, frame.size.height-BUTTON_OFFSET*2);
    self.selectMedia.frame = CGRectMake(frame.size.width/2, BUTTON_OFFSET, frame.size.width/2-BUTTON_OFFSET, frame.size.height-BUTTON_OFFSET*2);
}
//Iain
-(void)addButtonsAsSubviews
{
    [self addSubview:self.selectText];
    [self addSubview:self.selectMedia];
}


-(void) addText
{
    [self.customDelegate addTextViewButtonPressedAsBaseView:self.baseSelector];
}

-(void) addMedia
{
    [self addDashedBorder];
    [self.customDelegate addMultiMediaButtonPressedAsBaseView:self.baseSelector];
}


#pragma mark - *Lazy Instantiation
-(UIButton *) selectMedia
{
    if(!_selectMedia)
    {
        _selectMedia = [[UIButton alloc]init];
        [_selectMedia addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectMedia;
}

-(UIButton *) selectText
{
    if(!_selectText) _selectText = [[UIButton alloc]init];
    [_selectText addTarget:self action:@selector(addMedia) forControlEvents:UIControlEventTouchUpInside];

    return _selectText;
}

-(void)addDashedBorder
{
    self.dashedView = [[verbatmDashLineView alloc]initWithFrame:self.bounds];
    [self.selectText removeFromSuperview];
    [self.selectMedia removeFromSuperview];
    [self.dashedView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.dashedView];
    
}

@end