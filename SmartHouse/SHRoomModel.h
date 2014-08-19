//
//  SHRoomModel.h
//  SmartHouse
//
//  Created by 衣世倩 on 8/14/13.
//  Copyright (c) 2013 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHRoomModel : NSObject

@property (nonatomic,strong)NSString *roomid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSMutableArray *modes;
@property (nonatomic,strong)NSMutableArray *lights;
@property (nonatomic,strong)NSMutableArray *curtains;
@property (nonatomic,strong)NSMutableArray *airconditionings;
@property (nonatomic,strong)NSMutableArray *musics;

- (id)init;

@end
