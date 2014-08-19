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
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(100.0, 105, 76.0, 76.0)];
    [self.playButton setImage:[UIImage imageNamed:@"mbtn_play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"mbtn_play_pressed"] forState:UIControlStateHighlighted];
    [self.playButton addTarget:self action:@selector(onPlayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playButton];
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(208.0, 105, 76.0, 76.0)];
    [self.pauseButton setImage:[UIImage imageNamed:@"mbtn_pause"] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:@"mbtn_pause_pressed"] forState:UIControlStateHighlighted];
    [self.pauseButton addTarget:self action:@selector(onPauseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.pauseButton];
    self.volAddButton = [[UIButton alloc] initWithFrame:CGRectMake(316.0, 105, 76.0, 76.0)];
    [self.volAddButton setImage:[UIImage imageNamed:@"mbtn_vol_add"] forState:UIControlStateNormal];
    [self.volAddButton setImage:[UIImage imageNamed:@"mbtn_vol_add_pressed"] forState:UIControlStateHighlighted];
    [self.volAddButton addTarget:self action:@selector(onVolAddButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.volAddButton];
    self.volSubButton = [[UIButton alloc] initWithFrame:CGRectMake(424.0, 105, 76.0, 76.0)];
    [self.volSubButton setImage:[UIImage imageNamed:@"mbtn_vol_sub"] forState:UIControlStateNormal];
    [self.volSubButton setImage:[UIImage imageNamed:@"mbtn_vol_sub_pressed"] forState:UIControlStateHighlighted];
    [self.volSubButton addTarget:self action:@selector(onVolSubButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.volSubButton];
    
    self.controlButtons = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.model.buttons.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100.0 + i%3*152.0, 216.0 + i/3*73.0, 96.0, 43.0)];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_music_control"] forState:UIControlStateNormal];
        [button setTitle:[[self.model.buttons objectAtIndex:i] name] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.263 green:0.255 blue:0.255 alpha:1] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [button addTarget:self action:@selector(onControlButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.controlButtons addObject:button];
        [self addSubview:button];
    }
}

- (void)onPlayButtonClicked
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", @"play"];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onPauseButtonClicked
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", @"pause"];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onVolAddButtonClicked
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", @"voladd"];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onVolSubButtonClicked
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", @"volsub"];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onControlButtonClicked:(UIButton *)button
{
    int index = [self.controlButtons indexOfObject:button];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", [[self.model.buttons objectAtIndex:index] command]];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

@end
