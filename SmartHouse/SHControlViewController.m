//
//  SHControlViewController.m
//  SmartHouse
//
//  Created by Roc on 13-8-13.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "SHControlViewController.h"
#import "SHSettingsViewController.h"
#import "SHModeModel.h"
#import "SHLightControlView.h"
#import "SHCurtainControlView.h"
#import "SHSettingsViewController.h"
#import "SHAirControlView.h"
#import "RegexKitLite.h"

#define GUIDE_PANEL_BASE_TAG 2000
#define MODE_BTN_BASE_TAG 1000
#define TYPE_LIGHT 1
#define TYPE_CURTAIN 2
#define TYPE_AIR 3
#define TYPE_MODE 0

@interface SHControlViewController ()

@end

@implementation SHControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.myAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.socketQueue = dispatch_queue_create("socketQueue1", NULL);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailView = [[UIScrollView alloc] init];
    self.detailBackground = [[UIImageView alloc] init];
    
    self.NetStateButton = [[UIButton alloc] init];
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"network"];
    [self.NetStateButton setImage:[UIImage imageNamed:@"btn_switch_2"] forState:UIControlStateNormal];
    self.insideNetAddr = YES;
    self.myAppDelegate.host = self.myAppDelegate.host1;
    if (string) {
        if ([string isEqualToString:self.myAppDelegate.host2]) {
            [self.NetStateButton setImage:[UIImage imageNamed:@"btn_switch_1"] forState:UIControlStateNormal];
            self.insideNetAddr = NO;
            self.myAppDelegate.host = self.myAppDelegate.host2;
        }
    }
    [self.NetStateButton addTarget:self action:@selector(onNetStateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.ModeButton = [[UIButton alloc] init];
    [self.ModeButton setBackgroundImage:[UIImage imageNamed:@"btn_mode"] forState:UIControlStateNormal];
    [self.ModeButton setBackgroundImage:[UIImage imageNamed:@"btn_mode"] forState:UIControlStateSelected];
    [self.ModeButton addTarget:self action:@selector(onModeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.LightButton = [[UIButton alloc] init];
    [self.LightButton setBackgroundImage:[UIImage imageNamed:@"btn_light"] forState:UIControlStateNormal];
    [self.LightButton setBackgroundImage:[UIImage imageNamed:@"btn_light"] forState:UIControlStateSelected];
    [self.LightButton addTarget:self action:@selector(onLightClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.CurtainButton = [[UIButton alloc] init];
    [self.CurtainButton setBackgroundImage:[UIImage imageNamed:@"btn_curtain"] forState:UIControlStateNormal];
    [self.CurtainButton setBackgroundImage:[UIImage imageNamed:@"btn_curtain"] forState:UIControlStateSelected];
    [self.CurtainButton addTarget:self action:@selector(onCuitainClick:) forControlEvents:UIControlEventTouchUpInside];

    self.AirButton = [[UIButton alloc] init];
    [self.AirButton setBackgroundImage:[UIImage imageNamed:@"btn_air"] forState:UIControlStateNormal];
    [self.AirButton setBackgroundImage:[UIImage imageNamed:@"btn_air"] forState:UIControlStateSelected];
    [self.AirButton addTarget:self action:@selector(onAirClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftButton = [[UIButton alloc] init];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(onLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton = [[UIButton alloc] init];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(onRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentModel = [self.myAppDelegate.models objectAtIndex:0];
    self.tableView = [[UITableView alloc] init];
    [self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_background"]]];
    [self.tableView setBounces:NO];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    self.GuidePanel = [[UIView alloc] init];
    [self.GuidePanel setBackgroundColor:[UIColor clearColor]];
    [self setupNavigationBar:0.0];
    [self setViewFramesForOrientation:self.interfaceOrientation AtIndex:0];
    [self.view setBackgroundColor:[UIColor colorWithRed:246.0/255.0f green:246.0/255.0f blue:246.0/255.0f alpha:1.0]];
    
    [self.view addSubview:self.ModeButton];
    [self.view addSubview:self.LightButton];
    [self.view addSubview:self.CurtainButton];
    [self.view addSubview:self.AirButton];
    [self.view addSubview:self.NetStateButton];
    
    [self.ModeButton setHidden:YES];
    [self.LightButton setHidden:YES];
    [self.CurtainButton setHidden:YES];
    [self.AirButton setHidden:YES];
    
    [self setupDetailView:self.currentModel Type:TYPE_MODE AtIndex:0];
    
    [self.view addSubview:self.detailBackground];
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.GuidePanel];
    [self.view addSubview:self.leftButton];
    [self.view addSubview:self.rightButton];
    
    [self.leftButton setHidden:YES];
    [self.rightButton setHidden:YES];
    
}

- (int)checkCurrentTypeState:(SHRoomModel *)model
{
    int type = TYPE_MODE;
    NSMutableArray *currentTypeState = [[NSMutableArray alloc] init];
    if ((!self.currentModel.modes)||(self.currentModel.modes.count == 0)) {
        [currentTypeState addObject:@"0"];
        [self.ModeButton setHidden:YES];
        type = TYPE_LIGHT;
    } else {
        [currentTypeState addObject:@"1"];
        [self.ModeButton setHidden:NO];
    }
    if ((!self.currentModel.lights)||(self.currentModel.lights.count == 0)) {
        [currentTypeState addObject:@"0"];
        [self.LightButton setHidden:YES];
        if (type == TYPE_LIGHT) {
            type = TYPE_CURTAIN;
        }
    } else {
        [currentTypeState addObject:@"1"];
        [self.LightButton setHidden:NO];
    }
    if ((!self.currentModel.curtains)||(self.currentModel.curtains.count == 0)) {
        [currentTypeState addObject:@"0"];
        [self.CurtainButton setHidden:YES];
        if (type == TYPE_CURTAIN) {
            type = TYPE_AIR;
        }
    } else {
        [currentTypeState addObject:@"1"];
        [self.CurtainButton setHidden:NO];
    }
    if ((!self.currentModel.airconditionings)||(self.currentModel.airconditionings.count == 0)) {
        [currentTypeState addObject:@"0"];
        [self.AirButton setHidden:YES];
        if (type == TYPE_AIR) {
            type = -1;
        }
    } else {
        [currentTypeState addObject:@"1"];
        [self.AirButton setHidden:NO];
    }
    
    if (!self.ModeButton.isHidden) {
        [self.ModeButton setTag:0];
        [self.ModeButton setFrame:CGRectMake(192.0f, 90.0f, 66.0f, 70.0f)];
    }
    if (!self.LightButton.isHidden) {
        [self.LightButton setTag:[[currentTypeState objectAtIndex:0] integerValue]];
        [self.LightButton setFrame:CGRectMake(192.0f + 100.0 * self.LightButton.tag, 90.0f, 66.0f, 70.0f)];
    }
    if (!self.CurtainButton.isHidden) {
        [self.CurtainButton setTag:[[currentTypeState objectAtIndex:0] integerValue] + [[currentTypeState objectAtIndex:1] integerValue]];
        [self.CurtainButton setFrame:CGRectMake(192.0f + 100.0 * self.CurtainButton.tag, 90.0f, 66.0f, 70.0f)];
    }
    if (!self.AirButton.isHidden) {
        [self.AirButton setTag:[[currentTypeState objectAtIndex:0] integerValue] + [[currentTypeState objectAtIndex:1] integerValue] + [[currentTypeState objectAtIndex:2] integerValue]];
        [self.AirButton setFrame:CGRectMake(192.0f + 100.0 * self.AirButton.tag, 90.0f, 66.0f, 70.0f)];
    }
    
    return type;
}

//设置导航栏
- (void)setupNavigationBar:(float)width
{
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar_all"] forBarMetrics:UIBarMetricsDefault];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"智能家居系统"];
    [titleLabel setFont:[UIFont systemFontOfSize:24.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel sizeToFit];
    
    UIButton *leftButton = [[UIButton alloc] init];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [leftButton addTarget:self action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    
    UIButton *rightButton = [[UIButton alloc] init];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_setting"] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [rightButton addTarget:self action:@selector(onSettingsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [rightButton sizeToFit];
    
    self.networkStateButton = [[UIButton alloc] init];
    [self.networkStateButton setBackgroundImage:[UIImage imageNamed:@"state_1"] forState:UIControlStateNormal];
    [self.networkStateButton sizeToFit];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.networkBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.networkStateButton];
    
    NSArray *rightButtons = @[rightBarButton, self.networkBarButton];
    
    self.item = [[UINavigationItem alloc] init];
    [self.item setTitleView:titleLabel];
    [self.item setLeftBarButtonItem:leftBarButton];
    [self.item setRightBarButtonItems:rightButtons];
    
    [self.navigationBar pushNavigationItem:self.item animated:NO];
    [self.view addSubview:self.navigationBar];
}

- (void)onBackButtonClick
{
    [self.backController willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:1.0];
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

- (void)onSettingsButtonClick
{
    SHSettingsViewController *controller = [[SHSettingsViewController alloc] initWithNibName:nil bundle:nil];
    controller.controller = self;
    [self presentViewController:controller animated:YES completion:^(void){
        
    }];
}

- (void)setDetailViewScroll:(NSMutableArray *)detailViews;
{
    self.detailPageCount = detailViews.count;
    self.currentDetailPage = 0;
    [self.detailView setContentSize:CGSizeMake(844*detailViews.count, 553)];
    if (detailViews.count > 1) {
        [self.GuidePanel setFrame:CGRectMake(160+(844-(detailViews.count*2-1)*15)/2.0, 675, (detailViews.count*2-1)*15, 44)];
        for (int i = 0; i < detailViews.count; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(i*30, 14.5, 15, 15)];
            if (i == 0) {
                [image setImage:[UIImage imageNamed:@"selected"]];
            } else {
                [image setImage:[UIImage imageNamed:@"unselected"]];
            }
            [image setTag:GUIDE_PANEL_BASE_TAG + i];
            [self.GuidePanel addSubview:image];
        }
        [self.GuidePanel setHidden:NO];
        [self.leftButton setHidden:NO];
        [self.rightButton setHidden:NO];
    }
}

- (void)setupDetailView:(SHRoomModel *)currentModel Type:(int)type AtIndex:(int)index
{
    self.detailViews = [[NSMutableArray alloc] init];
    self.currentType = type;
    for (UIView *view in self.detailView.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in self.GuidePanel.subviews) {
        [view removeFromSuperview];
    }
    
    [self.detailView setBounces:NO];
    [self.detailView setDelegate:self];
    [self.detailView setShowsHorizontalScrollIndicator:NO];
    [self.detailView setShowsVerticalScrollIndicator:NO];
    [self.detailView setContentOffset:CGPointMake(0, 0)];
    [self.detailView setBackgroundColor:[UIColor clearColor]];
    
    switch (type) {
        case TYPE_MODE:
            if (index != 0) {
                if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                    [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_l_0"]];
                } else {
                    [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_p_0"]];
                }
            }
            break;
        case TYPE_LIGHT:
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_l_%d", self.LightButton.tag]]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_p_%d", self.LightButton.tag]]];
            }
            break;
        case TYPE_CURTAIN:
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_l_%d", self.CurtainButton.tag]]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_p_%d", self.CurtainButton.tag]]];
            }
            break;
        case TYPE_AIR:
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_l_%d", self.AirButton.tag]]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_detail_p_%d", self.AirButton.tag]]];
            }
            break;
    }
    [self.GuidePanel setHidden:YES];
    [self.leftButton setHidden:YES];
    [self.rightButton setHidden:YES];

    if (type == TYPE_LIGHT) {
        [self setDetailViewScroll:self.currentModel.lights];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < self.currentModel.lights.count; i++) {
                SHLightControlView *lightView = [[SHLightControlView alloc] initWithFrame:CGRectMake(844 * i + 122.0, 25.0, 600.0, 500.0) andModel:[self.currentModel.lights objectAtIndex:i] andController:self];
                [self.detailViews addObject:lightView];
                if (i == 0) {
                    lightView.query = YES;
                }
                [self.detailView addSubview:lightView];
            }
        }
    } else if (type == TYPE_CURTAIN) {
        [self setDetailViewScroll:self.currentModel.curtains];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < self.currentModel.curtains.count; i++) {
                SHCurtainControlView *curtainView = [[SHCurtainControlView alloc] initWithFrame:CGRectMake(844 * i + 122.0, 25.0, 600.0, 500.0) andModel:[self.currentModel.curtains objectAtIndex:i] andController:self];
                [self.detailViews addObject:curtainView];
                [self.detailView addSubview:curtainView];
            }
        }
    } else if (type == TYPE_AIR) {
        [self setDetailViewScroll:self.currentModel.airconditionings];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < self.currentModel.airconditionings.count; i++) {
                SHAirControlView *detailViewPanel = [[SHAirControlView alloc] initWithFrame:CGRectMake(844 * i + 230.5, 25.0, 383, 500) andModel:[self.currentModel.airconditionings objectAtIndex:i] andController:self];
                [self.detailViews addObject:detailViewPanel];
                if (i == 0) {
                    detailViewPanel.query = YES;
                }
                [self.detailView addSubview:detailViewPanel];
            }
        }
    } else if (type == TYPE_MODE) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            [self.detailView setContentSize:CGSizeMake(844.0, 553.0)];
            for (int i = 0; i <= self.currentModel.modes.count; i++) {
                UIButton *button = [[UIButton alloc] init];
                [button setFrame:CGRectMake(76.0 + 246.0 * (i % 3), 75.0 + 124.0 * (i / 3), 200.0, 74.0)];
                //[button setTitle:[self.currentModel.modesNames objectAtIndex:i] forState:UIControlStateNormal];
                //[button setTitle:[self.currentModel.modesNames objectAtIndex:i] forState:UIControlStateSelected];
                //[button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
                if (i == self.currentModel.modes.count) {
                    [button setBackgroundImage:[UIImage imageNamed:@"mode_normal_userdefine"] forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:@"mode_selected_userdefine"] forState:UIControlStateHighlighted];
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onModeButtonLongPressed:)];
                    longPress.minimumPressDuration = 1.5; //定义按的时间
                    [button addGestureRecognizer:longPress];
                } else {
                    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"mode_normal%d", i]] forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"mode_selected%d", i]] forState:UIControlStateHighlighted];
                }
                [button setTag:MODE_BTN_BASE_TAG + i];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
                [button setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(onModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.detailView addSubview:button];
            }
        } else {
            
        }
    }

}

