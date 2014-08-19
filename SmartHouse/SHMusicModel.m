//
//  SHMusicModel.m
//  SmartHouseIphone
//
//  Created by Roc on 14-8-13.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHMusicModel.h"

@implementation SHMusicModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.deviceid = [[NSString alloc] init];
        self.modecmd = [[NSString alloc] init];
        self.area = [[NSString alloc] init];
        self.buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
