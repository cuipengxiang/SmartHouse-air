//
//  SHLightModel.m
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import "SHLightModel.h"

@implementation SHLightModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.deviceid = [[NSString alloc] init];
        self.area = [[NSString alloc] init];
        self.channel = [[NSString alloc] init];
        self.fade = [[NSString alloc] init];
    }
    return self;
}

@end