- (void)onModeButtonClick:(UIButton *)sender
{
    if (sender.tag < self.currentModel.modes.count + MODE_BTN_BASE_TAG) {
        SHModeModel *modeModel = [self.currentModel.modes objectAtIndex:sender.tag - MODE_BTN_BASE_TAG];
        NSArray *cmdarray = [modeModel.modecmd componentsSeparatedByString:@"|"];
        for (int i = 0; i < cmdarray.count; i++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
                NSError *error;
                GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myAppDelegate delegateQueue:self.myAppDelegate.socketQueue];
                socket.command = [NSString stringWithFormat:@"%@\r\n", [cmdarray objectAtIndex:i]];
                [socket connectToHost:self.myAppDelegate.host onPort:self.myAppDelegate.port withTimeout:3.0 error:&error];
            });
        }
    } else {
        NSMutableArray *modeDefine = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"mode_user_define%@", self.currentModel.roomid]];
        if (modeDefine) {
            if (self.myModeSetThread) {
                self.myModeSetThread = nil;
            }
            self.myModeSetThread = [[NSThread alloc] initWithTarget:self selector:@selector(setMode:) object:nil];
            if (![self.myModeSetThread isExecuting]) {
                [self.myModeSetThread start];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定模式提醒" message:@"您尚未录入自定模式，是否保存家电当前状态为自定模式？(长按此按钮将再次录入自定义模式)" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self saveUserDefineMode];
    }
}

