//
//  SHRoomModel.m
//  SmartHouse
//
//  Created by 衣世倩 on 8/14/13.
//  Copyright (c) 2013 Roc. All rights reserved.
//

#import "SHRoomModel.h"

@implementation SHRoomModel

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [[NSString alloc] init];
        self.modes = [[NSMutableArray alloc] init];
        self.lights = [[NSMutableArray alloc] init];
        self.curtains = [[NSMutableArray alloc] init];
        self.airconditionings = [[NSMutableArray alloc] init];
        self.musics = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
