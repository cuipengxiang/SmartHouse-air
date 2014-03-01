//
//  SHLightControlView.m
//  SmartHouse-Air
//
//  Created by Roc on 14-3-1.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHLightControlView.h"

#define BRIGHTNESS_DEGREE_BASE_TAG 3000

@implementation SHLightControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)titleString andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        self.controller = controller;
        [self setBackgroundColor:[UIColor clearColor]];
        self.Brightness = 0;
        
        self.on_off = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 400.0, 139.0, 48.0)];
        self.isNowOn = NO;
        [self.on_off setImage:[UIImage imageNamed:@"switch_btn_off"] forState:UIControlStateNormal];
        [self.on_off addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.on_off];
        
        self.BrightnessImage = [[UIImageView alloc] initWithFrame:CGRectMake(138.0, 24.0, 322.0, 336.0)];
        [self.BrightnessImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"lightball_lv%d", self.Brightness]]];
        [self addSubview:self.BrightnessImage];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:titleString];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor greenColor]];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake((frame.size.width - titleLabel.frame.size.width)/2, 21, titleLabel.frame.size.width, titleLabel.frame.size.height)];
        [self addSubview:titleLabel];
        
        self.BrightnessControl = [[UIView alloc] initWithFrame:CGRectMake(210.0, 400.0, 350.0, 48.0)];
        [self.BrightnessControl setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"brightness_bg"]]];
        [self addSubview:self.BrightnessControl];
        
        self.lessButton = [[UIButton alloc] initWithFrame:CGRectMake(2.0, 3.0, 50.0, 42.0)];
        [self.lessButton setImage:[UIImage imageNamed:@"less"] forState:UIControlStateNormal];
        [self.lessButton setImage:[UIImage imageNamed:@"less_pressed"] forState:UIControlStateHighlighted];
        [self.lessButton addTarget:self action:@selector(onLessButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.BrightnessControl addSubview:self.lessButton];
        self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(298.0, 3.0, 50.0, 42.0)];
        [self.moreButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.moreButton setImage:[UIImage imageNamed:@"more_pressed"] forState:UIControlStateHighlighted];
        [self.moreButton addTarget:self action:@selector(onMoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.BrightnessControl addSubview:self.moreButton];
        
        for (int i = 0; i < 10; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light_degree_empty"]];
            [imageView setFrame:CGRectMake(58.0 + 24.0 * i, 4.0, 18.0, 40.0)];
            [imageView setTag:i + BRIGHTNESS_DEGREE_BASE_TAG];
            [self.BrightnessControl addSubview:imageView];
        }
        
        [self setBrightnessDegree:2];
    }
    return self;
}

- (void)onSwitchButtonClick:(UIButton *)sender
{
    if (self.isNowOn) {
        [self setBrightnessDegree:0];
    } else {
        [self setBrightnessDegree:10];
    }
}

- (void)setBrightnessDegree:(int)degree
{
    self.Brightness = degree;
    if (degree > 0) {
        self.isNowOn = YES;
        [self.on_off setImage:[UIImage imageNamed:@"switch_btn_on"] forState:UIControlStateNormal];
    } else {
        self.isNowOn = NO;
        [self.on_off setImage:[UIImage imageNamed:@"switch_btn_off"] forState:UIControlStateNormal];
    }
    for (int i = BRIGHTNESS_DEGREE_BASE_TAG; i < BRIGHTNESS_DEGREE_BASE_TAG + 10; i++) {
        UIImageView *degreeImageView = (UIImageView *)[self.BrightnessControl viewWithTag:i];
        if (i < BRIGHTNESS_DEGREE_BASE_TAG + degree) {
            [degreeImageView setImage:[UIImage imageNamed:@"light_degree_normal"]];
        } else {
            [degreeImageView setImage:[UIImage imageNamed:@"light_degree_empty"]];
        }
    }
    [self.BrightnessImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"lightball_lv%d", self.Brightness]]];
}

- (void)onMoreButtonClick:(UIButton *)sender
{
    if (self.Brightness < 10) {
        [self setBrightnessDegree:self.Brightness + 1];
    } else {
        return;
    }
}

- (void)onLessButtonClick:(UIButton *)sender
{
    if (self.Brightness > 0) {
        [self setBrightnessDegree:self.Brightness - 1];
    } else {
        return;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