- (void)saveUserDefineMode
{
    self.defineModeCmd = [[NSMutableArray alloc] init];
    self.queryCmds = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.currentModel.lights.count; i++) {
        SHLightModel *lightmodel = [self.currentModel.lights objectAtIndex:i];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:lightmodel forKey:@"data"];
        [dictionary setObject:[NSString stringWithFormat:@"%d", TYPE_LIGHT] forKey:@"type"];
        [dictionary setObject:[NSString stringWithFormat:@"*requestchannellevel %@,%@\r\n", [lightmodel channel], [lightmodel area]] forKey:@"command"];
        [self.queryCmds addObject:dictionary];
    }
    for (int i = 0; i < self.currentModel.curtains.count; i++) {
        SHCurtainModel *curtainmodel = [self.currentModel.curtains objectAtIndex:i];
        NSString *stateString = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"curtain%@%@", curtainmodel.channel, curtainmodel.area]];
        if (stateString) {
            int state = [stateString integerValue];
            if (state == 0) {
                [self.defineModeCmd addObject:curtainmodel.closecmd];
            } else {
                [self.defineModeCmd addObject:curtainmodel.opencmd];
            }
        } else {
            [self.defineModeCmd addObject:curtainmodel.closecmd];
        }
    }
    for (int i = 0; i < self.currentModel.airconditionings.count; i++) {
        SHAirConditioningModel *airmodel = [self.currentModel.airconditionings objectAtIndex:i];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:airmodel forKey:@"data"];
        [dictionary setObject:[NSString stringWithFormat:@"%d", TYPE_AIR] forKey:@"type"];
        [dictionary setObject:[NSString stringWithFormat:@"*aircreply %@,%@\r\n", [airmodel mainaddr], [airmodel secondaryaddr]] forKey:@"command"];
        [self.queryCmds addObject:dictionary];
    }
    
    if (self.myModeQueryThread) {
        self.myModeQueryThread = nil;
    }
    self.myModeQueryThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
    if (![self.myModeQueryThread isExecuting]) {
        [self.myModeQueryThread start];
    }
}

