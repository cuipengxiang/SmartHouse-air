//
//  SHAirConditioningModel.m
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import "SHAirConditioningModel.h"

@implementation SHAirConditioningModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.deviceid = [[NSString alloc] init];
        self.mainaddr = [[NSString alloc] init];
        self.secondaryaddr = [[NSString alloc] init];
        self.modes = [[NSArray alloc] init];
    }
    return self;
}

@end
