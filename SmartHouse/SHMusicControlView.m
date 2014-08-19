//
//  SHMusicControlView.m
//  SmartHouse-Air
//
//  Created by Roc on 14-8-19.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHMusicControlView.h"

@implementation SHMusicControlView

- (id)initWithFrame:(CGRect)frame andModel:(SHMusicModel *)model andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        self.controller = controller;
        self.model = model;
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:model.name];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bg"]]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFrame:CGRectMake((frame.size.width - 162.0)/2, 31.0, 162.0, 33.0)];
        [self addSubview:titleLabel];
        self.socketQueue = dispatch_queue_create("socketQueue5", NULL);
        skip = NO;
        self.query = NO;
        [self setDetailWithModel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDetailWithModel
{

}

@end
