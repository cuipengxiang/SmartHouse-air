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

- (id)initWithFrame:(CGRect)frame andModel:(SHAirConditioningModel *)model andController:(SHControlViewController *)controller
{
    self = [self initWithFrame:frame];
    if (self) {
        self.myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
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
        self.socketQueue = dispatch_queue_create("socketQueue4", NULL);
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

    }
    return self;
}

- (void)setDetailWithModel
{
    self.open_close = [[UIButton alloc] initWithFrame:CGRectMake(30.0, 84.0, 93.0, 33.0)];
    [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateNormal];
    [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateSelected];
    [self.open_close addTarget:self action:@selector(onCloseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.open_close];
    
    modePanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 135.0, 325.0, 74.0)];
    [modePanel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"air_panel_bg"]]];
    modeImage = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 9.5, 30.0, 55.0)];
    [modeImage setImage:[UIImage imageNamed:@"panel_title_mode"]];
    [modePanel addSubview:modeImage];
    for (int i = 0; i < self.model.modes.count; i++) {
        int mode = [self checkMode:[self.model.modes objectAtIndex:i]];
        UIButton *modebutton = [[UIButton alloc] initWithFrame:CGRectMake(45.5 + 54.0 * i, 9.0, 46.0, 56.0)];
        NSString *imageNameNormal = [NSString stringWithFormat:@"btn_mode_%d_normal", mode];
        NSString *imageNameSelected = [NSString stringWithFormat:@"btn_mode_%d_selected", mode];
        [modebutton setTag:MODE_BUTTON_BASE_TAG + mode];
        [modebutton setBackgroundImage:[UIImage imageNamed:imageNameNormal] forState:UIControlStateNormal];
        [modebutton setBackgroundImage:[UIImage imageNamed:imageNameSelected] forState:UIControlStateSelected];
        [modebutton addTarget:self action:@selector(onModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [modePanel addSubview:modebutton];
    }
    [self addSubview:modePanel];
    
    speedPanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 230.0, 325.0, 74.0)];
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
    
    tempPanel = [[UIView alloc] initWithFrame:CGRectMake(29.0, 325.0, 325.0, 74.0)];
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
    
    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(256.0, 425.0, 97.0, 38.0)];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"btn_air_set_normal"] forState:UIControlStateNormal];
    [self.settingButton setBackgroundImage:[UIImage imageNamed:@"btn_air_set_pressed"] forState:UIControlStateHighlighted];
    [self.settingButton addTarget:self action:@selector(onSettingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.settingButton];
    
    NSString *on = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@%@on", self.model.mainaddr, self.model.secondaryaddr]];
    NSString *temp = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@%@temp", self.model.mainaddr, self.model.secondaryaddr]];
    NSString *speed = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@%@speed", self.model.mainaddr, self.model.secondaryaddr]];
    NSString *mode = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"air%@%@mode", self.model.mainaddr, self.model.secondaryaddr]];
    [self setStateWithOn:on Mode:mode Speed:speed Temp:temp];
    
    if (![self.myModeThread isExecuting]) {
        [self.myModeThread start];
    }
}

- (int)checkMode:(NSString *)mode
{
    if ([mode isEqualToString:@"Wind"]) {
        return 0;
    } else if ([mode isEqualToString:@"Hot"]) {
        return 1;
    } else if ([mode isEqualToString:@"Cool"]) {
        return 2;
    } else if ([mode isEqualToString:@"Auto"]) {
        return 3;
    } else if ([mode isEqualToString:@"Wet"]) {
        return 4;
    } else {
        return -1;
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
    for (int i = 0; i < self.model.modes.count; i++) {
        int tag = [self checkMode:[self.model.modes objectAtIndex:i]] + MODE_BUTTON_BASE_TAG;
        if (tag != button.tag) {
            [(UIButton *)[modePanel viewWithTag:tag] setSelected:NO];
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentTemp] forKey:[NSString stringWithFormat:@"air%@%@temp", self.model.mainaddr, self.model.secondaryaddr]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.isOnNow] forKey:[NSString stringWithFormat:@"air%@%@on", self.model.mainaddr, self.model.secondaryaddr]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentMode] forKey:[NSString stringWithFormat:@"air%@%@mode", self.model.mainaddr, self.model.secondaryaddr]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentSpeed] forKey:[NSString stringWithFormat:@"air%@%@speed", self.model.mainaddr, self.model.secondaryaddr]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.controller delegateQueue:self.controller.socketQueue];
        NSString *command = [NSString stringWithFormat:@"*aircset %@,%@,%d,%d,%d,%d,%d", self.model.mainaddr, self.model.secondaryaddr, self.isOnNow, WIND_DIRECT, self.currentSpeed, self.currentMode, self.currentTemp];
        socket.command = [NSString stringWithFormat:@"%@\r\n", command];
        [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)queryMode:(NSThread *)thread
{
    while ([[NSThread currentThread] isCancelled] == NO) {
        if (self.query) {
            if (!skip) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
                    NSError *error;
                    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
                    socket.command = [NSString stringWithFormat:@"*aircreply %@,%@\r\n", self.model.mainaddr, self.model.secondaryaddr];
                    [socket connectToHost:self.myDelegate.host onPort:self.myDelegate.port withTimeout:3.0 error:&error];
                });
            } else {
                skip = NO;
            }
            sleep(4);
        }
    }
    [NSThread exit];
}


