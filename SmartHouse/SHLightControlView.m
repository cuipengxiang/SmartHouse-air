//
//  SHLightControlView.m
//  SmartHouse-Air
//
//  Created by Roc on 14-3-1.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHLightControlView.h"
#import "RegexKitLite.h"

#define BRIGHTNESS_DEGREE_BASE_TAG 3000

@implementation SHLightControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.socketQueue = dispatch_queue_create("socketQueue2", NULL);
        self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        skip = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andModel:(SHLightModel *)model andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.controller = controller;
        [self setBackgroundColor:[UIColor clearColor]];
        self.Brightness = 0;
        self.model = model;
        self.on_off = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 400.0, 139.0, 48.0)];
        self.isNowOn = NO;
        [self.on_off setImage:[UIImage imageNamed:@"switch_btn_off"] forState:UIControlStateNormal];
        [self.on_off addTarget:self action:@selector(onSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.on_off];
        
        self.BrightnessImage = [[UIImageView alloc] initWithFrame:CGRectMake(138.0, 24.0, 322.0, 336.0)];
        [self.BrightnessImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"lightball_lv%d", self.Brightness]]];
        [self addSubview:self.BrightnessImage];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:model.name];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bg"]]];
        [titleLabel setFrame:CGRectMake((frame.size.width - 162.0)/2, 31.0, 162.0, 33.0)];
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
        
        [self setBrightnessDegree:0];
        
        if (![self.myModeThread isExecuting]) {
            [self.myModeThread start];
        }
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
    [self sendCommand];
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

- (void)sendCommand
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.controller delegateQueue:self.controller.socketQueue];
        NSString *command = [NSString stringWithFormat:@"*channellevel %@,%d,%@,%@", self.model.channel, self.Brightness*10, self.model.area, self.model.fade];
        socket.command = [NSString stringWithFormat:@"%@\r\n", command];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)onMoreButtonClick:(UIButton *)sender
{
    if (self.Brightness < 10) {
        [self setBrightnessDegree:self.Brightness + 1];
        [self sendCommand];
    } else {
        return;
    }
}

- (void)onLessButtonClick:(UIButton *)sender
{
    if (self.Brightness > 0) {
        [self setBrightnessDegree:self.Brightness - 1];
        [self sendCommand];
    } else {
        return;
    }
}

- (void)queryMode:(NSThread *)thread
{
    while ([[NSThread currentThread] isCancelled] == NO) {
        if (!skip) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
                NSError *error;
                GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
                socket.command = [NSString stringWithFormat:@"*requestchannellevel %@,%@\r\n", self.model.channel, self.model.area];
                [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
            });
        } else {
            skip = NO;
        }
        sleep(4);
    }
    [NSThread exit];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [sock writeData:[sock.command dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    
    NSArray *arrayTemp = [msg arrayOfCaptureComponentsMatchedByRegex:@"T\\[(.+?)\\]"];
    if (arrayTemp) {
        int brightness = [[[arrayTemp objectAtIndex:0] objectAtIndex:1] integerValue]/10;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self setBrightnessDegree:brightness];
        });
    }
    [sock disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        [self.controller setNetworkState:NO];
    } else {
        [self.controller setNetworkState:YES];
    }
    sock = nil;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    [sock disconnect];
    return 0.0;
}

- (void)removeFromSuperview
{
    [self.myModeThread cancel];
    [super removeFromSuperview];
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
