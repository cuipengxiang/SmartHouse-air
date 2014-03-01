//
//  SHCurtainControlView.m
//  SmartHouse-Air
//
//  Created by Roc on 14-3-1.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHCurtainControlView.h"

#define CURTAIN_DEGREE_BASE_TAG 4000

@implementation SHCurtainControlView

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

        self.CurtainImage = [[UIImageView alloc] initWithFrame:CGRectMake(138.0, 24.0, 494.0, 258.0)];
        [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_closed"]];
        [self addSubview:self.CurtainImage];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:titleString];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor greenColor]];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake((frame.size.width - titleLabel.frame.size.width)/2, 21, titleLabel.frame.size.width, titleLabel.frame.size.height)];
        [self addSubview:titleLabel];
        
        self.onButton = [[UIButton alloc] initWithFrame:CGRectMake(2.0, 3.0, 50.0, 42.0)];
        [self.onButton setImage:[UIImage imageNamed:@"less"] forState:UIControlStateNormal];
        [self.onButton setImage:[UIImage imageNamed:@"less_pressed"] forState:UIControlStateHighlighted];
        [self.onButton addTarget:self action:@selector(onLessButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.onButton];
        
        self.offButton = [[UIButton alloc] initWithFrame:CGRectMake(298.0, 3.0, 50.0, 42.0)];
        [self.offButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.offButton setImage:[UIImage imageNamed:@"more_pressed"] forState:UIControlStateHighlighted];
        [self.offButton addTarget:self action:@selector(onMoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.offButton];
        
        self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(298.0, 3.0, 50.0, 42.0)];
        [self.stopButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [self.stopButton setImage:[UIImage imageNamed:@"more_pressed"] forState:UIControlStateHighlighted];
        [self.stopButton addTarget:self action:@selector(onMoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.stopButton];

    }
    return self;
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
