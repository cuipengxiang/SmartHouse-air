//
//  SHMusicModel.h
//  SmartHouseIphone
//
//  Created by Roc on 14-8-13.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHMusicModel : NSObject

@property (nonatomic,strong)NSString *deviceid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *area;
@property (nonatomic,strong)NSString *channel;
@property (nonatomic,strong)NSString *modecmd;
@property (nonatomic,strong)NSMutableArray *buttons;

- (id)init;

@end
