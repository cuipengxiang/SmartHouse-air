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
        self.socketQueue = dispatch_queue_create("socketQueue3", NULL);
        //self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        skip = NO;
        self.query = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andModel:(SHCurtainModel *)model andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        self.controller = controller;
        [self setBackgroundColor:[UIColor clearColor]];
        self.model = model;
        self.CurtainImage = [[UIImageView alloc] initWithFrame:CGRectMake(53.0, 130.0, 494.0, 258.0)];
        NSString *curtainState = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"curtain%@%@", self.model.channel,self.model.area]];
        if (curtainState) {
            self.state = [curtainState integerValue];
            if (self.state == 0) {
                [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_closed"]];
            } else {
                [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_open"]];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"curtain%@%@", self.model.channel,self.model.area]];
            [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_closed"]];
        }
        [self addSubview:self.CurtainImage];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:model.name];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bg"]]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setFrame:CGRectMake((frame.size.width - 162.0)/2, 31.0, 162.0, 33.0)];
        [self addSubview:titleLabel];
        
        self.onButton = [[UIButton alloc] initWithFrame:CGRectMake(173.5, 380.0, 71.0, 48.0)];
        [self.onButton setImage:[UIImage imageNamed:@"btn_curtain_open_normal"] forState:UIControlStateNormal];
        [self.onButton setImage:[UIImage imageNamed:@"btn_curtain_open_pressed"] forState:UIControlStateHighlighted];
        [self.onButton addTarget:self action:@selector(onOnButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.onButton];
        
        self.offButton = [[UIButton alloc] initWithFrame:CGRectMake(264.5, 380.0, 71.0, 48.0)];
        [self.offButton setImage:[UIImage imageNamed:@"btn_curtain_close_normal"] forState:UIControlStateNormal];
        [self.offButton setImage:[UIImage imageNamed:@"btn_curtain_close_pressed"] forState:UIControlStateHighlighted];
        [self.offButton addTarget:self action:@selector(onOffButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.offButton];
        
        self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(355.5, 380.0, 71.0, 48.0)];
        [self.stopButton setImage:[UIImage imageNamed:@"btn_stop_normal"] forState:UIControlStateNormal];
        [self.stopButton setImage:[UIImage imageNamed:@"btn_stop_pressed"] forState:UIControlStateHighlighted];
        [self.stopButton addTarget:self action:@selector(onStopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.stopButton];

    }
    return self;
}

- (void)onOnButtonClick:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:[NSString stringWithFormat:@"curtain%@%@", self.model.channel,self.model.area]];
    [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_open"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", self.model.opencmd];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onOffButtonClick:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:[NSString stringWithFormat:@"curtain%@%@", self.model.channel,self.model.area]];
    [self.CurtainImage setImage:[UIImage imageNamed:@"curtain_closed"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", self.model.closecmd];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onStopButtonClick:(UIButton *)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myDelegate delegateQueue:self.myDelegate.socketQueue];
        socket.command = [NSString stringWithFormat:@"%@\r\n", self.model.stopcmd];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

/*
- (void)queryMode:(NSThread *)thread
{
    while ([[NSThread currentThread] isCancelled] == NO) {
        if (!skip) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
                NSError *error;
                GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
                socket.command = [NSString stringWithFormat:@"aircreply %@,%@\r\n", self.model.channel, self.model.area];
                [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
            });
        } else {
            skip = NO;
        }
        sleep(4);
    }
    [NSThread exit];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
