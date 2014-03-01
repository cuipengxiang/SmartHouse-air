//
//  SHLightControlView.h
//  SmartHouse-Air
//
//  Created by Roc on 14-3-1.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"
#import "SHControlViewController.h"

@interface SHLightControlView : UIView<GCDAsyncSocketDelegate>

@property (nonatomic, strong) SHControlViewController *controller;
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic, strong) AppDelegate *myDelegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *on_off;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *lessButton;
@property (nonatomic) int Brightness;
@property (nonatomic) BOOL isNowOn;
@property (nonatomic, strong) UIView *BrightnessControl;
@property (nonatomic, strong) UIImageView *BrightnessImage;

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)titleString andController:(SHControlViewController *)controller;
- (void)onSwitchButtonClick:(UIButton *)sender;
- (void)onMoreButtonClick:(UIButton *)sender;
- (void)onLessButtonClick:(UIButton *)sender;
- (void)setBrightnessDegree:(int)degree;

@end