- (void)queryMode:(NSThread *)thread
{
    int i = 0;
    while ([[NSThread currentThread] isCancelled] == NO) {
        NSMutableDictionary *dictionary = [self.queryCmds objectAtIndex:i];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
            NSError *error;
            GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
            socket.command = [dictionary objectForKey:@"command"];
            socket.type = [[dictionary objectForKey:@"type"] integerValue];
            socket.data = [dictionary objectForKey:@"data"];
            [socket connectToHost:self.myAppDelegate.host onPort:self.myAppDelegate.port withTimeout:3.0 error:&error];
        });
        [NSThread sleepForTimeInterval:0.5];
        i = i + 1;
        if (i == self.queryCmds.count) {
            [self.myModeQueryThread cancel];
        }
    }
    [NSThread exit];
}

- (void)setMode:(NSThread *)thread
{
    int i = 0;
    NSMutableArray *modeDefine = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"mode_user_define%@", self.currentModel.roomid]];
    while ([[NSThread currentThread] isCancelled] == NO) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
            NSError *error;
            GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self.myAppDelegate delegateQueue:self.myAppDelegate.socketQueue];
            socket.command = [NSString stringWithFormat:@"%@\r\n", [modeDefine objectAtIndex:i]];
            [socket connectToHost:self.myAppDelegate.host onPort:self.myAppDelegate.port withTimeout:3.0 error:&error];
        });
        [NSThread sleepForTimeInterval:0.5];
        i = i + 1;
        if (i == modeDefine.count) {
            [self.myModeSetThread cancel];
        }
    }
    [NSThread exit];
}

