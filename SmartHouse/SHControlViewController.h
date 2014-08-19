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

@interface SHControlViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,GCDAsyncSocketDelegate>

{
    UIImageView *firstImageView;
    
    NSArray *Lights;
    NSArray *Curtains;
    NSArray *AirConditionings;
    NSArray *Musics;
}

@property(nonatomic)dispatch_queue_t socketQueue;
@property(nonatomic, strong)AppDelegate *myAppDelegate;
@property(nonatomic, strong)NSThread *myModeQueryThread;
@property(nonatomic, strong)NSThread *myModeSetThread;
@property(nonatomic, strong)UINavigationBar *navigationBar;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)UIButton *ModeButton;
@property(nonatomic, strong)UIButton *LightButton;
@property(nonatomic, strong)UIButton *CurtainButton;
@property(nonatomic, strong)UIButton *AirButton;
@property(nonatomic, strong)UIButton *MusicButton;
@property(nonatomic, strong)UIButton *NetStateButton;
@property(nonatomic, strong)UIButton *leftButton;
@property(nonatomic, strong)UIButton *rightButton;
@property(nonatomic, strong)UIScrollView *detailView;
@property(nonatomic, strong)UIView *GuidePanel;
@property(nonatomic, strong)UIImageView *detailBackground;
@property(nonatomic, strong)UIButton *networkStateButton;
@property(nonatomic, strong)UIBarButtonItem *networkBarButton;
@property(nonatomic, strong)UINavigationItem *item;
@property(nonatomic)BOOL insideNetAddr;
@property(nonatomic, strong)NSMutableArray *queryCmds;
@property(nonatomic)int currentType;

@property(nonatomic, retain)SHLoginViewController *backController;

@property(nonatomic)SHRoomModel *currentModel;

@property(nonatomic)int detailPageCount;
@property(nonatomic)int currentDetailPage;

@property(nonatomic, strong)NSMutableArray *defineModeCmd;
@property(nonatomic) int scrollLastViewPage;
@property(nonatomic, strong)NSMutableArray *detailViews;

- (void)setViewFramesForOrientation:(UIInterfaceOrientation)orientation AtIndex:(int)index;
- (void)setupNavigationBar:(float)width;
- (void)setupDetailView:(SHRoomModel *)currentModel Type:(int)type AtIndex:(int)index;
- (void)updateViews:(SHRoomModel *)currentModel atIndex:(int)index;

- (void)onBackButtonClick;
- (void)onSettingsButtonClick;

- (void)onLightClick:(id)sender;
- (void)onCuitainClick:(id)sender;
- (void)onModeClick:(id)sender;
- (void)onAirClick:(id)sender;
- (void)onNetStateButtonClick:(id)sender;

- (void)setNetworkState:(BOOL)state;
- (void)onModeButtonClick:(UIButton *)sender;
- (void)onModeButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer;

- (void)onLeftButtonClick:(UIButton *)sender;
- (void)onRightButtonClick:(UIButton *)sender;

- (void)setDetailViewScroll:(NSMutableArray *)detailViews;

- (int)checkCurrentTypeState:(SHRoomModel *)model;
- (void)queryMode:(NSThread *)thread;
- (void)setMode:(NSThread *)thread;
- (void)saveUserDefineMode;
- (void)setCurrentViewQuery:(int)currentViewPage NewPage:(int)newViewPage;

- (NSMutableArray *)contentToCommamd:(NSArray *)contents;

@end
