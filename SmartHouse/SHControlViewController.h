//
//  SHControlViewController.h
//  SmartHouse
//
//  Created by Roc on 13-8-13.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SHRoomModel.h"
#import "SHLoginViewController.h"
#import "GCDAsyncSocket.h"

@interface SHControlViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,GCDAsyncSocketDelegate>


@property(nonatomic)dispatch_queue_t socketQueue;
@property(nonatomic, strong)AppDelegate *myAppDelegate;
@property(nonatomic, strong)NSThread *myModeThread;
@property(nonatomic, strong)UINavigationBar *navigationBar;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIButton *ModeButton;
@property(nonatomic, strong)UIButton *LightButton;
@property(nonatomic, strong)UIButton *CurtainButton;
@property(nonatomic, strong)UIButton *AirButton;
@property(nonatomic, strong)UIScrollView *detailView;
@property(nonatomic, strong)UIView *GuidePanel;
@property(nonatomic, strong)UIImageView *detailBackground;
@property(nonatomic, strong)UIButton *networkStateButton;
@property(nonatomic, strong)UIBarButtonItem *networkBarButton;
@property(nonatomic, strong)UINavigationItem *item;

@property(nonatomic)int currentType;

@property(nonatomic, retain)SHLoginViewController *backController;

@property(nonatomic)SHRoomModel *currentModel;
@property(nonatomic)int modesCount;
@property(nonatomic)int detailPageCount;

@property BOOL needquery;
@property int skipQuery;

- (void)setupNavigationBar:(float)width;
- (void)setupDetailView:(SHRoomModel *)currentModel Type:(int)type;
- (void)updateViews:(SHRoomModel *)currentModel;

- (void)onBackButtonClick;
- (void)onSettingsButtonClick;

- (void)onLightClick:(id)sender;
- (void)onCuitainClick:(id)sender;
- (void)onModeClick:(id)sender;
- (void)onAirClick:(id)sender;

- (void)sendCommand:(NSString *)cmd;
- (void)setNetworkState:(BOOL)state;
- (void)onModeButtonClick:(UIButton *)sender;
- (void)setCurrentMode:(NSString *)mode;

@end
