//
//  SHMusicControlView.m
//  SmartHouse
//
//  Created by Roc on 13-8-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "SHAirControlView.h"
#import "RegexKitLite.h"

#define MODE_BUTTON_BASE_TAG 5000
#define SPEED_BUTTON_BASE_TAG 6000
#define WIND_DIRECT 0

@implementation SHAirControlView

@synthesize myModeThread;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)titleString andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        self.controller = controller;
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setText:titleString];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor greenColor]];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake((frame.size.width - titleLabel.frame.size.width)/2, 12.0, titleLabel.frame.size.width, titleLabel.frame.size.height)];
        [self addSubview:titleLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        //[background setImage:[UIImage imageNamed:@"bg_air"]];
        //[self addSubview:background];
        self.socketQueue = dispatch_queue_create("socketQueue3", NULL);
        self.isOnNow = 0;
        NSString *savedtemp = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@%@temp", [self.airAddrs objectAtIndex:0], [self.airAddrs objectAtIndex:1]]];
        if (savedtemp) {
            self.currentTemp = [savedtemp integerValue];
        } else {
            self.currentTemp = 20;
        }
        skip = NO;
    }
    return self;
}

- (void)setAddrs:(NSMutableArray *)addrs andCmds:(NSMutableArray *)cmds andModes:(NSMutableArray *)modes
{
    self.airAddrs = addrs;
    self.airCmds = cmds;
    self.airModes = modes;
    
    self.open_close = [[UIButton alloc] initWithFrame:CGRectMake(30.0, 64.0, 93.0, 33.0)];
    [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateNormal];
    [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateSelected];
    [self.open_close addTarget:self action:@selector(onCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.open_close];
    
    modePanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 115.0, 325.0, 74.0)];
    [modePanel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"air_panel_bg"]]];
    modeImage = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 9.5, 30.0, 55.0)];
    [modeImage setImage:[UIImage imageNamed:@"panel_title_mode"]];
    [modePanel addSubview:modeImage];
    for (int i = 0; i < modes.count; i++) {
        int location = [@"01234" rangeOfString:[modes objectAtIndex:i]].location;
        UIButton *modebutton = [[UIButton alloc] initWithFrame:CGRectMake(45.5 + 54.0 * i, 9.0, 46.0, 56.0)];
        NSString *imageNameNormal = [NSString stringWithFormat:@"btn_mode_%d_normal", location];
        NSString *imageNameSelected = [NSString stringWithFormat:@"btn_mode_%d_selected", location];
        [modebutton setTag:MODE_BUTTON_BASE_TAG + location];
        [modebutton setBackgroundImage:[UIImage imageNamed:imageNameNormal] forState:UIControlStateNormal];
        [modebutton setBackgroundImage:[UIImage imageNamed:imageNameSelected] forState:UIControlStateSelected];
        [modebutton addTarget:self action:@selector(onModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [modePanel addSubview:modebutton];
    }
    [self addSubview:modePanel];
    
    speedPanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 210.0, 325.0, 74.0)];
    [speedPanel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"air_panel_bg"]]];
    speedImage = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 9, 31.0, 56.0)];
    [speedImage setImage:[UIImage imageNamed:@"panel_title_speed"]];
    [speedPanel addSubview:speedImage];
    for (int i = 0; i < 3; i++) {
        UIButton *speedbutton = [[UIButton alloc] initWithFrame:CGRectMake(65.0 + 86.0 * i, 9.0, 56.0, 56.0)];
        NSString *imageNameNormal = [NSString stringWithFormat:@"btn_speed_%d_normal", i];
        NSString *imageNameSelected = [NSString stringWithFormat:@"btn_speed_%d_selected", i];
        [speedbutton setTag:SPEED_BUTTON_BASE_TAG + i];
        [speedbutton setBackgroundImage:[UIImage imageNamed:imageNameNormal] forState:UIControlStateNormal];
        [speedbutton setBackgroundImage:[UIImage imageNamed:imageNameSelected] forState:UIControlStateSelected];
        [speedbutton addTarget:self action:@selector(onSpeedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [speedPanel addSubview:speedbutton];
    }
    [self addSubview:speedPanel];
    
    tempPanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 305.0, 325.0, 74.0)];
    [tempPanel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"air_panel_temp_bg"]]];
    self.tempLower = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 2.0, 75.0, 70.0)];
    [self.tempLower setBackgroundImage:[UIImage imageNamed:@"btn_lower_normal"] forState:UIControlStateNormal];
    [self.tempLower setBackgroundImage:[UIImage imageNamed:@"btn_lower_pressed"] forState:UIControlStateNormal];
    [self.tempLower addTarget:self action:@selector(onLowerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tempPanel addSubview:self.tempLower];
    self.tempHigher = [[UIButton alloc] initWithFrame:CGRectMake(250.0, 2.0, 75.0, 70.0)];
    [self.tempHigher setBackgroundImage:[UIImage imageNamed:@"btn_higher_normal"] forState:UIControlStateNormal];
    [self.tempHigher setBackgroundImage:[UIImage imageNamed:@"btn_higher_pressed"] forState:UIControlStateNormal];
    [self.tempHigher addTarget:self action:@selector(onHigherButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tempPanel addSubview:self.tempHigher];
    label_indoor = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 10.0, 35.0, 15.0)];
    [label_indoor setText:@"室温"];
    [label_indoor setBackgroundColor:[UIColor clearColor]];
    [label_indoor setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label_indoor setTextAlignment:NSTextAlignmentRight];
    [label_indoor setTextColor:[UIColor colorWithRed:0.808 green:0.804 blue:0.792 alpha:1.0]];
    [tempPanel addSubview:label_indoor];
    temp_mini = [[UILabel alloc] initWithFrame:CGRectMake(78.0, 25.0, 35.0, 15.0)];
    [temp_mini setText:@"--℃"];
    [temp_mini setBackgroundColor:[UIColor clearColor]];
    [temp_mini setFont:[UIFont systemFontOfSize:15.0]];
    [temp_mini setTextColor:[UIColor colorWithRed:0.808 green:0.804 blue:0.792 alpha:1.0]];
    [temp_mini setTextAlignment:NSTextAlignmentRight];
    [tempPanel addSubview:temp_mini];
    [tempPanel addSubview:self.tempHigher];
    temp_big = [[UILabel alloc] initWithFrame:CGRectMake(122.0, 15.0, 56.0, 44.0)];
    [temp_big setBackgroundColor:[UIColor clearColor]];
    [temp_big setTextColor:[UIColor whiteColor]];
    [temp_big setFont:[UIFont systemFontOfSize:38.0]];
    [temp_big setText:@"--"];
    [temp_big setTextAlignment:NSTextAlignmentRight];
    [tempPanel addSubview:temp_big];
    tempsysbol = [[UILabel alloc] initWithFrame:CGRectMake(178.0, 28.0, 28.0, 28.0)];
    [tempsysbol setBackgroundColor:[UIColor clearColor]];
    [tempsysbol setText:@"℃"];
    [tempsysbol setTextColor:[UIColor colorWithRed:0.808 green:0.804 blue:0.792 alpha:1.0]];
    [tempsysbol setFont:[UIFont systemFontOfSize:24.0]];
    [tempPanel addSubview:tempsysbol];
    [self addSubview:tempPanel];
    
    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(256.0, 405.0, 97.0, 38.0)];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"btn_air_set_normal"] forState:UIControlStateNormal];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"btn_air_set_pressed"] forState:UIControlStateHighlighted];
    [self.settingButton addTarget:self action:@selector(onSettingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingButton];
    
    if (![self.myModeThread isExecuting]) {
        [self.myModeThread start];
    }
}

