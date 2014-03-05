//
//  SHModeModel.m
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import "SHModeModel.h"

@implementation SHModeModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.modeid = [[NSString alloc] init];
        self.modecmd = [[NSString alloc] init];
        self.area = [[NSString alloc] init];
    }
    return self;
}

@end
