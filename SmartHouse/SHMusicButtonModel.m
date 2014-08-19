//
//  SHMusicButtonModel.m
//  SmartHouseIphone
//
//  Created by Roc on 14-8-17.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHMusicButtonModel.h"

@implementation SHMusicButtonModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.command = [[NSString alloc] init];
    }
    return self;
}

@end
