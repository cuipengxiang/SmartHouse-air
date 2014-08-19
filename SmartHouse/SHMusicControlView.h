//
//  SHMusicControlView.h
//  SmartHouse-Air
//
//  Created by Roc on 14-8-19.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"
#import "SHControlViewController.h"
#import "SHMusicModel.h"
#import "SHDetailView.h"

@interface SHMusicControlView : SHDetailView<GCDAsyncSocketDelegate>
{
    BOOL skip;
}

@property (nonatomic)dispatch_queue_t socketQueue;
@property (nonatomic,strong)AppDelegate *myDelegate;
@property (nonatomic,retain)SHControlViewController *controller;
@property (nonatomic,strong)SHMusicModel *model;

- (id)initWithFrame:(CGRect)frame andModel:(SHMusicModel *)model andController:(SHControlViewController *)controller;
- (void)setDetailWithModel;

@end
