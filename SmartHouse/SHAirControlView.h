//
//  SHMusicControlView.h
//  SmartHouse
//
//  Created by Roc on 13-8-16.
//  Copyright (c) 2013年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SHControlViewController.h"
#import "GCDAsyncSocket.h"
#import "SHAirConditioningModel.h"

@interface SHAirControlView : UIView<GCDAsyncSocketDelegate>
{
    UIView *modePanel;
    UIView *speedPanel;
    UIView *tempPanel;
    
    UILabel *label_indoor;
    UILabel *tempsysbol;
    UILabel *temp_big;
    UILabel *temp_mini;

    UIImageView *modeImage;
    UIImageView *speedImage;
    
    BOOL skip;
}

@property (nonatomic)dispatch_queue_t socketQueue;
@property (nonatomic,strong)AppDelegate *myDelegate;
@property (nonatomic,strong)NSThread *myModeThread;
@property (nonatomic,retain)SHControlViewController *controller;
@property (nonatomic,strong)UIButton *settingButton;
@property (nonatomic,strong)UIButton *open_close;
@property (nonatomic,strong)UIButton *tempHigher;
@property (nonatomic,strong)UIButton *tempLower;
@property (nonatomic) int currentMode;
@property (nonatomic) int currentSpeed;
@property (nonatomic) int currentTemp;
@property (nonatomic) int isOnNow;
@property (nonatomic,strong)SHAirConditioningModel *model;

- (id)initWithFrame:(CGRect)frame andModel:(SHAirConditioningModel *)model andController:(SHControlViewController *)controller;
- (void)setDetailWithModel;
- (void)onSettingButtonClick:(UIButton *)button;
- (void)onCloseButtonClick:(UIButton *)button;
- (void)onHigherButtonClick:(UIButton *)button;
- (void)onLowerButtonClick:(UIButton *)button;
- (void)onModeButtonClick:(UIButton *)button;
- (void)onSpeedButtonClick:(UIButton *)button;
- (int)checkMode:(NSString *)mode;

@end