- (void)setStateWithOn:(NSString *)on Mode:(NSString *)mode Speed:(NSString *)speed Temp:(NSString *)temp
{
    int tag = 0;
    if (on) {
        self.isOnNow = [on integerValue];
        if (self.isOnNow == 1) {
            [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateNormal];
            [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_on"] forState:UIControlStateSelected];
        } else {
            [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateNormal];
            [self.open_close setBackgroundImage:[UIImage imageNamed:@"btn_switch_off"] forState:UIControlStateSelected];
        }
    }
    
    if (speed) {
        self.currentSpeed = [speed integerValue];
        tag = self.currentSpeed + SPEED_BUTTON_BASE_TAG;
        [(UIButton *)[speedPanel viewWithTag:tag] setSelected:YES];
        for (int i = 0; i < 3; i++) {
            if (tag != [[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] tag]) {
                [(UIButton *)[speedPanel viewWithTag:i + SPEED_BUTTON_BASE_TAG] setSelected:NO];
            }
        }
    }
    
    if (mode) {
        self.currentMode = [mode integerValue];
        tag = self.currentMode + MODE_BUTTON_BASE_TAG;
        [(UIButton *)[modePanel viewWithTag:tag] setSelected:YES];
        for (int i = 0; i < self.model.modes.count; i++) {
            int buttonTag = [self checkMode:[self.model.modes objectAtIndex:i]];
            if (tag != buttonTag) {
                [(UIButton *)[modePanel viewWithTag:buttonTag] setSelected:NO];
            }
        }
    }
    
    if (temp) {
        self.currentTemp = [temp integerValue];
        [temp_big setText:[NSString stringWithFormat:@"%d", self.currentTemp]];
    }
    
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
    if (sock.skip == -1) {
        sock.skip = 0;
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:1 tag:0];
        return;
    }
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    NSArray *arrayState = [msg arrayOfCaptureComponentsMatchedByRegex:@"State\\[(.+?)\\]"];
    NSArray *arrayMode = [msg arrayOfCaptureComponentsMatchedByRegex:@"Mode\\[(.+?)\\]"];
    NSArray *arraySpeed = [msg arrayOfCaptureComponentsMatchedByRegex:@"Size\\[(.+?)\\]"];
    NSArray *arrayTemp = [msg arrayOfCaptureComponentsMatchedByRegex:@"Temp\\[(.+?)\\]"];
    if ((arrayState)&&(arrayState.count > 0)) {
        self.isOnNow = [[[arrayState objectAtIndex:0] objectAtIndex:1] integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.isOnNow] forKey:[NSString stringWithFormat:@"air%@%@on", self.model.mainaddr, self.model.secondaryaddr]];
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
    if ((arraySpeed)&&(arraySpeed.count > 0)) {
        self.currentSpeed = [[[arraySpeed objectAtIndex:0] objectAtIndex:1] integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentSpeed] forKey:[NSString stringWithFormat:@"air%@%@speed", self.model.mainaddr, self.model.secondaryaddr]];
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
    if ((arrayMode)&&(arrayMode.count > 0)) {
        self.currentMode = [[[arrayMode objectAtIndex:0] objectAtIndex:1] integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentMode] forKey:[NSString stringWithFormat:@"air%@%@mode", self.model.mainaddr, self.model.secondaryaddr]];
        int tag = self.currentMode + MODE_BUTTON_BASE_TAG;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [(UIButton *)[modePanel viewWithTag:tag] setSelected:YES];
            for (int i = 0; i < self.model.modes.count; i++) {
                int buttonTag = [self checkMode:[self.model.modes objectAtIndex:i]];
                if (tag != buttonTag) {
                    [(UIButton *)[modePanel viewWithTag:buttonTag] setSelected:NO];
                }
            }
        });
    }
    if ((arrayTemp)&&(arrayTemp.count > 0)) {
        self.currentTemp = [[[arrayTemp objectAtIndex:0] objectAtIndex:1] integerValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", self.currentTemp] forKey:[NSString stringWithFormat:@"air%@%@temp", self.model.mainaddr, self.model.secondaryaddr]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [temp_big setText:[NSString stringWithFormat:@"%d", self.currentTemp]];
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