- (void)onModeButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"自定模式提醒" message:@"是否保存家电当前状态为自定模式？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)onLightClick:(id)sender
{
    [self setupDetailView:self.currentModel Type:TYPE_LIGHT AtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)onCuitainClick:(id)sender
{
    [self setupDetailView:self.currentModel Type:TYPE_CURTAIN AtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)onModeClick:(id)sender
{
    [self setupDetailView:self.currentModel Type:TYPE_MODE AtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)onAirClick:(id)sender
{
    [self setupDetailView:self.currentModel Type:TYPE_AIR AtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)onNetStateButtonClick:(id)sender
{
    self.insideNetAddr = !self.insideNetAddr;
    UIImage *netimage = self.insideNetAddr?[UIImage imageNamed:@"btn_switch_2"] : [UIImage imageNamed:@"btn_switch_1"];
    [self.NetStateButton setImage:netimage forState:UIControlStateNormal];
    self.myAppDelegate.host = self.insideNetAddr? self.myAppDelegate.host1 : self.myAppDelegate.host2;
    [[NSUserDefaults standardUserDefaults] setObject:self.myAppDelegate.host forKey:@"network"];
}

- (void)setCurrentViewQuery:(int)currentViewPage NewPage:(int)newViewPage
{
    [[self.detailViews objectAtIndex:currentViewPage] setQuery:NO];
    [[self.detailViews objectAtIndex:newViewPage] setQuery:YES];
}

- (void)onLeftButtonClick:(UIButton *)sender
{
    self.currentDetailPage = self.detailView.contentOffset.x/844.0;
    if (self.currentDetailPage > 0) {
        [self setCurrentViewQuery:self.currentDetailPage NewPage:self.currentDetailPage - 1];
        CGPoint point = CGPointMake((self.currentDetailPage - 1) * 844.0, self.detailView.contentOffset.y);
        [self.detailView setContentOffset:point animated:YES];
        
        for (int i = 0; i < self.detailPageCount; i++) {
            UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + i];
            [image setImage:[UIImage imageNamed:@"unselected"]];
        }
        UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + self.currentDetailPage - 1];
        [image setImage:[UIImage imageNamed:@"selected"]];
    }
}

- (void)onRightButtonClick:(UIButton *)sender
{
    if ((int)self.detailView.contentOffset.x % 844 != 0) {
        self.currentDetailPage = self.detailView.contentOffset.x/844.0 + 1;
    } else {
        self.currentDetailPage = self.detailView.contentOffset.x/844.0;
    }
    if (self.currentDetailPage < self.detailPageCount - 1) {
        [self setCurrentViewQuery:self.currentDetailPage NewPage:self.currentDetailPage + 1];
        CGPoint point = CGPointMake((self.currentDetailPage + 1) * 844.0, self.detailView.contentOffset.y);
        [self.detailView setContentOffset:point animated:YES];
        
        for (int i = 0; i < self.detailPageCount; i++) {
            UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + i];
            [image setImage:[UIImage imageNamed:@"unselected"]];
        }
        UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + self.currentDetailPage + 1];
        [image setImage:[UIImage imageNamed:@"selected"]];
    }
}

