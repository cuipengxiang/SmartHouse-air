//
//  SHControlViewController.m
//  SmartHouse
//
//  Created by Roc on 13-8-13.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import "SHControlViewController.h"
#import "SHSettingsViewController.h"
#import "SHDetailContolView.h"
#import "SHSettingsNewViewController.h"
#import "SHAirControlView.h"

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
        self.myModeThread = [[NSThread alloc] initWithTarget:self selector:@selector(queryMode:) object:nil];
        self.socketQueue = dispatch_queue_create("socketQueue1", NULL);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.needquery = YES;
    
    self.detailView = [[UIScrollView alloc] init];
    self.detailBackground = [[UIImageView alloc] init];
    
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
    
    [self.ModeButton setHidden:YES];
    [self.LightButton setHidden:YES];
    [self.CurtainButton setHidden:YES];
    [self.AirButton setHidden:YES];
    
    [self setupDetailView:self.currentModel Type:TYPE_MODE AtIndex:0];
    
    [self.view addSubview:self.detailBackground];
    [self.view addSubview:self.detailView];
    [self.view addSubview:self.GuidePanel];
    
    /*
    if (![self.myModeThread isExecuting]) {
        [self.myModeThread start];
    }
    */
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
        self.needquery = NO;
    }];
}

- (void)onSettingsButtonClick
{
    SHSettingsNewViewController *controller = [[SHSettingsNewViewController alloc] initWithNibName:nil bundle:nil];
    controller.controller = self;
    [self presentViewController:controller animated:YES completion:^(void){
        self.needquery = NO;
    }];
}

