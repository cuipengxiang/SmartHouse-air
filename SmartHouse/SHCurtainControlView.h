//
//  SHCurtainControlView.h
//  SmartHouse-Air
//
//  Created by Roc on 14-3-1.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"
#import "SHControlViewController.h"

@interface SHCurtainControlView : UIView<GCDAsyncSocketDelegate>

@property (nonatomic, strong) SHControlViewController *controller;
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic, strong) AppDelegate *myDelegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *onButton;
@property (nonatomic, strong) UIButton *offButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIImageView *CurtainImage;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)titleString andController:(SHControlViewController *)controller;
- (void)onOnButtonClick:(UIButton *)sender;
- (void)onOffButtonClick:(UIButton *)sender;
- (void)onStopButtonClick:(UIButton *)sender;

@end