- (void)onCloseButtonClick:(UIButton *)button
{
    skip = YES;
    if (self.isOnNow == 1) {
        [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateNormal];
        [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateSelected];
        self.isOnNow = 0;
    } else {
        [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateNormal];
        [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateSelected];
        self.isOnNow = 1;
    }
}

- (void)onModeButtonClick:(UIButton *)button
{
    skip = YES;
    self.currentMode = button.tag - MODE_BUTTON_BASE_TAG;
    [button setSelected:YES];
    for (int i = 0; i < self.airModes.count; i++) {
        if ([[modePanel viewWithTag:[[self.airModes objectAtIndex:i] integerValue] + MODE_BUTTON_BASE_TAG] tag] != button.tag) {
            [(UIButton *)[modePanel viewWithTag:[[self.airModes objectAtIndex:i] integerValue] + MODE_BUTTON_BASE_TAG] setSelected:NO];
        }
    }
}

- (void)onSpeedButtonClick:(UIButton *)button
{
    skip = YES;
    self.currentSpeed = button.tag - SPEED_BUTTON_BASE_TAG;
    [button setSelected:YES];
    for (int i = 0; i < 3; i++) {
        if (button.tag != [[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] tag]) {
            [(UIButton *)[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] setSelected:NO];
        }
    }
}