- (void)setupDetailView:(SHRoomModel *)currentModel Type:(int)type AtIndex:(int)index
{
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
    
    NSMutableArray *detailViewNames = nil;
    NSMutableArray *detailViewBtns = nil;
    NSMutableArray *detailViewCmds = nil;
    NSMutableArray *airViewModes = nil;
    NSMutableArray *airViewAddrs = nil;
    switch (type) {
        case TYPE_MODE:
            detailViewNames = [[NSMutableArray alloc] initWithArray:self.currentModel.modesNames];
            detailViewBtns = [[NSMutableArray alloc] initWithArray:self.currentModel.modesNames];
            detailViewCmds = [[NSMutableArray alloc] initWithArray:self.currentModel.modesCmds];
            if (index != 0) {
                if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                    [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_mode_l"]];
                } else {
                    [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_mode_p"]];
                }
            }
            break;
        case TYPE_LIGHT:
            detailViewNames = [[NSMutableArray alloc] initWithArray:self.currentModel.lightNames];
            detailViewBtns = [[NSMutableArray alloc] initWithArray:self.currentModel.lightBtns];
            detailViewCmds = [[NSMutableArray alloc] initWithArray:self.currentModel.lightCmds];
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_light_l"]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_light_p"]];
            }
            break;
        case TYPE_CURTAIN:
            detailViewNames = [[NSMutableArray alloc] initWithArray:self.currentModel.curtainNames];
            detailViewBtns = [[NSMutableArray alloc] initWithArray:self.currentModel.curtainBtns];
            detailViewCmds = [[NSMutableArray alloc] initWithArray:self.currentModel.curtainCmds];
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_curtain_l"]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_curtain_p"]];
            }
            break;
        case TYPE_AIR:
            detailViewNames = [[NSMutableArray alloc] initWithArray:self.currentModel.airNames];
            detailViewCmds = [[NSMutableArray alloc] initWithArray:self.currentModel.airCmds];
            airViewModes = [[NSMutableArray alloc] initWithArray:self.currentModel.airModes];
            airViewAddrs = [[NSMutableArray alloc] initWithArray:self.currentModel.airAddrs];
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_air_l"]];
            } else {
                [self.detailBackground setImage:[UIImage imageNamed:@"bg_detail_air_p"]];
            }
            break;
    }
    [self.GuidePanel setHidden:YES];
    if (type != TYPE_MODE) {
        [self.detailView setContentSize:CGSizeMake(844*detailViewNames.count, 553)];
        if (detailViewNames.count > 1) {
            [self.GuidePanel setFrame:CGRectMake(160+(844-(detailViewNames.count*2-1)*15)/2.0, 694, (detailViewNames.count*2-1)*15, 44)];
            for (int i = 0; i < detailViewNames.count; i++) {
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
        }
    }
    if (type == TYPE_LIGHT) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < detailViewNames.count; i++) {
                SHDetailContolView *detailViewPanel = [[SHDetailContolView alloc] initWithFrame:CGRectMake(i/6*844 + 34.5 + (i%2)*395, 45 + i/2%3*155, 380, 140)andTitle:[detailViewNames objectAtIndex:i] andType:type andController:self];
                [detailViewPanel setButtons:[detailViewBtns objectAtIndex:i] andCmd:[detailViewCmds objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        } else {
            int height = MAX(580, (150 * detailViewNames.count));
            [self.detailView setContentSize:CGSizeMake(588, height)];
            for (int i = 0; i < detailViewNames.count; i++) {
                SHDetailContolView *detailViewPanel = [[SHDetailContolView alloc] initWithFrame:CGRectMake(104, i*150, 380, 140)andTitle:[detailViewNames objectAtIndex:i] andType:type andController:self];
                [detailViewPanel setButtons:[detailViewBtns objectAtIndex:i] andCmd:[detailViewCmds objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        }
    } else if (type == TYPE_CURTAIN) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < detailViewNames.count; i++) {
                SHDetailContolView *detailViewPanel = [[SHDetailContolView alloc] initWithFrame:CGRectMake(i/6*844 + 34.5 + (i%2)*395, 45 + i/2%3*155, 380, 140)andTitle:[detailViewNames objectAtIndex:i] andType:type andController:self];
                [detailViewPanel setButtons:[detailViewBtns objectAtIndex:i] andCmd:[detailViewCmds objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        } else {
            int height = MAX(580, (150 * detailViewNames.count));
            [self.detailView setContentSize:CGSizeMake(588, height)];
            for (int i = 0; i < detailViewNames.count; i++) {
                SHDetailContolView *detailViewPanel = [[SHDetailContolView alloc] initWithFrame:CGRectMake(104, i*150, 380, 140)andTitle:[detailViewNames objectAtIndex:i] andType:type andController:self];
                [detailViewPanel setButtons:[detailViewBtns objectAtIndex:i] andCmd:[detailViewCmds objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        }
    } else if (type == TYPE_AIR) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < detailViewNames.count; i++) {
                SHAirControlView *detailViewPanel = [[SHAirControlView alloc] initWithFrame:CGRectMake(i/2*844 + 26 + (i%2)*409, 45, 383, 490)andTitle:[detailViewNames objectAtIndex:i] andController:self];
                [detailViewPanel setAddrs:[airViewAddrs objectAtIndex:i] andCmds:[detailViewCmds objectAtIndex:i] andModes:[airViewModes objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        } else {
            int height = MAX(580, (300 * detailViewNames.count));
            [self.detailView setContentSize:CGSizeMake(588, height)];
            for (int i = 0; i < detailViewNames.count; i++) {
                SHAirControlView *detailViewPanel = [[SHAirControlView alloc] initWithFrame:CGRectMake(104, i*300, 380, 280) andTitle:[detailViewNames objectAtIndex:i] andController:self];
                [detailViewPanel setAddrs:[airViewAddrs objectAtIndex:i] andCmds:[detailViewCmds objectAtIndex:i] andModes:[airViewModes objectAtIndex:i]];
                [self.detailView addSubview:detailViewPanel];
            }
        }

    } else if (type == TYPE_MODE) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            for (int i = 0; i < detailViewNames.count; i++) {
                UIButton *button = [[UIButton alloc] init];
                [button setFrame:CGRectMake(64.0 + 184.0 * (i % 4), 60.0 + 88.0 * (i / 4), 164.0, 58.0)];
                [button setTitle:[self.currentModel.modesNames objectAtIndex:i] forState:UIControlStateNormal];
                [button setTitle:[self.currentModel.modesNames objectAtIndex:i] forState:UIControlStateSelected];
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
                [button setBackgroundImage:[UIImage imageNamed:@"mode_normal"] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"mode_selected"] forState:UIControlStateSelected];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
                [button setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
                [button setTag:MODE_BTN_BASE_TAG + i];
                [button addTarget:self action:@selector(onModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.detailView addSubview:button];
            }
        } else {
            
        }
    }

}

- (void)onModeButtonClick:(UIButton *)sender
{
    for (int i = MODE_BTN_BASE_TAG; i < MODE_BTN_BASE_TAG + self.currentModel.modesNames.count; i++) {
        [(UIButton *)[self.detailView viewWithTag:i] setSelected:NO];
    }
    [sender setSelected:YES];
    
    self.skipQuery = 1;
    NSString *commandSend = [NSString stringWithFormat:@"%@\r\n", [self.currentModel.modesCmds objectAtIndex:sender.tag - MODE_BTN_BASE_TAG]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^(void){
        NSError *error;
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
        socket.command = commandSend;
        [socket connectToHost:self.myAppDelegate.host onPort:self.myAppDelegate.port withTimeout:3.0 error:&error];
    });
}

- (void)setCurrentMode:(NSString *)mode
{
    if (self.currentType != TYPE_MODE) {
        return;
    }
    //跳过点击按钮后的第一次查询
    if (self.skipQuery == 1) {
        self.skipQuery = 0;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        int btn_tag = -1;
        for (int i = MODE_BTN_BASE_TAG; i < MODE_BTN_BASE_TAG + self.currentModel.modesNames.count; i++) {
            int location = [mode rangeOfString:[self.currentModel.modeBacks objectAtIndex:i - MODE_BTN_BASE_TAG]].location;
            
            if (location == INT32_MAX) {
                //[(UIButton *)[self.modeView viewWithTag:i] setSelected:NO];
            } else {
                //[(UIButton *)[self.modeView viewWithTag:i] setSelected:YES];
                btn_tag = i;
            }
        }
        if (btn_tag > 0) {
            for (int i = MODE_BTN_BASE_TAG; i < MODE_BTN_BASE_TAG + self.currentModel.modesNames.count;i++) {
                if (i == btn_tag) {
                    [(UIButton *)[self.detailView viewWithTag:i] setSelected:YES];
                } else {
                    [(UIButton *)[self.detailView viewWithTag:i] setSelected:NO];
                }
            }
        }
    });
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

-(void)updateViews:(SHRoomModel *)currentModel atIndex:(int)index
{
    if (index == 0) {
        [self.LightButton setHidden:YES];
        [self.ModeButton setHidden:YES];
        [self.CurtainButton setHidden:YES];
        [self.AirButton setHidden:YES];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.detailView setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_l_index0"]];
        } else {
            
        }
    } else {
        [self.LightButton setHidden:NO];
        [self.ModeButton setHidden:NO];
        [self.CurtainButton setHidden:NO];
        [self.AirButton setHidden:NO];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            [self.detailView setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
        } else {
            
        }
    }
    [self setupDetailView:self.currentModel Type:TYPE_MODE AtIndex:index];
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
        [cell.imageView setImage:[UIImage imageNamed:@"selected"]];
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


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x/844.0;
    for (int i = 0; i < self.detailPageCount; i++) {
        UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + i];
        [image setImage:[UIImage imageNamed:@"unselected"]];
    }
    UIImageView *image = (UIImageView *)[self.GuidePanel viewWithTag:GUIDE_PANEL_BASE_TAG + currentPage];
    [image setImage:[UIImage imageNamed:@"selected"]];
}

- (void)queryMode:(NSThread *)thread
{
    while (YES) {
        if (self.needquery) {
            [self sendCommand:self.currentModel.queryCmd];
            sleep(4);
        }
    }
}

- (void)sendCommand:(NSString *)cmd;
{
    [self.myAppDelegate sendCommand:cmd from:self];
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
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.navigationBar setFrame:CGRectMake(0, 0, 1024, 44)];
        [self.tableView setFrame:CGRectMake(0.0, 44.0, 140, 704)];
        [self.ModeButton setFrame:CGRectMake(192.0f, 90.0f, 66.0f, 70.0f)];
        [self.LightButton setFrame:CGRectMake(292.0f, 90.0f, 66.0f, 70.0f)];
        [self.CurtainButton setFrame:CGRectMake(392.0f, 90.0f, 66.0f, 70.0f)];
        [self.AirButton setFrame:CGRectMake(492.0f, 90.0f, 66.0f, 70.0f)];
        [self.detailView setPagingEnabled:YES];
        if (index == 0) {
            [self.detailView setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 128.0f, 844.0f, 600.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_l_index0"]];
        } else {
            [self.detailView setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 175.0f, 844.0f, 553.0f)];
        }
    } else {
        [self.navigationBar setFrame:CGRectMake(0, 0, 768, 44)];
        [self.tableView setFrame:CGRectMake(0.0, 44.0, 140, 960)];
        [self.ModeButton setFrame:CGRectMake(190.0f, 95.0f, 72.0f, 76.0f)];
        [self.LightButton setFrame:CGRectMake(288.0f, 95.0f, 72.0f, 76.0f)];
        [self.CurtainButton setFrame:CGRectMake(386.0f, 95.0f, 72.0f, 76.0f)];
        [self.AirButton setFrame:CGRectMake(484.0f, 95.0f, 72.0f, 76.0f)];
        [self.detailView setPagingEnabled:NO];
        if (index == 0) {
            [self.detailView setFrame:CGRectMake(160.0f, 226.0f, 588.0f, 580.0f)];
            [self.detailBackground setFrame:CGRectMake(160.0f, 186.0f, 588.0f, 640.0f)];
            [self.detailBackground setImage:[UIImage imageNamed:@"detail_bg_p_index0"]];
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
    [sock writeData:[sock.command dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:1 tag:0];
    [sock disconnect];
    sock = nil;
}

@end