-(void)updateViews:(SHRoomModel *)currentModel atIndex:(int)index
{
    int type = TYPE_MODE;
    if (index == 0) {
        [self.LightButton setHidden:YES];
        [self.ModeButton setHidden:YES];
        [self.CurtainButton setHidden:YES];
        [self.AirButton setHidden:YES];
        if (firstImageView) {
            [firstImageView setImage:[UIImage imageNamed:@"icon_house_selected"]];
        }
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.detailView setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_l_index0"]];
        } else {
            
        }
    } else {
        type = [self checkCurrentTypeState:currentModel];
        if (firstImageView) {
            [firstImageView setImage:[UIImage imageNamed:@"icon_house_normal"]];
        }
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.detailView setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
        } else {
            
        }
    }
    [self setupDetailView:self.currentModel Type:type AtIndex:index];
}


#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentModel = [self.myAppDelegate.models objectAtIndex:indexPath.row];
    [self updateViews:self.currentModel atIndex:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.;
}


#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ViolationTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *roomName = [[self.myAppDelegate.models objectAtIndex:indexPath.row] name];
    [cell.textLabel setText:roomName];
    cell.selectedBackgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"left_selected"]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_normal"]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.827 green:0.827 blue:0.827 alpha:1.0]];
    [cell.textLabel setHighlightedTextColor:[UIColor yellowColor]];
    if (indexPath.row == 0) {
        firstImageView = cell.imageView;
        [cell.imageView setImage:[UIImage imageNamed:@"icon_house_selected"]];
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myAppDelegate.models.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollLastViewPage = scrollView.contentOffset.x/844.0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x/844.0;
    if (currentPage != self.scrollLastViewPage) {
        [[self.detailViews objectAtIndex:self.scrollLastViewPage] setQuery:NO];
        [[self.detailViews objectAtIndex:currentPage] setQuery:YES];
    }
    for (int i = 0; i < self.detailPageCount; i++) {
        UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + i];
        [image setImage:[UIImage imageNamed:@"unselected"]];
    }
    UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + currentPage];
    [image setImage:[UIImage imageNamed:@"selected"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)setViewFramesForOrientation:(UIInterfaceOrientation)orientation AtIndex:(int)index{
    [self checkCurrentTypeState:self.currentModel];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.navigationBar setFrame:CGRectMake(0, 0, 1024, 44)];
        [self.tableView setFrame:CGRectMake(0.0, 44.0, 140, 704)];
        [self.NetStateButton setFrame:CGRectMake(850.0, 64.0, 144.0, 36.0)];
        [self.detailView setPagingEnabled:YES];
        [self.leftButton setFrame:CGRectMake(185.0, 431.0, 22.0, 41.0)];
        [self.rightButton setFrame:CGRectMake(957.0, 431.0, 22.0, 41.0)];
        if (index == 0) {
            [self.detailView setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_l_index0"]];
            [self.ModeButton setHidden:YES];
            [self.LightButton setHidden:YES];
            [self.CurtainButton setHidden:YES];
            [self.AirButton setHidden:YES];
        } else {
            [self.detailView setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
        }
    } else {
        [self.navigationBar setFrame:CGRectMake(0, 0, 768, 44)];
        [self.tableView setFrame:CGRectMake(0.0, 44.0, 140, 960)];
        [self.NetStateButton setFrame:CGRectMake(594.0, 64.0, 144.0, 36.0)];
        [self.ModeButton setFrame:CGRectMake(190.0f, 95.0f, 72.0f, 76.0f)];
        [self.LightButton setFrame:CGRectMake(288.0f, 95.0f, 72.0f, 76.0f)];
        [self.CurtainButton setFrame:CGRectMake(386.0f, 95.0f, 72.0f, 76.0f)];
        [self.AirButton setFrame:CGRectMake(484.0f, 95.0f, 72.0f, 76.0f)];
        [self.detailView setPagingEnabled:NO];
        if (index == 0) {
            [self.detailView setFrame:CGRectMake(160.0f, 226.0f, 588.0f, 580.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 186.0f, 588.0f, 640.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_p_index0"]];
            [self.ModeButton setHidden:YES];
            [self.LightButton setHidden:YES];
            [self.CurtainButton setHidden:YES];
            [self.AirButton setHidden:YES];
        } else {
            [self.detailView setFrame:CGRectMake(160.0f, 226.0f, 588.0f, 580.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 186.0f, 588.0f, 640.0f)];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setViewFramesForOrientation:toInterfaceOrientation AtIndex:self.tableView.indexPathForSelectedRow.row];
    [self setupDetailView:self.currentModel Type:self.currentType AtIndex:self.tableView.indexPathForSelectedRow.row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setNetworkState:(BOOL)state
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (state) {
            [self.networkStateButton setBackgroundImage:[UIImage imageNamed:@"state_1"] forState:UIControlStateNormal];
        } else {
            [self.networkStateButton setBackgroundImage:[UIImage imageNamed:@"state_2"] forState:UIControlStateNormal];
        }
    });
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
    
    if (sock.type == TYPE_LIGHT) {
        NSArray *arrayTemp = [msg arrayOfCaptureComponentsMatchedByRegex:@"T\\[(.+?)\\]"];
        if ((arrayTemp)&&(arrayTemp.count > 0)) {
            int brightness = [[[arrayTemp objectAtIndex:0] objectAtIndex:1] integerValue];
            SHLightModel *lightmodel = (SHLightModel *)sock.data;
            [self.defineModeCmd addObject:[NSString stringWithFormat:@"*channellevel %@,%d,%@,%@", lightmodel.channel, brightness, lightmodel.area, lightmodel.fade]];
        }
    } else if (sock.type == TYPE_AIR) {
        NSArray *arrayState = [msg arrayOfCaptureComponentsMatchedByRegex:@"State\\[(.+?)\\]"];
        NSArray *arrayMode = [msg arrayOfCaptureComponentsMatchedByRegex:@"Mode\\[(.+?)\\]"];
        NSArray *arraySpeed = [msg arrayOfCaptureComponentsMatchedByRegex:@"Size\\[(.+?)\\]"];
        NSArray *arrayTemp = [msg arrayOfCaptureComponentsMatchedByRegex:@"Temp\\[(.+?)\\]"];
        int isOnNow = 0;
        int speed = 0;
        int mode = 0;
        int temp = 20;
        if ((arrayState)&&(arrayState.count > 0)) {
            isOnNow = [[[arrayState objectAtIndex:0] objectAtIndex:1] integerValue];
        }
        if ((arraySpeed)&&(arraySpeed.count > 0)) {
            speed = [[[arraySpeed objectAtIndex:0] objectAtIndex:1] integerValue];
        }
        if ((arrayMode)&&(arrayMode.count > 0)) {
            mode = [[[arrayMode objectAtIndex:0] objectAtIndex:1] integerValue];
        }
        if ((arrayTemp)&&(arrayTemp.count > 0)) {
            temp = [[[arrayTemp objectAtIndex:0] objectAtIndex:1] integerValue];
        }
        SHAirConditioningModel *airmodel = (SHAirConditioningModel *)sock.data;
        [self.defineModeCmd addObject:[NSString stringWithFormat:@"*aircset %@,%@,%d,%d,%d,%d,%d", airmodel.mainaddr, airmodel.secondaryaddr, isOnNow, 0, speed, mode, temp]];
    }
    NSLog(@"%@", self.defineModeCmd);
    [[NSUserDefaults standardUserDefaults] setObject:self.defineModeCmd forKey:[NSString stringWithFormat:@"mode_user_define%@", self.currentModel.roomid]];
    [sock disconnect];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        [self setNetworkState:NO];
    } else {
        [self setNetworkState:YES];
    }
    sock = nil;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    [sock disconnect];
    return 0.0;
}


@end