- (void)onHigherButtonClick:(UIButton *)button
{
    skip = YES;
    self.currentTemp++;
    [temp_big setText:[NSString stringWithFormat:@"%d", self.currentTemp]];
}

- (void)onLowerButtonClick:(UIButton *)button
{
    skip = YES;
    self.currentTemp--;
    [temp_big setText:[NSString stringWithFormat:@"%d", self.currentTemp]];
}

- (void)onSettingButtonClick:(UIButton *)button
{
    skip = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentTemp] forKey:[NSString stringWithFormat:@"air%@%@temp", [self.airAddrs objectAtIndex:0], [self.airAddrs objectAtIndex:1]]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.controller delegateQueue:self.controller.socketQueue];
        NSString *command = [NSString stringWithFormat:@"%@ %@,%@,%d,%d,%d,%d,%d", [self.airCmds objectAtIndex:0], [self.airAddrs objectAtIndex:0], [self.airAddrs objectAtIndex:1], self.isOnNow, WIND_DIRECT, self.currentSpeed, self.currentMode, self.currentTemp];
        socket.command = [NSString stringWithFormat:@"%@\r\n", command];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)queryMode:(NSThread *)thread
{
    while ([[NSThread currentThread] isCancelled] == NO) {
        if (!skip) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
                NSError *error;
                GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
                socket.command = [NSString stringWithFormat:@"%@ %@,%@\r\n", [self.airCmds objectAtIndex:1], [self.airAddrs objectAtIndex:0], [self.airAddrs objectAtIndex:1]];
                [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
            });
        } else {
            skip = NO;
        }
        sleep(6);
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
    NSArray *arrayState = [msg arrayOfCaptureComponentsMatchedByRegex:@"State\\[(.+?)\\]"];
    NSArray *arrayMode = [msg arrayOfCaptureComponentsMatchedByRegex:@"Mode\\[(.+?)\\]"];
    NSArray *arraySpeed = [msg arrayOfCaptureComponentsMatchedByRegex:@"Size\\[(.+?)\\]"];
    NSArray *arrayTemp = [msg arrayOfCaptureComponentsMatchedByRegex:@"Temp\\[(.+?)\\]"];
    if (arrayState) {
        self.isOnNow = [[[arrayState objectAtIndex:0] objectAtIndex:1] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (self.isOnNow == 1) {
                [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateNormal];
                [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateSelected];
            } else {
                [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateNormal];
                [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateSelected];
            }
        });
    }
    if (arraySpeed) {
        self.currentSpeed = [[[arraySpeed objectAtIndex:0] objectAtIndex:1] integerValue];
        int tag = self.currentSpeed + SPEED_BUTTON_BASE_TAG;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [(UIButton *)[speedPanel viewWithTag:tag] setSelected:YES];
            for (int i = 0; i < 3; i++) {
                if (tag != [[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] tag]) {
                    [(UIButton *)[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] setSelected:NO];
                }
            }
        });
    }
    if (arrayMode) {
        self.currentMode = [[[arrayMode objectAtIndex:0] objectAtIndex:1] integerValue];
        int tag = self.currentMode + MODE_BUTTON_BASE_TAG;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [(UIButton *)[modePanel viewWithTag:tag] setSelected:YES];
            for (int i = 0; i < self.airModes.count; i++) {
                if (tag != [[modePanel viewWithTag:[[self.airModes objectAtIndex:i] integerValue] + MODE_BUTTON_BASE_TAG] tag]) {
                    [(UIButton *)[modePanel viewWithTag:[[self.airModes objectAtIndex:i] integerValue] + MODE_BUTTON_BASE_TAG] setSelected:NO];
                }
            }
        });
    }
    if (arrayTemp) {
        self.currentTemp = [[[arrayTemp objectAtIndex:0] objectAtIndex:1] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [temp_big setText:[NSString stringWithFormat:@"%d", self.currentTemp]];
        });
    }
    [sock disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
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
